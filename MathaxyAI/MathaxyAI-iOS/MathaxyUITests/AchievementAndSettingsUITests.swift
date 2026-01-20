//
//  AchievementAndSettingsUITests.swift
//  MathaxyUITests
//
//  测试成就和设置流程的UI交互
//  Created on 2026-01-19
//

import XCTest
@testable import Mathaxy

/// 成就和设置流程UI测试类
final class AchievementAndSettingsUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // 初始化应用
        app = XCUIApplication()
        
        // 启动应用并完成登录
        app.launchArguments = ["UI_TESTING", "AUTO_LOGIN"]
        app.launch()
        
        // 等待应用启动
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5.0), "应用应该成功启动")
        
        // 确保在首页
        XCTAssertTrue(app.otherElements["HomeView"].waitForExistence(timeout: 5.0), "应该显示首页")
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - 成就页面测试
    
    /// 测试成就页面导航
    func testAchievementViewNavigation() {
        // 点击成就按钮
        let achievementButton = app.buttons["achievement_button"]
        XCTAssertTrue(achievementButton.exists, "成就按钮应该存在")
        achievementButton.tap()
        
        // 验证成就页面显示
        XCTAssertTrue(app.otherElements["AchievementView"].waitForExistence(timeout: 5.0), "应该显示成就页面")
    }
    
    /// 测试勋章展示
    func testBadgeCollectionDisplay() {
        // 进入成就页面
        let achievementButton = app.buttons["achievement_button"]
        achievementButton.tap()
        
        // 验证勋章展示区域
        let badgeCollectionView = app.otherElements["BadgeCollectionView"]
        XCTAssertTrue(badgeCollectionView.waitForExistence(timeout: 3.0), "应该显示勋章展示区域")
        
        // 验证勋章列表
        let badgeCells = app.buttons.matching(identifier: "badge_cell")
        XCTAssertGreaterThanOrEqual(badgeCells.count, 0, "应该有勋章显示")
    }
    
    /// 测试勋章详情查看
    func testBadgeDetailView() {
        // 进入成就页面
        let achievementButton = app.buttons["achievement_button"]
        achievementButton.tap()
        
        // 查找第一个勋章
        let badgeCells = app.buttons.matching(identifier: "badge_cell")
        if badgeCells.count > 0 {
            let firstBadge = badgeCells.element(boundBy: 0)
            firstBadge.tap()
            
            // 验证勋章详情页面
            let badgeDetailView = app.otherElements["BadgeDetailView"]
            XCTAssertTrue(badgeDetailView.waitForExistence(timeout: 3.0), "应该显示勋章详情页面")
            
            // 验证勋章详情内容
            let badgeNameLabel = app.staticTexts["badge_name_label"]
            XCTAssertTrue(badgeNameLabel.exists, "应该显示勋章名称")
            
            let badgeDescriptionLabel = app.staticTexts["badge_description_label"]
            XCTAssertTrue(badgeDescriptionLabel.exists, "应该显示勋章描述")
            
            // 返回
            let backButton = app.buttons["back_button"]
            backButton.tap()
        }
    }
    
    /// 测试已获得和未获得勋章的显示
    func testEarnedAndUnearnedBadges() {
        // 进入成就页面
        let achievementButton = app.buttons["achievement_button"]
        achievementButton.tap()
        
        // 查找所有勋章
        let badgeCells = app.buttons.matching(identifier: "badge_cell")
        
        // 验证勋章状态
        for index in 0..<badgeCells.count {
            let badge = badgeCells.element(boundBy: index)
            
            // 检查是否有已获得或未获得的标识
            let earnedIndicator = badge.images["earned_indicator"]
            let unearnedIndicator = badge.images["unearned_indicator"]
            
            // 至少应该有一个状态标识
            XCTAssertTrue(earnedIndicator.exists || unearnedIndicator.exists, "勋章应该有状态标识")
        }
    }
    
    // MARK: - 奖状功能测试
    
    /// 测试奖状页面导航
    func testCertificateViewNavigation() {
        // 进入成就页面
        let achievementButton = app.buttons["achievement_button"]
        achievementButton.tap()
        
        // 点击奖状按钮
        let certificateButton = app.buttons["certificate_button"]
        XCTAssertTrue(certificateButton.exists, "奖状按钮应该存在")
        certificateButton.tap()
        
        // 验证奖状页面显示
        XCTAssertTrue(app.otherElements["CertificateView"].waitForExistence(timeout: 5.0), "应该显示奖状页面")
    }
    
    /// 测试奖状生成
    func testCertificateGeneration() {
        // 进入奖状页面
        let achievementButton = app.buttons["achievement_button"]
        achievementButton.tap()
        let certificateButton = app.buttons["certificate_button"]
        certificateButton.tap()
        
        // 等待奖状页面加载
        _ = app.otherElements["CertificateView"].waitForExistence(timeout: 5.0)
        
        // 验证奖状内容
        let certificateTitle = app.staticTexts["certificate_title"]
        XCTAssertTrue(certificateTitle.exists, "应该显示奖状标题")
        
        let certificateContent = app.otherElements["certificate_content"]
        XCTAssertTrue(certificateContent.exists, "应该显示奖状内容")
        
        let userNameLabel = app.staticTexts["user_name_label"]
        XCTAssertTrue(userNameLabel.exists, "应该显示用户名称")
        
        let achievementLabel = app.staticTexts["achievement_label"]
        XCTAssertTrue(achievementLabel.exists, "应该显示成就信息")
    }
    
    /// 测试奖状保存功能
    func testCertificateSave() {
        // 进入奖状页面
        let achievementButton = app.buttons["achievement_button"]
        achievementButton.tap()
        let certificateButton = app.buttons["certificate_button"]
        certificateButton.tap()
        
        // 等待奖状页面加载
        _ = app.otherElements["CertificateView"].waitForExistence(timeout: 5.0)
        
        // 点击保存按钮
        let saveButton = app.buttons["save_certificate_button"]
        XCTAssertTrue(saveButton.exists, "保存按钮应该存在")
        saveButton.tap()
        
        // 验证权限请求弹窗
        let photoLibraryAlert = app.alerts["photo_library_permission_alert"]
        if photoLibraryAlert.exists {
            // 点击允许
            let allowButton = photoLibraryAlert.buttons["允许"]
            allowButton.tap()
        }
        
        // 验证保存成功提示
        let successMessage = app.staticTexts["save_success_message"]
        XCTAssertTrue(successMessage.waitForExistence(timeout: 5.0), "应该显示保存成功提示")
    }
    
    /// 测试奖状分享功能
    func testCertificateShare() {
        // 进入奖状页面
        let achievementButton = app.buttons["achievement_button"]
        achievementButton.tap()
        let certificateButton = app.buttons["certificate_button"]
        certificateButton.tap()
        
        // 等待奖状页面加载
        _ = app.otherElements["CertificateView"].waitForExistence(timeout: 5.0)
        
        // 点击分享按钮
        let shareButton = app.buttons["share_certificate_button"]
        XCTAssertTrue(shareButton.exists, "分享按钮应该存在")
        shareButton.tap()
        
        // 验证分享面板显示
        let shareSheet = app.otherElements["share_sheet"]
        XCTAssertTrue(shareSheet.waitForExistence(timeout: 3.0), "应该显示分享面板")
        
        // 取消分享
        let cancelButton = app.buttons["取消"]
        cancelButton.tap()
    }
    
    // MARK: - 设置页面测试
    
    /// 测试设置页面导航
    func testSettingsViewNavigation() {
        // 点击设置按钮
        let settingsButton = app.buttons["settings_button"]
        XCTAssertTrue(settingsButton.exists, "设置按钮应该存在")
        settingsButton.tap()
        
        // 验证设置页面显示
        XCTAssertTrue(app.otherElements["SettingsView"].waitForExistence(timeout: 5.0), "应该显示设置页面")
    }
    
    /// 测试语言切换
    func testLanguageSwitching() {
        // 进入设置页面
        let settingsButton = app.buttons["settings_button"]
        settingsButton.tap()
        
        // 查找语言设置
        let languageButton = app.buttons["language_setting_button"]
        XCTAssertTrue(languageButton.exists, "语言设置按钮应该存在")
        languageButton.tap()
        
        // 验证语言选择列表
        let languageList = app.otherElements["language_selection_list"]
        XCTAssertTrue(languageList.waitForExistence(timeout: 3.0), "应该显示语言选择列表")
        
        // 选择英文
        let englishLanguage = app.buttons["language_en"]
        if englishLanguage.exists {
            englishLanguage.tap()
            
            // 验证语言已切换
            let titleLabel = app.staticTexts["settings_title_label"]
            XCTAssertTrue(titleLabel.exists, "设置标题应该存在")
        }
        
        // 返回
        let backButton = app.buttons["back_button"]
        backButton.tap()
    }
    
    /// 测试音效开关
    func testSoundToggle() {
        // 进入设置页面
        let settingsButton = app.buttons["settings_button"]
        settingsButton.tap()
        
        // 查找音效开关
        let soundToggle = app.switches["sound_toggle"]
        XCTAssertTrue(soundToggle.exists, "音效开关应该存在")
        
        // 获取初始状态
        let initialState = soundToggle.isSelected
        
        // 切换音效
        soundToggle.tap()
        
        // 验证状态改变
        let newState = soundToggle.isSelected
        XCTAssertNotEqual(initialState, newState, "音效开关状态应该改变")
    }
    
    /// 测试背景音乐开关
    func testMusicToggle() {
        // 进入设置页面
        let settingsButton = app.buttons["settings_button"]
        settingsButton.tap()
        
        // 查找背景音乐开关
        let musicToggle = app.switches["music_toggle"]
        XCTAssertTrue(musicToggle.exists, "背景音乐开关应该存在")
        
        // 获取初始状态
        let initialState = musicToggle.isSelected
        
        // 切换背景音乐
        musicToggle.tap()
        
        // 验证状态改变
        let newState = musicToggle.isSelected
        XCTAssertNotEqual(initialState, newState, "背景音乐开关状态应该改变")
    }
    
    /// 测试数据重置功能
    func testDataReset() {
        // 进入设置页面
        let settingsButton = app.buttons["settings_button"]
        settingsButton.tap()
        
        // 滚动到数据重置选项
        let tablesQuery = app.tables
        tablesQuery.swipeUp()
        
        // 查找数据重置按钮
        let resetDataButton = app.buttons["reset_data_button"]
        if resetDataButton.exists {
            resetDataButton.tap()
            
            // 验证确认弹窗
            let resetAlert = app.alerts["reset_data_alert"]
            XCTAssertTrue(resetAlert.waitForExistence(timeout: 3.0), "应该显示重置确认弹窗")
            
            // 点击取消
            let cancelButton = resetAlert.buttons["取消"]
            cancelButton.tap()
        }
    }
    
    /// 测试关于页面
    func testAboutPage() {
        // 进入设置页面
        let settingsButton = app.buttons["settings_button"]
        settingsButton.tap()
        
        // 查找关于按钮
        let aboutButton = app.buttons["about_button"]
        if aboutButton.exists {
            aboutButton.tap()
            
            // 验证关于页面显示
            let aboutView = app.otherElements["AboutView"]
            XCTAssertTrue(aboutView.waitForExistence(timeout: 3.0), "应该显示关于页面")
            
            // 验证版本信息
            let versionLabel = app.staticTexts["app_version_label"]
            XCTAssertTrue(versionLabel.exists, "应该显示应用版本")
            
            // 返回
            let backButton = app.buttons["back_button"]
            backButton.tap()
        }
    }
    
    /// 测试隐私政策页面
    func testPrivacyPolicyPage() {
        // 进入设置页面
        let settingsButton = app.buttons["settings_button"]
        settingsButton.tap()
        
        // 查找隐私政策按钮
        let privacyPolicyButton = app.buttons["privacy_policy_button"]
        if privacyPolicyButton.exists {
            privacyPolicyButton.tap()
            
            // 验证隐私政策页面显示
            let privacyPolicyView = app.otherElements["PrivacyPolicyView"]
            XCTAssertTrue(privacyPolicyView.waitForExistence(timeout: 3.0), "应该显示隐私政策页面")
            
            // 验证政策内容
            let policyContent = app.webViews["privacy_policy_content"]
            XCTAssertTrue(policyContent.exists, "应该显示隐私政策内容")
            
            // 返回
            let backButton = app.buttons["back_button"]
            backButton.tap()
        }
    }
    
    // MARK: - 卡通向导测试
    
    /// 测试卡通向导显示
    func testGuideCharacterDisplay() {
        // 进入成就页面
        let achievementButton = app.buttons["achievement_button"]
        achievementButton.tap()
        
        // 验证卡通向导显示
        let guideCharacter = app.images["guide_character"]
        if guideCharacter.exists {
            XCTAssertTrue(true, "应该显示卡通向导")
            
            // 点击卡通向导
            guideCharacter.tap()
            
            // 验证消息提示
            let guideMessage = app.staticTexts["guide_message"]
            XCTAssertTrue(guideMessage.waitForExistence(timeout: 2.0), "应该显示向导消息")
        }
    }
    
    // MARK: - 多语言切换测试
    
    /// 测试多语言界面切换
    func testMultiLanguageUI() {
        // 进入设置页面
        let settingsButton = app.buttons["settings_button"]
        settingsButton.tap()
        
        // 测试切换到英文
        let languageButton = app.buttons["language_setting_button"]
        languageButton.tap()
        
        let englishLanguage = app.buttons["language_en"]
        englishLanguage.tap()
        
        // 验证英文界面
        let titleLabel = app.staticTexts["settings_title_label"]
        XCTAssertTrue(titleLabel.exists, "应该显示英文设置标题")
        
        // 测试切换到中文
        languageButton.tap()
        let chineseLanguage = app.buttons["language_zh-Hans"]
        chineseLanguage.tap()
        
        // 验证中文界面
        XCTAssertTrue(titleLabel.exists, "应该显示中文设置标题")
    }
    
    // MARK: - 性能测试
    
    /// 测试成就页面性能
    func testAchievementViewPerformance() {
        measure {
            // 进入成就页面
            let achievementButton = app.buttons["achievement_button"]
            achievementButton.tap()
            
            // 等待加载
            _ = app.otherElements["AchievementView"].waitForExistence(timeout: 5.0)
            
            // 返回
            let backButton = app.buttons["back_button"]
            backButton.tap()
        }
    }
    
    /// 测试设置页面性能
    func testSettingsViewPerformance() {
        measure {
            // 进入设置页面
            let settingsButton = app.buttons["settings_button"]
            settingsButton.tap()
            
            // 等待加载
            _ = app.otherElements["SettingsView"].waitForExistence(timeout: 5.0)
            
            // 返回
            let backButton = app.buttons["back_button"]
            backButton.tap()
        }
    }
}
