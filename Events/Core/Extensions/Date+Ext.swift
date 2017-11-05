//
//  Date+Ext.swift
//  Events
//
//  Created by Antony on 05/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Foundation


extension Date {
    
    func stringValue(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func stringValue(withDateStyle dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style = DateFormatter.Style.none) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        return dateFormatter.string(from : self)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isSameDay(of date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
}

extension String {
    
    // MARK: - Returns NSDate for JSON String Date based on format rules
    func date(withFormat format:String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", formatter : DateFormatter? = nil) -> Date? {
        
        let formatter = formatter ?? DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = format
        
        return formatter.date(from: self)
    }
    
}
