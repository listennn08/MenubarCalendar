//
//  DateModel.swift
//  MenubarCalendar
//
//  Created by listennn on 2021/9/25.
//

import Foundation

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}

/// date object
struct CalendarItem: Hashable {
    var date: String
    var isCurrentDate: Bool
    var isCurrentMonth: Bool
    
    init(date: String, isCurrentDate: Bool, isCurrentMonth: Bool) {
        self.date = date
        self.isCurrentDate = isCurrentDate
        self.isCurrentMonth = isCurrentMonth
    }
}

/// date model
class DateModel: ObservableObject {
    @Published var currentDate: Date = Date()
    @Published var today: Date = Date()
    @Published var weeks: [String] = ["sun", "mon", "tue", "wed", "thr", "fri", "sat"]
    @Published var year: String = ""
    @Published var month: String = ""
    @Published var day: String = ""
    @Published var weekday: String = ""
    @Published var hour: String = ""
    @Published var minute: String = ""
    @Published var formattedToday: String = ""
    @Published var calendarList: [CalendarItem] = []
    @Published var locale: String = ""
    

    init() {
        if let language = Locale.current.languageCode {
            locale = Locale.current.localizedString(forLanguageCode: language) ?? ""
        }

        self.today = Date()
        self.currentDate = Date()
        self.getCurrentData()
    }
    
//    func createTimer() {
//        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.setDate), userInfo: nil, repeats: true)
//    }
    
    @objc func setDate() {
        self.today = Date()
        self.formattedToday = self.setFormattedTody()
    }

    private func getCurrentData() {
        self.year = self.getCurrentDate(type: "y")
        self.month = self.getCurrentDate(type: "m")
        self.day = self.getCurrentDate(type: "d")
        self.calendarList = self.setCalendarList()
        self.formattedToday = self.setFormattedTody()
    }

    /// Set current date list
    /// - Returns: Date list
    private func setCalendarList() -> [CalendarItem] {
        var _calendarList: [[CalendarItem]] = []
        var _weekList: [CalendarItem] = []
        
        let start = Calendar.current.dateComponents(in: TimeZone.current, from: self.currentDate.startOfMonth())
        let end = Calendar.current.dateComponents(in: TimeZone.current, from: self.currentDate.endOfMonth())
        
        let today = Calendar.current.dateComponents(in: TimeZone.current, from: self.today)
        let startWeekDay = start.weekday!

        for item in start.day! ..< end.day! + 1 {
            if item == 1 {
                let prevMonth = Calendar.current.date(byAdding: DateComponents(month: 0, day: -1), to: self.currentDate.startOfMonth())
                let prevMonthComp = Calendar.current.dateComponents(in: TimeZone.current, from: prevMonth!)

                // add previous date to fill columns
                if (startWeekDay - 1 > 0) {
                    _weekList = (0...startWeekDay - 2).map({
                        CalendarItem(date: String(prevMonthComp.day! - $0), isCurrentDate: false, isCurrentMonth: false)
                    }).reversed()
                }

                _weekList.append(
                    CalendarItem(
                        date: String(format: "%02d", item),
                        isCurrentDate: item == today.day! && end.month! == today.month!,
                        isCurrentMonth: true
                    )
                )
                
                if (_weekList.count == 7) {
                    _calendarList.append(_weekList)
                    _weekList = []
                }

                continue
            }
            
            _weekList.append(
                CalendarItem(
                    date: String(format: "%02d", item),
                    isCurrentDate: item == today.day! && end.month! == today.month!,
                    isCurrentMonth: true
                )
            )
            if _weekList.count == 7 {
                _calendarList.append(_weekList)
                _weekList = []
            }
            
            if item == end.day! {
                // add next month date to fill columns
                _weekList += Array(1...7 - _weekList.count).map({
                    CalendarItem(date: String(format: "%02d", $0), isCurrentDate: false, isCurrentMonth: false)
                })
                _calendarList.append(_weekList)
            }
        }

        return _calendarList.flatMap{ $0 }
    }
    
    /// Get current formatted date
    /// - Parameter type: formatedt type
    /// - Returns: Formatted date
    func getCurrentDate(type: String) -> String {
        let _dateFormatter = DateFormatter()
        switch type {
        case "y":
            _dateFormatter.dateFormat = "y"
            break
        case "m":
            _dateFormatter.dateFormat = "MMMM"
            break
        case "d":
            _dateFormatter.dateFormat = "dd"
        default:
            return ""
        }

        return type == "m"
            ? String(_dateFormatter.string(from: self.currentDate).prefix(3))
            : _dateFormatter.string(from: self.currentDate)
    }
    
    /// Move to today
    internal func goToToday() {
        self.currentDate = self.today
        self.getCurrentData()
    }

    /// Move to previous month
    internal func minusMonth() {
        self.currentDate = Calendar.current.date(byAdding: DateComponents(month: -1), to: self.currentDate)!
        self.getCurrentData()
    }

    /// Move to next month
    internal func addMonth() {
        self.currentDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: self.currentDate)!
        self.getCurrentData()

    }
    
    internal func setFormattedTody() -> String {
        let formatter = DateFormatter()
        var formatDateString: String
        switch self.locale {
        case "zh_Hant_TW":
            formatDateString = "MMMdd日 EEE"
        default:
            formatDateString = "YYYY/MM/dd EEE"
        }
        let formatTimeString = "HH:mm:ss"
        formatter.locale =  Locale(identifier: self.locale)

        formatter.dateFormat = "\(formatDateString) \(formatTimeString)"
        return formatter.string(from: self.today)
    }
}
