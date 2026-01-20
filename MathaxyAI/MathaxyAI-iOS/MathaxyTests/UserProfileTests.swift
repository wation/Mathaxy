//
//  UserProfileTests.swift
//  MathaxyTests
//
//  测试用户资料数据模型的功能
//  Created on 2026-01-19
//

import XCTest
@testable import Mathaxy

/// 用户资料测试类
final class UserProfileTests: XCTestCase {
    
    var storageService: StorageService!
    
    override func setUp() {
        super.setUp()
        // 每个测试前初始化存储服务
        storageService = StorageService.shared
        storageService.clearAll()
    }
    
    override func tearDown() {
        storageService.clearAll()
        storageService = nil
        super.tearDown()
    }
    
    // MARK: - 初始化测试
    
    /// 测试用户资料初始化
    func testUserProfileInitialization() {
        let profile = UserProfile(
            id: "test_user_001",
            nickname: "测试用户",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        XCTAssertEqual(profile.id, "test_user_001", "用户ID应该正确")
        XCTAssertEqual(profile.nickname, "测试用户", "用户昵称应该正确")
        XCTAssertTrue(profile.isGuest, "应该是游客账户")
        XCTAssertNil(profile.parentEmail, "游客账户不应该有家长邮箱")
        XCTAssertNotNil(profile.createdAt, "创建时间不应该为nil")
        XCTAssertNotNil(profile.lastLoginDate, "最后登录时间不应该为nil")
    }
    
    /// 测试非游客用户初始化
    func testNonGuestUserProfileInitialization() {
        let profile = UserProfile(
            id: "test_user_002",
            nickname: "正式用户",
            isGuest: false,
            parentEmail: "parent@example.com",
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        XCTAssertEqual(profile.id, "test_user_002", "用户ID应该正确")
        XCTAssertEqual(profile.nickname, "正式用户", "用户昵称应该正确")
        XCTAssertFalse(profile.isGuest, "不应该是游客账户")
        XCTAssertEqual(profile.parentEmail, "parent@example.com", "家长邮箱应该正确")
    }
    
    // MARK: - 数据持久化测试
    
    /// 测试保存和加载用户资料
    func testSaveAndLoadUserProfile() {
        let profile = UserProfile(
            id: "test_user_003",
            nickname: "保存测试",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        // 保存用户资料
        profile.save()
        
        // 加载用户资料
        let loadedProfile = UserProfile.load(userId: "test_user_003")
        
        // 验证数据一致性
        XCTAssertNotNil(loadedProfile, "应该能加载用户资料")
        XCTAssertEqual(loadedProfile?.id, profile.id, "用户ID应该一致")
        XCTAssertEqual(loadedProfile?.nickname, profile.nickname, "用户昵称应该一致")
        XCTAssertEqual(loadedProfile?.isGuest, profile.isGuest, "是否为游客应该一致")
    }
    
    /// 测试加载不存在的用户资料
    func testLoadNonExistentUserProfile() {
        let loadedProfile = UserProfile.load(userId: "non_existent_user")
        XCTAssertNil(loadedProfile, "不应该能加载不存在的用户资料")
    }
    
    // MARK: - 用户资料更新测试
    
    /// 测试更新用户昵称
    func testUpdateNickname() {
        var profile = UserProfile(
            id: "test_user_004",
            nickname: "旧昵称",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        // 保存初始资料
        profile.save()
        
        // 更新昵称
        profile.nickname = "新昵称"
        profile.save()
        
        // 加载并验证
        let loadedProfile = UserProfile.load(userId: "test_user_004")
        XCTAssertEqual(loadedProfile?.nickname, "新昵称", "昵称应该已更新")
    }
    
    /// 测试更新家长邮箱
    func testUpdateParentEmail() {
        var profile = UserProfile(
            id: "test_user_005",
            nickname: "测试用户",
            isGuest: false,
            parentEmail: "old@example.com",
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        // 保存初始资料
        profile.save()
        
        // 更新家长邮箱
        profile.parentEmail = "new@example.com"
        profile.save()
        
        // 加载并验证
        let loadedProfile = UserProfile.load(userId: "test_user_005")
        XCTAssertEqual(loadedProfile?.parentEmail, "new@example.com", "家长邮箱应该已更新")
    }
    
    /// 测试更新最后登录时间
    func testUpdateLastLoginDate() {
        var profile = UserProfile(
            id: "test_user_006",
            nickname: "测试用户",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        // 保存初始资料
        profile.save()
        
        // 等待一秒后更新登录时间
        Thread.sleep(forTimeInterval: 1.0)
        profile.lastLoginDate = Date()
        profile.save()
        
        // 加载并验证
        let loadedProfile = UserProfile.load(userId: "test_user_006")
        XCTAssertNotNil(loadedProfile?.lastLoginDate, "最后登录时间应该存在")
    }
    
    // MARK: - 游戏数据测试
    
    /// 测试更新最高分
    func testUpdateHighScore() {
        var profile = UserProfile(
            id: "test_user_007",
            nickname: "测试用户",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        // 初始最高分
        profile.highScore = 100
        profile.save()
        
        // 加载并验证
        var loadedProfile = UserProfile.load(userId: "test_user_007")
        XCTAssertEqual(loadedProfile?.highScore, 100, "最高分应该为100")
        
        // 更新更高的分数
        loadedProfile?.highScore = 150
        loadedProfile?.save()
        
        // 再次加载验证
        loadedProfile = UserProfile.load(userId: "test_user_007")
        XCTAssertEqual(loadedProfile?.highScore, 150, "最高分应该更新为150")
    }
    
    /// 测试更新关卡进度
    func testUpdateLevelProgress() {
        var profile = UserProfile(
            id: "test_user_008",
            nickname: "测试用户",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        // 初始关卡
        profile.currentLevel = 1
        profile.save()
        
        // 加载并验证
        var loadedProfile = UserProfile.load(userId: "test_user_008")
        XCTAssertEqual(loadedProfile?.currentLevel, 1, "当前关卡应该为1")
        
        // 更新关卡
        loadedProfile?.currentLevel = 3
        loadedProfile?.save()
        
        // 再次加载验证
        loadedProfile = UserProfile.load(userId: "test_user_008")
        XCTAssertEqual(loadedProfile?.currentLevel, 3, "当前关卡应该更新为3")
    }
    
    /// 测试更新总游戏次数
    func testUpdateTotalGamesPlayed() {
        var profile = UserProfile(
            id: "test_user_009",
            nickname: "测试用户",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        // 初始游戏次数
        profile.totalGamesPlayed = 5
        profile.save()
        
        // 加载并验证
        var loadedProfile = UserProfile.load(userId: "test_user_009")
        XCTAssertEqual(loadedProfile?.totalGamesPlayed, 5, "总游戏次数应该为5")
        
        // 增加游戏次数
        loadedProfile?.totalGamesPlayed = 6
        loadedProfile?.save()
        
        // 再次加载验证
        loadedProfile = UserProfile.load(userId: "test_user_009")
        XCTAssertEqual(loadedProfile?.totalGamesPlayed, 6, "总游戏次数应该更新为6")
    }
    
    // MARK: - 勋章数据测试
    
    /// 测试添加获得的勋章
    func testAddEarnedBadge() {
        var profile = UserProfile(
            id: "test_user_010",
            nickname: "测试用户",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        // 添加勋章
        profile.earnedBadges.append("speed_master")
        profile.earnedBadges.append("quiz_genius")
        profile.save()
        
        // 加载并验证
        let loadedProfile = UserProfile.load(userId: "test_user_010")
        XCTAssertEqual(loadedProfile?.earnedBadges.count, 2, "应该有2个勋章")
        XCTAssertTrue(loadedProfile?.earnedBadges.contains("speed_master") ?? false, "应该包含speed_master勋章")
        XCTAssertTrue(loadedProfile?.earnedBadges.contains("quiz_genius") ?? false, "应该包含quiz_genius勋章")
    }
    
    /// 测试检查是否拥有勋章
    func testHasBadge() {
        var profile = UserProfile(
            id: "test_user_011",
            nickname: "测试用户",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        // 初始没有勋章
        XCTAssertFalse(profile.hasBadge("speed_master"), "初始不应该有勋章")
        
        // 添加勋章
        profile.earnedBadges.append("speed_master")
        
        // 验证拥有勋章
        XCTAssertTrue(profile.hasBadge("speed_master"), "应该有speed_master勋章")
        XCTAssertFalse(profile.hasBadge("quiz_genius"), "不应该有quiz_genius勋章")
    }
    
    // MARK: - 数据删除测试
    
    /// 测试删除用户资料
    func testDeleteUserProfile() {
        let profile = UserProfile(
            id: "test_user_012",
            nickname: "待删除用户",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        // 保存用户资料
        profile.save()
        
        // 验证数据存在
        var loadedProfile = UserProfile.load(userId: "test_user_012")
        XCTAssertNotNil(loadedProfile, "用户资料应该存在")
        
        // 删除用户资料
        profile.delete()
        
        // 验证数据已删除
        loadedProfile = UserProfile.load(userId: "test_user_012")
        XCTAssertNil(loadedProfile, "用户资料应该已被删除")
    }
    
    // MARK: - 边界条件测试
    
    /// 测试空昵称
    func testEmptyNickname() {
        let profile = UserProfile(
            id: "test_user_013",
            nickname: "",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        profile.save()
        let loadedProfile = UserProfile.load(userId: "test_user_013")
        XCTAssertEqual(loadedProfile?.nickname, "", "空昵称应该能正确存储")
    }
    
    /// 测试特殊字符昵称
    func testSpecialCharactersNickname() {
        let specialNickname = "测试@#$%^&*()_+-=[]{}|;':\",./<>?"
        let profile = UserProfile(
            id: "test_user_014",
            nickname: specialNickname,
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        profile.save()
        let loadedProfile = UserProfile.load(userId: "test_user_014")
        XCTAssertEqual(loadedProfile?.nickname, specialNickname, "特殊字符昵称应该能正确存储")
    }
    
    /// 测试长昵称
    func testLongNickname() {
        let longNickname = String(repeating: "测", count: 50)
        let profile = UserProfile(
            id: "test_user_015",
            nickname: longNickname,
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        profile.save()
        let loadedProfile = UserProfile.load(userId: "test_user_015")
        XCTAssertEqual(loadedProfile?.nickname, longNickname, "长昵称应该能正确存储")
    }
    
    /// 测试无效邮箱格式
    func testInvalidEmailFormat() {
        let profile = UserProfile(
            id: "test_user_016",
            nickname: "测试用户",
            isGuest: false,
            parentEmail: "invalid_email",
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        profile.save()
        let loadedProfile = UserProfile.load(userId: "test_user_016")
        XCTAssertEqual(loadedProfile?.parentEmail, "invalid_email", "无效邮箱格式应该能正确存储（由上层验证）")
    }
    
    // MARK: - 数据一致性测试
    
    /// 测试多次更新数据的一致性
    func testDataConsistencyAfterMultipleUpdates() {
        var profile = UserProfile(
            id: "test_user_017",
            nickname: "初始昵称",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        // 多次更新
        for i in 1...10 {
            profile.nickname = "昵称\(i)"
            profile.highScore = i * 100
            profile.currentLevel = i
            profile.totalGamesPlayed = i
            profile.save()
        }
        
        // 验证最终数据
        let loadedProfile = UserProfile.load(userId: "test_user_017")
        XCTAssertEqual(loadedProfile?.nickname, "昵称10", "昵称应该是最后一次更新的值")
        XCTAssertEqual(loadedProfile?.highScore, 1000, "最高分应该是最后一次更新的值")
        XCTAssertEqual(loadedProfile?.currentLevel, 10, "当前关卡应该是最后一次更新的值")
        XCTAssertEqual(loadedProfile?.totalGamesPlayed, 10, "总游戏次数应该是最后一次更新的值")
    }
    
    // MARK: - 性能测试
    
    /// 测试用户资料保存和加载性能
    func testUserProfilePerformance() {
        measure {
            for i in 0..<100 {
                let profile = UserProfile(
                    id: "perf_user_\(i)",
                    nickname: "性能测试\(i)",
                    isGuest: true,
                    parentEmail: nil,
                    createdAt: Date(),
                    lastLoginDate: Date()
                )
                profile.save()
                _ = UserProfile.load(userId: "perf_user_\(i)")
            }
        }
    }
}
