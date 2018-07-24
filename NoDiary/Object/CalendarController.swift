//
//  AppDelegate.swift
//  NoDiary
//
//  Created by Xie Liwei on 18/07/2018.
//  Copyright © 2018 Xie Liwei. All rights reserved.
//

import Cocoa

struct Day {
    var isNumber = false
    var isToday = false
    var isCurrentMonth = false
    var text = "0"
    var hasDiary = false
    var date = Date()
}

class CalendarController: NSObject {
    
    let calendar = Calendar.autoupdatingCurrent
    let formatter = DateFormatter()
    let monthFormatter = DateFormatter()
    var locale: Locale!
    var dayZero: Date? = nil
    var shownItemCount = 0
    var weekdays: [String] = []
    var daysInWeek = 0
    var monthOffset = 0
    
    var currentMonth: Date? = nil
    var lastFirstWeekdayLastMonth: Date? = nil

    var onCalendarUpdate: (() -> ())? = nil
    
    override init() {
        super.init()
        
        let languageIdentifier = Locale.preferredLanguages[0]
        locale = Locale.init(identifier: languageIdentifier)
        
        monthFormatter.locale = locale
        monthFormatter.dateFormat = "MMMM yyyy"
        
        weekdays = calendar.veryShortWeekdaySymbols
        daysInWeek = weekdays.count
        
        let maxWeeksInMonth = (calendar.maximumRange(of: .day)?.upperBound)! / daysInWeek
        shownItemCount = daysInWeek * (maxWeeksInMonth + 2 + 1)
        
        calculateDayZero()
        updateCurrentlyShownDays()
    }
    
    private func calculateDayZero() {
        dayZero = Date(timeIntervalSince1970: 86400 * 5)
        let now = Date()
        
        let dayZeroOrdinality = calendar.ordinality(of: .month, in: .era, for: dayZero!)!
        let nowOrdinality = calendar.ordinality(of: .month, in: .era, for: now)!
        
        monthOffset = nowOrdinality - dayZeroOrdinality
    }
    
    private func daysInMonth(month: Date) -> Int {
        return (calendar.range(of: .day, in: .month, for: month)?.count)!
    }
    
    private func getLastFirstWeekday(month: Date) -> Date {
        // zero-based weekday of the date "month"
        let weekday = (daysInWeek + calendar.component(.weekday, from: month) - calendar.firstWeekday) % daysInWeek
        
        // the date of the first day that same week (eg. the monday of that week)
        let d = calendar.ordinality(of: .day, in: .month, for: month)! - weekday
        
        // calculate full weeks left after the day number "d" and add that to d, to get the "last first day of the month"
        let totalDaysInMonth = daysInMonth(month: month)
        let lastFirstWeekdayNumber = (totalDaysInMonth - d) / daysInWeek * daysInWeek + d
        return calendar.date(bySetting: .day, value: lastFirstWeekdayNumber, of: month)!
    }
    
    private func updateCurrentlyShownDays() {
        currentMonth = calendar.date(byAdding: .month, value: monthOffset, to: dayZero!)
        let lastMonth = calendar.date(byAdding: .month, value: Int(-1), to: currentMonth!)!
        lastFirstWeekdayLastMonth = getLastFirstWeekday(month: lastMonth)
    }

    func itemCount() -> Int {
        return shownItemCount
    }
    
    func getItemAt(index: Int) -> Day {
        var day = Day()
        if (index < daysInWeek) {
            day.text = weekdays[(calendar.firstWeekday + index - 1) % daysInWeek]
        } else {
            let dayOffset = index - daysInWeek
            let date = calendar.date(byAdding: .day, value: dayOffset, to: lastFirstWeekdayLastMonth!)!

            let formater = DateFormatter()
            formater.dateFormat = "M-d-yyyy"
            let dateString = formater.string(from: date)
            let isSet = UserDefaults.standard.bool(forKey: "\(dateString)IsSet")
            
            day.hasDiary = isSet
            day.isNumber = true
            day.text = String(calendar.ordinality(of: .day, in: .month, for: date)!)
            day.isCurrentMonth = calendar.isDate(date, equalTo: currentMonth!, toGranularity: .month)
            day.isToday = calendar.isDateInToday(date)
            day.date = date
        }
        return day
    }
    
    func getMonth() -> String {
        return monthFormatter.string(from: currentMonth!)
    }
    
    func incrementMonth() {
        monthOffset += 1
        updateCurrentlyShownDays()
        onCalendarUpdate?()
    }
    
    func decrementMonth() {
        monthOffset -= 1
        updateCurrentlyShownDays()
        onCalendarUpdate?()
    }
    
    func resetMonth() {
        calculateDayZero()
        updateCurrentlyShownDays()
        onCalendarUpdate?()
    }
}
