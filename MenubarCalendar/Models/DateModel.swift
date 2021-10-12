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

/// 日期物件
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

/// 日期資料模型
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

    /// 建構子
    init() {
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

    /// 設定當月日期清單
    /// - Returns: 日期清單
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

                if (startWeekDay - 2 > 0) {
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
                _weekList += Array(1...7 - _weekList.count).map({
                    CalendarItem(date: String(format: "%02d", $0), isCurrentDate: false, isCurrentMonth: false)
                })
                _calendarList.append(_weekList)
            }
        }

        return _calendarList.flatMap{ $0 }
    }
    
    /// 取得現在日期格式化
    /// - Parameter type: 格式化類型
    /// - Returns: 已格式化日期
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
    
    /// 移動日期到今天
    internal func goToToday() {
        self.currentDate = self.today
        self.getCurrentData()
    }

    /// 減少月份
    internal func minusMonth() {
        self.currentDate = Calendar.current.date(byAdding: DateComponents(month: -1), to: self.currentDate)!
        self.getCurrentData()
    }

    /// 增加月份
    internal func addMonth() {
        self.currentDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: self.currentDate)!
        self.getCurrentData()

    }
    
    internal func setFormattedTody() -> String {
        let formatter = DateFormatter()
        formatter.locale =  Locale(identifier: "zh_Hant_TW")
        formatter.dateFormat = "MMMdd日 EEE HH:mm:ss"
        return formatter.string(from: self.today)
    }
}
