//
//  DateHelper.swift
//  Mathaxy
//
//  日期助手
//  提供日期相关的工具方法
//

import Foundation

// MARK: - 日期助手类
class DateHelper {
    
    // MARK: - 单例
    static let shared = DateHelper()
    
    private init() {}
    
    // MARK: - 日期格式化
    
    /// 格式化日期为字符串
    /// - Parameters:
    ///   - date: 日期
    ///   - format: 格式字符串
    /// - Returns: 格式化后的字符串
    func formatDate(_ date: Date, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    /// 格式化日期为相对时间
    /// - Parameter date: 日期
    /// - Returns: 相对时间字符串（如"刚刚"、"5分钟前"）
    func formatRelativeTime(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "刚刚"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)分钟前"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)小时前"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)天前"
        } else {
            return formatDate(date, format: "yyyy-MM-dd")
        }
    }
    
    /// 格式化时间间隔为字符串
    /// - Parameter seconds: 秒数
    /// - Returns: 格式化后的字符串（如"1分30秒"）
    func formatTimeInterval(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d分%d秒", minutes, secs)
    }
    
    /// 格式化时间间隔为详细字符串
    /// - Parameter seconds: 秒数
    /// - Returns: 格式化后的字符串（如"01:30:00"）
    func formatTimeIntervalDetailed(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
    /// 格式化日期为完整中文日期
    /// - Parameter date: 日期
    /// - Returns: 格式化后的字符串（如"2023年5月20日"）
    func formatFullDate(_ date: Date) -> String {
        return formatDate(date, format: "yyyy年MM月dd日")
    }
    
    // MARK: - 日期计算
    
    /// 获取今天的开始时间
    /// - Returns: 今天的开始时间（00:00:00）
    func startOfDay(_ date: Date = Date()) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    /// 获取今天的结束时间
    /// - Returns: 今天的结束时间（23:59:59）
    func endOfDay(_ date: Date = Date()) -> Date {
        let start = startOfDay(date)
        return Calendar.current.date(byAdding: .day, value: 1, to: start)! - 1
    }
    
    /// 获取两个日期之间的天数差
    /// - Parameters:
    ///   - from: 开始日期
    ///   - to: 结束日期
    /// - Returns: 天数差
    func daysBetween(from: Date, to: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startOfDay(from), to: startOfDay(to))
        return components.day ?? 0
    }
    
    /// 获取日期的年份
    /// - Parameter date: 日期
    /// - Returns: 年份
    func year(of date: Date) -> Int {
        return Calendar.current.component(.year, from: date)
    }
    
    /// 检查两个日期是否为同一天
    /// - Parameters:
    ///   - date1: 日期1
    ///   - date2: 日期2
    /// - Returns: 是否为同一天
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    /// 检查日期是否为今天
    /// - Parameter date: 日期
    /// - Returns: 是否为今天
    func isToday(_ date: Date) -> Bool {
        return isSameDay(date, Date())
    }
    
    /// 检查日期是否为昨天
    /// - Parameter date: 日期
    /// - Returns: 是否为昨天
    func isYesterday(_ date: Date) -> Bool {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return isSameDay(date, yesterday)
    }
    
    /// 添加天数到日期
    /// - Parameters:
    ///   - date: 原始日期
    ///   - days: 要添加的天数
    /// - Returns: 新的日期
    func addDays(_ days: Int, to date: Date = Date()) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: date) ?? date
    }
    
    /// 添加小时到日期
    /// - Parameters:
    ///   - date: 原始日期
    ///   - hours: 要添加的小时数
    /// - Returns: 新的日期
    func addHours(_ hours: Int, to date: Date = Date()) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: date) ?? date
    }
    
    /// 添加分钟到日期
    /// - Parameters:
    ///   - date: 原始日期
    ///   - minutes: 要添加的分钟数
    /// - Returns: 新的日期
    func addMinutes(_ minutes: Int, to date: Date = Date()) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: date) ?? date
    }
    
    /// 添加秒到日期
    /// - Parameters:
    ///   - date: 原始日期
    ///   - seconds: 要添加的秒数
    /// - Returns: 新的日期
    func addSeconds(_ seconds: Double, to date: Date = Date()) -> Date {
        return Calendar.current.date(byAdding: .second, value: Int(seconds), to: date) ?? date
    }
    
    // MARK: - 日期组件
    
    /// 获取日期的月份
    /// - Parameter date: 日期
    /// - Returns: 月份（1-12）
    func month(of date: Date) -> Int {
        return Calendar.current.component(.month, from: date)
    }
    
    /// 获取日期的日
    /// - Parameter date: 日期
    /// - Returns: 日（1-31）
    func day(of date: Date) -> Int {
        return Calendar.current.component(.day, from: date)
    }
    
    /// 获取日期的小时
    /// - Parameter date: 日期
    /// - Returns: 小时（0-23）
    func hour(of date: Date) -> Int {
        return Calendar.current.component(.hour, from: date)
    }
    
    /// 获取日期的分钟
    /// - Parameter date: 日期
    /// - Returns: 分钟（0-59）
    func minute(of date: Date) -> Int {
        return Calendar.current.component(.minute, from: date)
    }
    
    /// 获取日期的秒
    /// - Parameter date: 日期
    /// - Returns: 秒（0-59）
    func second(of date: Date) -> Int {
        return Calendar.current.component(.second, from: date)
    }
    
    /// 获取日期的星期几
    /// - Parameter date: 日期
    /// - Returns: 星期几（1-7，1为周日）
    func weekday(of date: Date) -> Int {
        return Calendar.current.component(.weekday, from: date)
    }
    
    // MARK: - 日期比较
    
    /// 比较两个日期
    /// - Parameters:
    ///   - date1: 日期1
    ///   - date2: 日期2
    /// - Returns: 比较结果（-1: date1 < date2, 0: date1 == date2, 1: date1 > date2）
    func compare(_ date1: Date, _ date2: Date) -> ComparisonResult {
        return date1.compare(date2)
    }
    
    /// 检查date1是否在date2之前
    /// - Parameters:
    ///   - date1: 日期1
    ///   - date2: 日期2
    /// - Returns: 是否在之前
    func isBefore(_ date1: Date, _ date2: Date) -> Bool {
        return date1 < date2
    }
    
    /// 检查date1是否在date2之后
    /// - Parameters:
    ///   - date1: 日期1
    ///   - date2: 日期2
    /// - Returns: 是否在之后
    func isAfter(_ date1: Date, _ date2: Date) -> Bool {
        return date1 > date2
    }
}

