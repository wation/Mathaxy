//
//  LoginTrackingServiceTests.swift
//  MathaxyTests
//
//  测试登录追踪服务的功能
//  Created on 2026-01-19
//

import XCTest
@testable import Mathaxy

/// 登录追踪服务测试类
final class LoginTrackingServiceTests: XCTestCase {
    
    var trackingService: LoginTrackingService!
    var storageService: StorageService!
    
    override func setUp() {
        super.setUp()
        // 每个测试前初始化服务
        trackingService = LoginTrackingService.shared
        storageService = StorageService.shared
        
        // 清理测试数据
        storageService.clearAll()
    }
    
    override func tearDown() {
        // 清理测试数据
        storageService.clearAll()
        trackingService = nil
        storageService = nil
        super.tearDown()
    }
    
    // MARK: - 登录记录测试
    
    /// 测试记录登录
    func testRecordLogin() {
        // 记录登录
        trackingService.recordLogin()
        
        // 验证登录次数
        let loginCount = trackingService.getLoginCount()
        XCTAssertEqual(loginCount, 1, "登录次数应该为1")
    }
    
    /// 测试多次记录登录
    func testRecordMultipleLogins() {
        // 记录多次登录
        trackingService.recordLogin()
        trackingService.recordLogin()
        trackingService.recordLogin()
        
        // 验证登录次数
        let loginCount = trackingService.getLoginCount()
        XCTAssertEqual(loginCount, 3, "登录次数应该为3")
    }
    
    /// 测试获取登录次数
    func testGetLoginCount() {
        // 初始登录次数应为0
        var loginCount = trackingService.getLoginCount()
        XCTAssertEqual(loginCount, 0, "初始登录次数应该为0")
        
        // 记录登录后
        trackingService.recordLogin()
        loginCount = trackingService.getLoginCount()
        XCTAssertEqual(loginCount, 1, "登录次数应该为1")
    }
    
    // MARK: - 连续登录天数测试
    
    /// 测试记录连续登录
    func testRecordConsecutiveLogin() {
        // 记录第一天登录
        trackingService.recordLogin()
        
        // 验证连续登录天数
        var consecutiveDays = trackingService.getConsecutiveDays()
        XCTAssertEqual(consecutiveDays, 1, "连续登录天数应该为1")
    }
    
    /// 测试连续多天登录
    func testRecordMultipleConsecutiveLogins() {
        // 模拟连续3天登录
        for day in 1...3 {
            // 设置登录日期为day天前
            let loginDate = Calendar.current.date(byAdding: .day, value: -day, to: Date())!
            trackingService.recordLogin(at: loginDate)
        }
        
        // 记录今天登录
        trackingService.recordLogin()
        
        // 验证连续登录天数
        let consecutiveDays = trackingService.getConsecutiveDays()
        XCTAssertGreaterThan(consecutiveDays, 0, "连续登录天数应该大于0")
    }
    
    /// 测试获取连续登录天数
    func testGetConsecutiveDays() {
        // 初始连续登录天数应为0
        var consecutiveDays = trackingService.getConsecutiveDays()
        XCTAssertEqual(consecutiveDays, 0, "初始连续登录天数应该为0")
        
        // 记录登录
        trackingService.recordLogin()
        
        consecutiveDays = trackingService.getConsecutiveDays()
        XCTAssertEqual(consecutiveDays, 1, "连续登录天数应该为1")
    }
    
    /// 测试中断连续登录
    func testBreakConsecutiveLogin() {
        // 记录登录
        trackingService.recordLogin()
        
        // 验证连续登录天数
        var consecutiveDays = trackingService.getConsecutiveDays()
        XCTAssertEqual(consecutiveDays, 1, "连续登录天数应该为1")
        
        // 模拟中断（设置上次登录日期为3天前）
        let oldLoginDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        trackingService.recordLogin(at: oldLoginDate)
        
        // 记录新登录
        trackingService.recordLogin()
        
        // 验证连续登录天数被重置
        consecutiveDays = trackingService.getConsecutiveDays()
        XCTAssertEqual(consecutiveDays, 1, "中断后连续登录天数应该重置为1")
    }
    
    // MARK: - 最后登录时间测试
    
    /// 测试记录最后登录时间
    func testLastLoginTime() {
        let beforeTime = Date()
        
        // 记录登录
        trackingService.recordLogin()
        
        let afterTime = Date()
        
        // 获取最后登录时间
        let lastLoginTime = trackingService.getLastLoginTime()
        
        // 验证最后登录时间在合理范围内
        XCTAssertNotNil(lastLoginTime, "最后登录时间不应为nil")
        XCTAssertGreaterThanOrEqual(lastLoginTime!, beforeTime, "最后登录时间应该在记录时间之后")
        XCTAssertLessThanOrEqual(lastLoginTime!, afterTime, "最后登录时间应该在当前时间之前")
    }
    
    /// 测试获取最后登录时间
    func testGetLastLoginTime() {
        // 初始最后登录时间应为nil
        var lastLoginTime = trackingService.getLastLoginTime()
        XCTAssertNil(lastLoginTime, "初始最后登录时间应该为nil")
        
        // 记录登录
        trackingService.recordLogin()
        
        // 验证最后登录时间存在
        lastLoginTime = trackingService.getLastLoginTime()
        XCTAssertNotNil(lastLoginTime, "记录登录后最后登录时间不应为nil")
    }
    
