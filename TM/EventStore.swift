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
    
    private var pointerToAfterAsync: AfterAsynchronous? = nil
    
    func checkEventKitAuthorizationStatus(afterCheck: AfterAsynchronous) {
        pointerToAfterAsync = afterCheck
        let calendarAuthorization = checkEventAuthorizationStatus(typeOfEntity: EKEntityType.event)
        let reminderAuthorization = checkEventAuthorizationStatus(typeOfEntity: EKEntityType.reminder)
        
        if calendarAuthorization == true && reminderAuthorization == true {
            Error.manageError.changeError(typeOfError: "Permission", error: true)
            loadCalendars()
        } else {
            Error.manageError.changeError(typeOfError: "Permission", error: false)
            afterCheck.onFinish()
        }
    }
    
    private func callOnFinish() {
        pointerToAfterAsync?.onFinish()
    }
    
    private func checkEventAuthorizationStatus(typeOfEntity: EKEntityType) -> Bool {
        var returnValue:Bool = false
        let status = EKEventStore.authorizationStatus(for: typeOfEntity)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            returnValue = (requestAccessToCalendar(typeOfEntity: typeOfEntity))
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
    
    private func requestAccessToCalendar(typeOfEntity: EKEntityType) -> Bool {
        var returnValue:Bool = false
        eventStore.requestAccess(to: typeOfEntity, completion: { (granted, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
                returnValue = false
            } else {
                print("User accepted event permission")
                returnValue = true
                self.checkEventKitAuthorizationStatus(afterCheck: self.pointerToAfterAsync!)
            }
        })
        return returnValue
    }
    
    private var homeViewCalendars: [EKEvent] = []
    private var homeViewReminders: [EKReminder] = []
    
    func giveCalendarsSinceNow() -> [EKEvent] {
        return homeViewCalendars
    }
    
    func giveReminders() -> [EKReminder] {
        return homeViewReminders
    }
    
    func eraseEventArrays() {
        homeViewCalendars.removeAll()
        homeViewReminders.removeAll()
    }
    
    private func loadCalendars() {
        let calendars = eventStore.calendars(for: .event)
        for calendar in calendars {
            let startDate = Date(timeIntervalSinceNow: 0)
            let endDate = Date(timeIntervalSinceNow: +365*24*3600)
            
            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
            let events = eventStore.events(matching: predicate)
            for event in events {
                homeViewCalendars.append(event)
            }
        }
        loadReminders()
    }
    
    private func loadReminders() {
        let predicate = eventStore.predicateForReminders(in: nil)
        eventStore.fetchReminders(matching: predicate) { (fetchedEvents: [EKReminder]?) in
            if let events = fetchedEvents {
                for event in events {
                    self.homeViewReminders.append(event)
                }
            }
            self.callOnFinish()
        }
    }
    
}