// MARK: - 日期扩展
extension Date {
    
    /// 格式化为字符串
    /// - Parameter format: 格式字符串
    /// - Returns: 格式化后的字符串
    func formatted(_ format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        return DateHelper.shared.formatDate(self, format: format)
    }
    
    /// 格式化为相对时间
    /// - Returns: 相对时间字符串
    var relativeFormatted: String {
        return DateHelper.shared.formatRelativeTime(self)
    }
    
    /// 是否为今天
    var isToday: Bool {
        return DateHelper.shared.isToday(self)
    }
    
    /// 是否为昨天
    var isYesterday: Bool {
        return DateHelper.shared.isYesterday(self)
    }
    
    /// 添加天数
    /// - Parameter days: 天数
    /// - Returns: 新的日期
    func addingDays(_ days: Int) -> Date {
        return DateHelper.shared.addDays(days, to: self)
    }
    
    /// 添加小时
    /// - Parameter hours: 小时数
    /// - Returns: 新的日期
    func addingHours(_ hours: Int) -> Date {
        return DateHelper.shared.addHours(hours, to: self)
    }
    
    /// 添加分钟
    /// - Parameter minutes: 分钟数
    /// - Returns: 新的日期
    func addingMinutes(_ minutes: Int) -> Date {
        return DateHelper.shared.addMinutes(minutes, to: self)
    }
    
    /// 添加秒
    /// - Parameter seconds: 秒数
    /// - Returns: 新的日期
    func addingSeconds(_ seconds: Double) -> Date {
        return DateHelper.shared.addSeconds(seconds, to: self)
    }
}
