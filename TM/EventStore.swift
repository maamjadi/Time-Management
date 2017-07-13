//
//  File.swift
//  TM
//
//  Created by Amin Amjadi on 7/6/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import Foundation
import EventKit

class EventStore {
    
    static let eventKit = EventStore()
    
    private var eventStore = EKEventStore()
    
    func checkEventKitAuthorizationStatus(afterCheck: AfterAsynchronous) {
        let calendarAuthorization = checkEventAuthorizationStatus(typeOfEntity: EKEntityType.event)
        let reminderAuthorization = checkEventAuthorizationStatus(typeOfEntity: EKEntityType.reminder)
        
        if calendarAuthorization == true && reminderAuthorization == true {
            Error.manageError.changeError(typeOfError: "Permission", error: true)
            loadCalendars()
            loadReminders()
            afterCheck.onFinish()
        } else {
            Error.manageError.changeError(typeOfError: "Permission", error: false)
            afterCheck.onFinish()
        }
    }
    
    private func checkEventAuthorizationStatus(typeOfEntity: EKEntityType) -> Bool {
        var returnValue:Bool = false
        let status = EKEventStore.authorizationStatus(for: typeOfEntity)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            returnValue = (requestAccessToCalendar(typeOfEntity: typeOfEntity))!
            break
        case EKAuthorizationStatus.authorized:
            // Things are in line with being able to show the calendars in the table view
            returnValue = true
            break
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            break
        }
        
        return returnValue

    }
    
    private func requestAccessToCalendar(typeOfEntity: EKEntityType) -> Bool? {
        var returnValue:Bool? = nil
        eventStore.requestAccess(to: typeOfEntity, completion: { (granted, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
                returnValue = false
            } else {
                print("User accepted event permission")
                returnValue = true
            }
        })
        return returnValue
    }
    
    private var iCarouselCalendar: [EKEvent] = []
    private var reminderTitles: [EKReminder] = []
    
    func giveCalendarsSinceNow() -> [EKEvent] {
        return iCarouselCalendar
    }
    
    func giveReminders() -> [EKReminder] {
        return reminderTitles
    }
    
    private func loadCalendars() {
        let calendars = eventStore.calendars(for: .event)
        for calendar in calendars {
            let startDate = Date(timeIntervalSinceNow: 0)
            let endDate = Date(timeIntervalSinceNow: +365*24*3600)
            
             let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
            let events = eventStore.events(matching: predicate)
            
            for event in events {
                iCarouselCalendar.append(event)
            }
        }
    }
    
    private func loadReminders() {
        let predicate = eventStore.predicateForReminders(in: nil)
       eventStore.fetchReminders(matching: predicate) { (fetchedEvents: [EKReminder]?) in
        if let events = fetchedEvents {
        for event in events {
            self.reminderTitles.append(event)
        }
        }
        }
        
    }

}
