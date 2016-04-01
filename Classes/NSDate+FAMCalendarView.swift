//
//  NSDate+FAMCalendarView.swift
//  FAMCalendarView
//
//  Created by Kazuya Ueoka on 2016/03/27.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import Foundation

public enum FAMCalendarWeekDay :Int
{
    case Sunday = 0
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    static func toString(value :Int) -> String
    {
        switch value
        {
        case self.Sunday.rawValue:
            return "Sun"
        case self.Monday.rawValue:
            return "Mon"
        case self.Tuesday.rawValue:
            return "Tue"
        case self.Wednesday.rawValue:
            return "Wed"
        case self.Thursday.rawValue:
            return "Thu"
        case self.Friday.rawValue:
            return "Fri"
        case self.Saturday.rawValue:
            return "Sat"
        default:
            return ""
        }
    }
}

public protocol NSDateFAMCalendarViewProtocol
{
    func dateFromIndexPath(indexPath :NSIndexPath) -> NSDate?
    func day() -> Int
    func isEqual(toYear year :Int, month :Int) -> Bool
    func formatedString(format :String) -> String
    static func date(fromYear year :Int, month :Int, day :Int) -> NSDate
    static func totalMonths(minDate :NSDate, maxDate :NSDate) -> Int
}

extension NSDate :NSDateFAMCalendarViewProtocol
{
    public func dateFromIndexPath(indexPath: NSIndexPath) -> NSDate? {
        let calendar :NSCalendar = NSCalendar.currentCalendar()
        calendar.locale = NSLocale.systemLocale()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        
        let comp1 :NSDateComponents = calendar.components([.Year, .Month], fromDate: self)
        let comp2 :NSDateComponents = NSDateComponents()
        comp2.weekOfMonth = indexPath.section + 1
        comp2.weekday     = indexPath.row + 1
        comp2.year        = comp1.year
        comp2.month       = comp1.month
        return calendar.dateFromComponents(comp2)
    }
    
    public func day() -> Int {
        let calendar :NSCalendar = NSCalendar.currentCalendar()
        calendar.locale = NSLocale.systemLocale()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        return calendar.component(.Day, fromDate: self)
    }
    
    public func isEqual(toYear year: Int, month: Int) -> Bool {
        let calendar :NSCalendar = NSCalendar.currentCalendar()
        calendar.locale = NSLocale.systemLocale()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        let components :NSDateComponents = calendar.components([.Year, .Month], fromDate: self)
        return components.year == year && components.month == month
    }
    
    public func formatedString(format: String) -> String {
        let formatter :NSDateFormatter = NSDateFormatter()
        formatter.locale = NSLocale.systemLocale()
        formatter.timeZone = NSTimeZone.systemTimeZone()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
    public static func date(fromYear year :Int, month :Int, day :Int) -> NSDate {
        let components :NSDateComponents = NSDateComponents()
        components.year = year
        components.month = month
        components.day = day
        let calendar :NSCalendar = NSCalendar.currentCalendar()
        calendar.locale = NSLocale.systemLocale()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        return calendar.dateFromComponents(components)!
    }

    public static func totalMonths(minDate: NSDate, maxDate: NSDate) -> Int {
        let minComp :NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: minDate)
        let maxComp :NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: maxDate)

        let totalYear :Int = maxComp.year - minComp.year
        let totalMonth :Int = maxComp.month - minComp.month

        return totalYear * 12 + totalMonth + 1
    }
}