//
//  YearMonth.swift
//  Coco
//
//  Created by suyu on 2019/9/2.
//  Copyright © 2019 365rili.com. All rights reserved.
//

import UIKit

open class YearMonth: NSObject {
    static var days: [Int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    
    private(set) var year: Int
    private(set) var month: Int
    private(set) var weeks: Int = 0
    
    public var firstDayOfWeek: Weekday = .sunday {
        didSet {
            self.calculateWeeks()
        }
    }
    
    public init(year: Int, month: Int, firstWeekday: Weekday = .sunday) {
        self.year = year
        self.month = month
        super.init()
        self.calculateWeeks()
    }
    
    public static func current() -> YearMonth {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents(Set([Calendar.Component.year, Calendar.Component.month]), from: date)
        return YearMonth(year: components.year ?? 2019, month: components.month ?? 8)
    }
    
    public func next(month: Int = 1) -> YearMonth {
        var cy = self.year + Int(Double(month - 1) / 12.0)
        var cm = self.month + (month - 1) % 12 + 1
        
        if cm > 12 {
            cy += 1
            cm -= 12
        }
        else if cm < 1 {
            cy -= 1
            cm += 12
        }
        return YearMonth(year: cy, month: cm, firstWeekday: self.firstDayOfWeek)
    }
    
    public func firstDay() -> Date {
        return Calendar.current.date(from: DateComponents(year: self.year, month: self.month, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0))!
    }
    
    public func lastDay() -> Date {
        return self.next().firstDay().addingTimeInterval(-1)
    }
    
    public func daysInMonth() -> Int {
        if self.month != 2 {
            return YearMonth.days[self.month - 1]
        }
        return Date.isLeap(year: self.year) ? 29 : 28
    }
    
    // 0 1 2 3 4 5 6
    // 6 0 1 2 3 4 5
    // 5 6 0 1 2 3 4
    // 4 5 6 0 1 2 3
    // 3 4 5 6 0 1 2
    // 2 3 4 5 6 0 1
    // 1 2 3 4 5 6 0
    public func calculateWeeks() {
        let days = self.daysInMonth()
        
        let add: [Int] = [0, 1, 2, 3, 4, 5, 6].map { (i) -> Int in
            return (i - self.firstDayOfWeek.rawValue + 7) % 7
        }
        
        let weeks = Int(ceil(Double(days + add[self.firstDay().weekday().rawValue]) / 7.0))
        self.weeks = weeks
    }
    
    public func index() -> Int {
        let add: [Int] = [0, 1, 2, 3, 4, 5, 6].map { (i) -> Int in
            return (i - self.firstDayOfWeek.rawValue + 7) % 7
        }
        return add[self.firstDay().weekday().rawValue]
    }
    
    public func diffMonth(another: YearMonth) -> Int {
        return (self.year - another.year) * 12 + (self.month - another.month)
    }
    
    public func toString() -> String {
        return String(format: "%4d-%02d", self.year, self.month)
    }
    
    public func isEqualToYearMonth(_ another: YearMonth) -> Bool {
        return self.year == another.year && self.month == another.month
    }
    
    public func weekOfMonth(forDate date: Date) -> Int {
        let firstDay = self.firstDay().addingTimeInterval(Double(-86400 * self.index()))
        return Int(floor(date.timeIntervalSince(firstDay) / Double(86400.0 * 7)))
    }
}
