//
//  Date.swift
//  CalendarApp
//
//  Created by Scott Horsfall on 6/9/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import Foundation
import UIKit

func dateFormatterToString(date: NSDate, dateStyle: String) -> String {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale.currentLocale()
    
    if dateStyle == "Full" {
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
    } else if dateStyle == "Long" {
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
    } else if dateStyle == "Medium" {
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
    } else if dateStyle == "Short" {
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    } else {
        dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
    }
    
    return dateFormatter.stringFromDate(date)
}

func timeFormatterToString(date: NSDate, timeStyle: String) -> String {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale.currentLocale()
    
    if timeStyle == "Full" {
        dateFormatter.timeStyle = NSDateFormatterStyle.FullStyle
    } else if timeStyle == "Long" {
        dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
    } else if timeStyle == "Medium" {
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
    } else if timeStyle == "Short" {
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    } else {
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
    }
    
    return dateFormatter.stringFromDate(date)
}

extension NSDate {
    
    func year() -> Int? {
        if
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = cal.components(.Year, fromDate: self) {
            return comp.year
        } else {
            return nil
        }
    }
    
    func month() -> Int? {
        if
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = cal.components(.Month, fromDate: self) {
            return comp.month
        } else {
            return nil
        }
    }
    
    func day() -> Int? {
        if
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = cal.components(.Day, fromDate: self) {
            return comp.day
        } else {
            return nil
        }
    }
    
    func hour() -> Int? {
        if
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = cal.components(.Hour, fromDate: self) {
            return comp.hour
        } else {
            return nil
        }
    }
    
    func mins() -> Int? {
        if
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = cal.components(.Minute, fromDate: self) {
            return comp.minute
        } else {
            return nil
        }
    }
    
    func dayOfWeek() -> Int? {
        if
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = cal.components(.Weekday, fromDate: self) {
            return comp.weekday
        } else {
            return nil
        }
    }
    
    func titleFormat() -> String? {
        // return date in format, ex: Wed, Jun 5
        let titleFormatter = NSDateFormatter()
        titleFormatter.dateFormat = "EEE, MMM d"
        return titleFormatter.stringFromDate(self)
    }
    
    func hourFormat() -> String? {
        // return date in format, ex: Wed, Jun 5
        let hourFormatter = NSDateFormatter()
        hourFormatter.locale = NSLocale.currentLocale()
        hourFormatter.dateFormat = "h:mm"
        return hourFormatter.stringFromDate(self)
    }
    
    func dayBegin() -> NSDate? {
        let todayComponents = NSDateComponents()
        todayComponents.year = self.year()!
        todayComponents.month = self.month()!
        todayComponents.day = self.day()!
        todayComponents.hour = 0
        todayComponents.minute = 0
        todayComponents.second = 0
        
        let today = NSCalendar.currentCalendar().dateFromComponents(todayComponents)
        
        return today
    }
    
    func setHour(hour: Int) -> NSDate? {
        
        let dateComponents = NSDateComponents()
        dateComponents.year = self.year()!
        dateComponents.month = self.month()!
        dateComponents.day = self.day()!
        dateComponents.hour = hour
        dateComponents.minute = 0
        dateComponents.second = 0
        
        let setHour = NSCalendar.currentCalendar().dateFromComponents(dateComponents)
        
        return setHour
        
    }
    
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func hoursFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    
    func minutesFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    
    func timeFromFloat(date: NSDate) -> Double {
        
        let minutes = NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
        let hours = Double(minutes / 60)
        let remainder = minutes % 60
        var decimal: Double!
        var time: Double!
        
        if hours >= 1 {
            if remainder >= 45 {
                decimal = 0.75
                time = hours + decimal
            } else if remainder >= 30 {
                decimal = 0.5
                time = hours + decimal
            } else if remainder >= 15 {
                decimal = 0.25
                time = hours + decimal
            } else {
                decimal = 0.0
                time = hours
            }
        } else {
            time = Double(minutes)
        }
        return time
    }
    
    func hoursFromFloat(date: NSDate) -> Double {
        
        let minutes = NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
        let hours = Double(minutes / 60)
        
        print("hoursFromFloat \(hours)")
        return hours
    }
    
    
    
    func stringTimeFromFloat(date: NSDate) -> String {
        
        let minutes = NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
        let hours = Double(minutes / 60)
        
        var timeString: String!
        
        if hours >= 1 {
            if minutes > 60 {
                timeString = "hours"
            } else {
                timeString = "hour"
            }
        } else {
            timeString = "minutes"
        }
        // set to true if hours
        
        return timeString
    }
    
}
