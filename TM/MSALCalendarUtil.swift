//
//  MSALCalendarUtil.swift
//  TM
//
//  Created by Amin Amjadi on 8/5/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import Foundation

typealias CalendarCompletion = ([Date: [CalendarEvent]]?, Error?) -> Void

class MSALCalendarUtil {
    // Constants
    fileprivate let kLastEventsCheckKey = "last_MSALevents_check"
    fileprivate let kEventsKey = "MSALevents"
    
    // Singleton instance
    static let shared = MSALCalendarUtil()
    
    private init() {
        if let storedEvents = UserDefaults.standard.object(forKey: kEventsKey) as? [[String: Any]] {
            self.cachedEvents = processEvents(withEvents: storedEvents)
        }
        else {
            self.cachedEvents = [Date: [CalendarEvent]]()
        }
    }
    
    /*
     Returns cached events (if any) for the current user
     */
    var cachedEvents: [Date: [CalendarEvent]]!
    
    /*
     Clears any cached events for the current user
     */
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: kLastEventsCheckKey)
        cachedEvents.removeAll()
    }
    
    /*
     Retrieves updated calendar event information from Microsoft graph
     */
    func getEvents(withCompletion completion: @escaping CalendarCompletion) {
        
        if checkTimestamp() == false {
            return
        }
        
        MSALUtil.shared.acquireTokenForCurrentUser(forScopes: ["Calendars.Read"]) {
            (token: String?, error: Error?) in
            
            guard let accessToken = token else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            self.getJsonEvents(withToken: accessToken, completion: {
                (jsonEvents: [[String : Any]]?, error: Error?) in
                
                self.setLastChecked()
                let processedEvents = self.processEvents(withEvents: jsonEvents)
                
                DispatchQueue.main.async {
                    if let jsonEvents = jsonEvents {
                        self.storeEvents(withJsonArray: jsonEvents)
                        self.cachedEvents = processedEvents
                    }
                    completion(processedEvents, error)
                }
            })
        }
    }
}

// MARK: Private methods
fileprivate extension MSALCalendarUtil {
    
    func processEvents(withEvents events: [[String: Any]]?) -> [Date: [CalendarEvent]] {
        
        guard let events = events else {
            return [Date: [CalendarEvent]]()
        }
        
        var eventDictionary = [Date: [CalendarEvent]]()
        let calendar = Calendar.current
        
        for jsonEvent in events {
            if let event = CalendarEvent.event(withJson: jsonEvent) {
                /*if event.startDate.timeIntervalSinceNow < 0 {
                    continue
                }*/
                
                let day = calendar.startOfDay(for: event.startDate)
                
                if (eventDictionary[day] == nil) {
                    eventDictionary[day] = [CalendarEvent]()
                }
                
                eventDictionary[day]!.append(event)
            }
        }
        
        return eventDictionary
    }
    
    func checkTimestamp() -> Bool {
        if let lastChecked = UserDefaults.standard.object(forKey: kLastEventsCheckKey) as? Date {
            // Only check for updated events every 30 minutes
            return (-lastChecked.timeIntervalSinceNow > 30 * 60)
        }
        return true
    }
    
    func setLastChecked() {
        UserDefaults.standard.set(Date(), forKey: kLastEventsCheckKey)
    }
    
    func storeEvents(withJsonArray json: [[String: Any]]) {
        UserDefaults.standard.set(json, forKey: kEventsKey)
    }
    
    func getJsonEvents(withToken token: String,
                       completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        
        let request = MSALGraphRequest(withToken: token)
        
        request.getJSON(path: "me/events?$select=subject,start") {
            (jsonEvents: [String : Any]?, error: Error?) in
            
            guard let jsonEvents = jsonEvents else {
                completion(nil, error)
                return
            }
            
            guard let verifiedJsonEvents = jsonEvents["value"] as? [[String: Any]] else {
                completion(nil, AppError.ErrorType.ServerInvalidResponse)
                return
            }
            
            completion(verifiedJsonEvents, nil)
        }
    }
}