    // MARK: - 7天连续登录奖励测试
    
    /// 测试检查7天连续登录奖励
    func testCheckSevenDayReward() {
        // 初始不应获得奖励
        var hasReward = trackingService.hasEarnedSevenDayReward()
        XCTAssertFalse(hasReward, "初始不应获得7天连续登录奖励")
        
        // 模拟7天连续登录
        for day in 1...7 {
            let loginDate = Calendar.current.date(byAdding: .day, value: -day, to: Date())!
            trackingService.recordLogin(at: loginDate)
        }
        trackingService.recordLogin()
        
        // 验证获得奖励
        hasReward = trackingService.hasEarnedSevenDayReward()
        XCTAssertTrue(hasReward, "7天连续登录应该获得奖励")
    }
    
    /// 测试标记7天连续登录奖励已领取
    func testMarkSevenDayRewardClaimed() {
        // 模拟7天连续登录
        for day in 1...7 {
            let loginDate = Calendar.current.date(byAdding: .day, value: -day, to: Date())!
            trackingService.recordLogin(at: loginDate)
        }
        trackingService.recordLogin()
        
        // 验证可以领取奖励
        var canClaim = trackingService.hasEarnedSevenDayReward()
        XCTAssertTrue(canClaim, "应该可以领取7天连续登录奖励")
        
        // 标记奖励已领取
        trackingService.markSevenDayRewardClaimed()
        
        // 验证奖励已领取
        canClaim = trackingService.hasEarnedSevenDayReward()
        XCTAssertFalse(canClaim, "奖励已领取后不应再显示可领取")
    }
    
    // MARK: - 登录历史记录测试
    
    /// 测试获取登录历史
    func testGetLoginHistory() {
        // 记录多次登录
        trackingService.recordLogin()
        trackingService.recordLogin()
        trackingService.recordLogin()
        
        // 获取登录历史
        let loginHistory = trackingService.getLoginHistory()
        
        // 验证登录历史
        XCTAssertEqual(loginHistory.count, 3, "登录历史应该有3条记录")
    }
    
    /// 测试登录历史限制
    func testLoginHistoryLimit() {
        // 记录超过限制的登录次数
        for _ in 0..<100 {
            trackingService.recordLogin()
        }
        
        // 获取登录历史
        let loginHistory = trackingService.getLoginHistory()
        
        // 验证登录历史数量在合理范围内（不超过30天）
        XCTAssertLessThanOrEqual(loginHistory.count, 30, "登录历史不应超过30天")
    }
    
    // MARK: - 数据重置测试
    
    /// 测试重置登录数据
    func testResetLoginData() {
        // 记录登录数据
        trackingService.recordLogin()
        trackingService.recordLogin()
        trackingService.recordLogin()
        
        // 验证数据存在
        var loginCount = trackingService.getLoginCount()
        XCTAssertEqual(loginCount, 3, "登录次数应该为3")
        
        // 重置数据
        trackingService.resetLoginData()
        
        // 验证数据已重置
        loginCount = trackingService.getLoginCount()
        XCTAssertEqual(loginCount, 0, "重置后登录次数应该为0")
        
        let consecutiveDays = trackingService.getConsecutiveDays()
        XCTAssertEqual(consecutiveDays, 0, "重置后连续登录天数应该为0")
        
        let lastLoginTime = trackingService.getLastLoginTime()
        XCTAssertNil(lastLoginTime, "重置后最后登录时间应该为nil")
    }
    
    // MARK: - 边界条件测试
    
    /// 测试同一天多次登录
    func testMultipleLoginsSameDay() {
        // 同一天记录多次登录
        trackingService.recordLogin()
        trackingService.recordLogin()
        trackingService.recordLogin()
        
        // 验证登录次数增加
        let loginCount = trackingService.getLoginCount()
        XCTAssertEqual(loginCount, 3, "同一天多次登录应该都记录")
        
        // 验证连续登录天数不重复计算
        let consecutiveDays = trackingService.getConsecutiveDays()
        XCTAssertEqual(consecutiveDays, 1, "同一天多次登录连续天数仍为1")
    }
    
    /// 测试跨年登录
    func testNewYearLogin() {
        // 设置上次登录时间为去年12月31日
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year! -= 1
        components.month = 12
        components.day = 31
        
        if let lastYearDate = calendar.date(from: components) {
            trackingService.recordLogin(at: lastYearDate)
            
            // 记录新年登录
            trackingService.recordLogin()
            
            // 验证连续登录天数
            let consecutiveDays = trackingService.getConsecutiveDays()
            XCTAssertGreaterThan(consecutiveDays, 0, "跨年登录应该能正确计算连续天数")
        }
    }
    
    // MARK: - 性能测试
    
    /// 测试登录记录性能
    func testRecordLoginPerformance() {
        measure {
            for _ in 0..<1000 {
                trackingService.recordLogin()
            }
        }
    }
    
    /// 测试获取登录数据性能
    func testGetLoginDataPerformance() {
        // 预先记录登录
        for _ in 0..<100 {
            trackingService.recordLogin()
        }
        
        measure {
            _ = trackingService.getLoginCount()
            _ = trackingService.getConsecutiveDays()
            _ = trackingService.getLastLoginTime()
            _ = trackingService.getLoginHistory()
        }
    }
}
