//
//  LoginFlowUITests.swift
//  MathaxyUITests
//
//  测试登录流程的UI交互
//  Created on 2026-01-19
//

import XCTest
@testable import Mathaxy

/// 登录流程UI测试类
final class LoginFlowUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // 初始化应用
        app = XCUIApplication()
        
        // 每个测试前启动应用
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        // 等待应用启动
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5.0), "应用应该成功启动")
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - 游客登录流程测试
    
    /// 测试游客登录流程
    func testGuestLoginFlow() {
        // 验证登录页面显示
        XCTAssertTrue(app.otherElements["LoginView"].exists, "应该显示登录页面")
        
        // 查找并点击游客登录按钮
        let guestLoginButton = app.buttons["guest_login_button"]
        XCTAssertTrue(guestLoginButton.exists, "游客登录按钮应该存在")
        XCTAssertTrue(guestLoginButton.isEnabled, "游客登录按钮应该可点击")
        
        guestLoginButton.tap()
        
        // 等待昵称输入页面显示
        let nicknameTextField = app.textFields["nickname_text_field"]
        XCTAssertTrue(nicknameTextField.waitForExistence(timeout: 5.0), "昵称输入框应该显示")
        
        // 输入昵称
        let testNickname = "测试用户\(Int.random(in: 1000...9999))"
        nicknameTextField.tap()
        nicknameTextField.typeText(testNickname)
        
        // 查找并点击确认按钮
        let confirmButton = app.buttons["confirm_button"]
        XCTAssertTrue(confirmButton.exists, "确认按钮应该存在")
        confirmButton.tap()
        
        // 验证跳转到首页
        XCTAssertTrue(app.otherElements["HomeView"].waitForExistence(timeout: 5.0), "应该跳转到首页")
    }
    
    /// 测试昵称验证
    func testNicknameValidation() {
        // 进入昵称输入页面
        let guestLoginButton = app.buttons["guest_login_button"]
        guestLoginButton.tap()
        
        let nicknameTextField = app.textFields["nickname_text_field"]
        nicknameTextField.tap()
        
        // 测试空昵称
        nicknameTextField.typeText("")
        let confirmButton = app.buttons["confirm_button"]
        confirmButton.tap()
        
        // 验证错误提示
        let errorMessage = app.staticTexts["error_message"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 2.0), "应该显示错误提示")
        
        // 测试过短昵称
        nicknameTextField.tap()
        nicknameTextField.typeText("测")
        confirmButton.tap()
        
        // 验证错误提示
        XCTAssertTrue(errorMessage.exists, "应该显示昵称过短的错误提示")
        
        // 测试过长昵称
        nicknameTextField.clearText()
        let longNickname = String(repeating: "测", count: 51)
        nicknameTextField.typeText(longNickname)
        confirmButton.tap()
        
        // 验证错误提示
        XCTAssertTrue(errorMessage.exists, "应该显示昵称过长的错误提示")
        
        // 测试有效昵称
        nicknameTextField.clearText()
        nicknameTextField.typeText("有效昵称")
        confirmButton.tap()
        
        // 验证成功跳转
        XCTAssertTrue(app.otherElements["HomeView"].waitForExistence(timeout: 5.0), "应该跳转到首页")
    }
    
    // MARK: - 家长辅助绑定流程测试
    
    /// 测试家长辅助绑定流程
    func testParentBindFlow() {
        // 点击家长辅助绑定按钮
        let parentBindButton = app.buttons["parent_bind_button"]
        XCTAssertTrue(parentBindButton.exists, "家长辅助绑定按钮应该存在")
        parentBindButton.tap()
        
        // 验证家长绑定页面显示
        XCTAssertTrue(app.otherElements["ParentBindView"].waitForExistence(timeout: 5.0), "应该显示家长绑定页面")
        
        // 输入家长邮箱
        let emailTextField = app.textFields["parent_email_text_field"]
        XCTAssertTrue(emailTextField.exists, "家长邮箱输入框应该存在")
        emailTextField.tap()
        emailTextField.typeText("parent@example.com")
        
        // 输入确认邮箱
        let confirmEmailTextField = app.textFields["confirm_email_text_field"]
        XCTAssertTrue(confirmEmailTextField.exists, "确认邮箱输入框应该存在")
        confirmEmailTextField.tap()
        confirmEmailTextField.typeText("parent@example.com")
        
        // 点击绑定按钮
        let bindButton = app.buttons["bind_button"]
        XCTAssertTrue(bindButton.exists, "绑定按钮应该存在")
        bindButton.tap()
        
        // 验证成功提示
        let successMessage = app.staticTexts["success_message"]
        XCTAssertTrue(successMessage.waitForExistence(timeout: 5.0), "应该显示绑定成功提示")
    }
    
    /// 测试邮箱验证
    func testEmailValidation() {
        // 进入家长绑定页面
        let parentBindButton = app.buttons["parent_bind_button"]
        parentBindButton.tap()
        
        let emailTextField = app.textFields["parent_email_text_field"]
        let confirmEmailTextField = app.textFields["confirm_email_text_field"]
        let bindButton = app.buttons["bind_button"]
        
        // 测试空邮箱
        emailTextField.tap()
        emailTextField.typeText("")
        bindButton.tap()
        
        let errorMessage = app.staticTexts["error_message"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 2.0), "应该显示错误提示")
        
        // 测试无效邮箱格式
        emailTextField.clearText()
        emailTextField.typeText("invalid_email")
        bindButton.tap()
        
        XCTAssertTrue(errorMessage.exists, "应该显示邮箱格式错误的提示")
        
        // 测试邮箱不匹配
        emailTextField.clearText()
        emailTextField.typeText("parent1@example.com")
        confirmEmailTextField.tap()
        confirmEmailTextField.typeText("parent2@example.com")
        bindButton.tap()
        
        XCTAssertTrue(errorMessage.exists, "应该显示邮箱不匹配的提示")
        
        // 测试有效邮箱
        emailTextField.clearText()
        emailTextField.typeText("parent@example.com")
        confirmEmailTextField.clearText()
        confirmEmailTextField.typeText("parent@example.com")
        bindButton.tap()
        
        // 验证成功
        let successMessage = app.staticTexts["success_message"]
        XCTAssertTrue(successMessage.waitForExistence(timeout: 5.0), "应该显示绑定成功提示")
    }
    
    // MARK: - 错误处理测试
    
    /// 测试网络错误处理
    func testNetworkErrorHandling() {
        // 模拟网络错误
        app.launchArguments += ["MOCK_NETWORK_ERROR"]
        app.terminate()
        app.launch()
        
        // 尝试登录
        let guestLoginButton = app.buttons["guest_login_button"]
        guestLoginButton.tap()
        
        let nicknameTextField = app.textFields["nickname_text_field"]
        nicknameTextField.tap()
        nicknameTextField.typeText("测试用户")
        
        let confirmButton = app.buttons["confirm_button"]
        confirmButton.tap()
        
        // 验证错误提示
        let networkErrorAlert = app.alerts["network_error_alert"]
        XCTAssertTrue(networkErrorAlert.waitForExistence(timeout: 5.0), "应该显示网络错误提示")
        
        // 点击重试按钮
        let retryButton = networkErrorAlert.buttons["retry_button"]
        XCTAssertTrue(retryButton.exists, "重试按钮应该存在")
        retryButton.tap()
    }
    
    // MARK: - UI元素可访问性测试
    
    /// 测试登录页面的可访问性
    func testLoginViewAccessibility() {
        // 验证所有重要UI元素都有可访问性标识
        let guestLoginButton = app.buttons["guest_login_button"]
        XCTAssertTrue(guestLoginButton.exists, "游客登录按钮应该存在")
        
        let parentBindButton = app.buttons["parent_bind_button"]
        XCTAssertTrue(parentBindButton.exists, "家长绑定按钮应该存在")
        
        let titleLabel = app.staticTexts["login_title_label"]
        XCTAssertTrue(titleLabel.exists, "登录标题应该存在")
        
        let descriptionLabel = app.staticTexts["login_description_label"]
        XCTAssertTrue(descriptionLabel.exists, "登录描述应该存在")
    }
    
    /// 测试昵称输入页面的可访问性
    func testNicknameInputViewAccessibility() {
        // 进入昵称输入页面
        let guestLoginButton = app.buttons["guest_login_button"]
        guestLoginButton.tap()
        
        // 验证UI元素
        let nicknameTextField = app.textFields["nickname_text_field"]
        XCTAssertTrue(nicknameTextField.exists, "昵称输入框应该存在")
        
        let confirmButton = app.buttons["confirm_button"]
        XCTAssertTrue(confirmButton.exists, "确认按钮应该存在")
        
        let cancelButton = app.buttons["cancel_button"]
        XCTAssertTrue(cancelButton.exists, "取消按钮应该存在")
        
        let instructionLabel = app.staticTexts["nickname_instruction_label"]
        XCTAssertTrue(instructionLabel.exists, "昵称输入说明应该存在")
    }
    
    // MARK: - 性能测试
    
    /// 测试登录流程性能
    func testLoginFlowPerformance() {
        measure {
            // 完整登录流程
            let guestLoginButton = app.buttons["guest_login_button"]
            guestLoginButton.tap()
            
            let nicknameTextField = app.textFields["nickname_text_field"]
            nicknameTextField.tap()
            nicknameTextField.typeText("性能测试")
            
            let confirmButton = app.buttons["confirm_button"]
            confirmButton.tap()
            
            // 等待跳转完成
            _ = app.otherElements["HomeView"].waitForExistence(timeout: 5.0)
            
            // 重置应用
            app.terminate()
            app.launch()
        }
    }
}

// MARK: - XCUIElement Extension
extension XCUIElement {
    /// 清除文本框内容
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
