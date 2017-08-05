//
//  CalendarEvents.swift
//  TM
//
//  Created by Amin Amjadi on 8/5/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import Foundation

class CalendarEvent {
    
    let startDate: Date
    let subject: String
    
    private static let s_dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    private init(startDate date: Date, subject: String) {
        self.startDate = date
        self.subject = subject
    }
    
    class func event(withJson json: [String: Any]) -> CalendarEvent? {
        guard let subject = json["subject"] as? String, let startDict = json["start"] as? [String: Any] else {
            return nil
        }
        
        guard let startTimeString = startDict["dateTime"] as? String else {
            return nil
        }
        
        guard let start = s_dateFormatter.date(from: startTimeString) else {
            return nil
        }
        
        return CalendarEvent(startDate: start, subject: subject)
    }
}
