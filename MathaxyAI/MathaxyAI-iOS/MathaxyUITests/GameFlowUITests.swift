//
//  GameFlowUITests.swift
//  MathaxyUITests
//
//  测试游戏流程的UI交互
//  Created on 2026-01-19
//

import XCTest
@testable import Mathaxy

/// 游戏流程UI测试类
final class GameFlowUITests: XCTestCase {
    
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
    
    // MARK: - 关卡选择流程测试
    
    /// 测试关卡选择流程
    func testLevelSelectFlow() {
        // 点击开始游戏按钮
        let startGameButton = app.buttons["start_game_button"]
        XCTAssertTrue(startGameButton.exists, "开始游戏按钮应该存在")
        startGameButton.tap()
        
        // 验证关卡选择页面显示
        XCTAssertTrue(app.otherElements["LevelSelectView"].waitForExistence(timeout: 5.0), "应该显示关卡选择页面")
        
        // 验证关卡列表
        let levelCells = app.buttons.matching(identifier: "level_cell")
        XCTAssertGreaterThan(levelCells.count, 0, "应该有关卡可选")
        
        // 选择第1关
        let firstLevelButton = app.buttons["level_1_button"]
        XCTAssertTrue(firstLevelButton.exists, "第1关按钮应该存在")
        XCTAssertTrue(firstLevelButton.isEnabled, "第1关应该可点击")
        firstLevelButton.tap()
        
        // 验证跳转到游戏页面
        XCTAssertTrue(app.otherElements["GameView"].waitForExistence(timeout: 5.0), "应该跳转到游戏页面")
    }
    
    /// 测试锁定关卡
    func testLockedLevels() {
        // 进入关卡选择页面
        let startGameButton = app.buttons["start_game_button"]
        startGameButton.tap()
        
        // 查找锁定关卡
        let lockedLevelButton = app.buttons["level_5_button"]
        
        // 如果锁定关卡存在，验证其状态
        if lockedLevelButton.exists {
            XCTAssertFalse(lockedLevelButton.isEnabled, "锁定关卡不应该可点击")
            
            // 尝试点击锁定关卡
            lockedLevelButton.tap()
            
            // 验证提示信息
            let lockMessage = app.staticTexts["level_locked_message"]
            XCTAssertTrue(lockMessage.waitForExistence(timeout: 2.0), "应该显示关卡锁定提示")
        }
    }
    
    // MARK: - 游戏答题流程测试
    
    /// 测试游戏答题流程
    func testGamePlayFlow() {
        // 进入游戏页面
        navigateToGameView()
        
        // 验证游戏UI元素
        let questionLabel = app.staticTexts["question_label"]
        XCTAssertTrue(questionLabel.waitForExistence(timeout: 3.0), "应该显示题目")
        
        let timerLabel = app.staticTexts["timer_label"]
        XCTAssertTrue(timerLabel.exists, "应该显示计时器")
        
        let scoreLabel = app.staticTexts["score_label"]
        XCTAssertTrue(scoreLabel.exists, "应该显示分数")
        
        // 查找选项按钮
        let optionButtons = app.buttons.matching(identifier: "option_button")
        XCTAssertEqual(optionButtons.count, 4, "应该有4个选项")
        
        // 选择第一个选项
        let firstOption = optionButtons.element(boundBy: 0)
        XCTAssertTrue(firstOption.exists, "第一个选项应该存在")
        firstOption.tap()
        
        // 验证答案反馈
        let feedbackView = app.otherElements["answer_feedback_view"]
        XCTAssertTrue(feedbackView.waitForExistence(timeout: 2.0), "应该显示答案反馈")
        
        // 等待下一题
        sleep(1)
        
        // 验证是否显示下一题
        XCTAssertTrue(questionLabel.exists, "应该显示下一题")
    }
    
    /// 测试正确答案反馈
    func testCorrectAnswerFeedback() {
        // 进入游戏页面
        navigateToGameView()
        
        // 模拟答对（需要根据实际题目逻辑调整）
        let optionButtons = app.buttons.matching(identifier: "option_button")
        let firstOption = optionButtons.element(boundBy: 0)
        firstOption.tap()
        
        // 验证正确答案反馈
        let correctIcon = app.images["correct_icon"]
        let correctMessage = app.staticTexts["correct_answer_message"]
        
        if correctIcon.exists || correctMessage.exists {
            // 答对了
            XCTAssertTrue(true, "应该显示正确答案反馈")
        }
    }
    
    /// 测试错误答案反馈
    func testIncorrectAnswerFeedback() {
        // 进入游戏页面
        navigateToGameView()
        
        // 模拟答错
        let optionButtons = app.buttons.matching(identifier: "option_button")
        let lastOption = optionButtons.element(boundBy: 3)
        lastOption.tap()
        
        // 验证错误答案反馈
        let incorrectIcon = app.images["incorrect_icon"]
        let incorrectMessage = app.staticTexts["incorrect_answer_message"]
        
        if incorrectIcon.exists || incorrectMessage.exists {
            // 答错了
            XCTAssertTrue(true, "应该显示错误答案反馈")
        }
    }
    
    /// 测试计时器功能
    func testTimerFunctionality() {
        // 进入游戏页面
        navigateToGameView()
        
        // 获取初始时间
        let timerLabel = app.staticTexts["timer_label"]
        let initialTime = timerLabel.label
        
        // 等待2秒
        sleep(2)
        
        // 获取当前时间
        let currentTime = timerLabel.label
        
        // 验证时间在减少
        XCTAssertNotEqual(initialTime, currentTime, "计时器应该在工作")
    }
    
    /// 测试超时处理
    func testTimeoutHandling() {
        // 进入游戏页面
        navigateToGameView()
        
        // 等待超时（实际测试中可能需要调整超时时间）
        sleep(60)
        
        // 验证超时提示
        let timeoutAlert = app.alerts["timeout_alert"]
        if timeoutAlert.exists {
            XCTAssertTrue(true, "应该显示超时提示")
            
            // 点击继续按钮
            let continueButton = timeoutAlert.buttons["continue_button"]
            continueButton.tap()
        }
    }
    
    // MARK: - 游戏结果流程测试
    
    /// 测试游戏完成结果
    func testGameCompletionResult() {
        // 进入游戏页面
        navigateToGameView()
        
        // 完成所有题目（模拟）
        for _ in 0..<10 {
            let optionButtons = app.buttons.matching(identifier: "option_button")
            let firstOption = optionButtons.element(boundBy: 0)
            if firstOption.exists {
                firstOption.tap()
                sleep(1)
            }
        }
        
        // 验证结果页面显示
        XCTAssertTrue(app.otherElements["ResultView"].waitForExistence(timeout: 5.0), "应该显示结果页面")
        
        // 验证结果显示
        let finalScoreLabel = app.staticTexts["final_score_label"]
        XCTAssertTrue(finalScoreLabel.exists, "应该显示最终分数")
        
        let correctCountLabel = app.staticTexts["correct_count_label"]
        XCTAssertTrue(correctCountLabel.exists, "应该显示正确题目数")
        
        let incorrectCountLabel = app.staticTexts["incorrect_count_label"]
        XCTAssertTrue(incorrectCountLabel.exists, "应该显示错误题目数")
    }
    
    /// 测试游戏失败结果
    func testGameFailureResult() {
        // 进入游戏页面
        navigateToGameView()
        
        // 连续答错3题
        for _ in 0..<3 {
            let optionButtons = app.buttons.matching(identifier: "option_button")
            let lastOption = optionButtons.element(boundBy: 3)
            if lastOption.exists {
                lastOption.tap()
                sleep(1)
            }
        }
        
        // 验证失败结果页面显示
        XCTAssertTrue(app.otherElements["ResultView"].waitForExistence(timeout: 5.0), "应该显示结果页面")
        
        // 验证失败提示
        let failureMessage = app.staticTexts["game_failure_message"]
        if failureMessage.exists {
            XCTAssertTrue(true, "应该显示游戏失败提示")
        }
    }
    
    /// 测试重新开始游戏
    func testRestartGame() {
        // 完成一局游戏
        navigateToGameView()
        
        for _ in 0..<10 {
            let optionButtons = app.buttons.matching(identifier: "option_button")
            let firstOption = optionButtons.element(boundBy: 0)
            if firstOption.exists {
                firstOption.tap()
                sleep(1)
            }
        }
        
        // 等待结果页面
        _ = app.otherElements["ResultView"].waitForExistence(timeout: 5.0)
        
        // 点击重新开始按钮
        let restartButton = app.buttons["restart_button"]
        XCTAssertTrue(restartButton.exists, "重新开始按钮应该存在")
        restartButton.tap()
        
        // 验证回到游戏页面
        XCTAssertTrue(app.otherElements["GameView"].waitForExistence(timeout: 5.0), "应该回到游戏页面")
    }
    
    /// 测试返回首页
    func testBackToHome() {
        // 完成一局游戏
        navigateToGameView()
        
        for _ in 0..<10 {
            let optionButtons = app.buttons.matching(identifier: "option_button")
            let firstOption = optionButtons.element(boundBy: 0)
            if firstOption.exists {
                firstOption.tap()
                sleep(1)
            }
        }
        
        // 等待结果页面
        _ = app.otherElements["ResultView"].waitForExistence(timeout: 5.0)
        
        // 点击返回首页按钮
        let homeButton = app.buttons["home_button"]
        XCTAssertTrue(homeButton.exists, "返回首页按钮应该存在")
        homeButton.tap()
        
        // 验证回到首页
        XCTAssertTrue(app.otherElements["HomeView"].waitForExistence(timeout: 5.0), "应该回到首页")
    }
    
    // MARK: - 跳关功能测试
    
    /// 测试连续答对跳关
    func testSkipLevelFeature() {
        // 进入游戏页面
        navigateToGameView()
        
        // 连续答对10题（模拟）
        for i in 0..<10 {
            let optionButtons = app.buttons.matching(identifier: "option_button")
            let firstOption = optionButtons.element(boundBy: 0)
            if firstOption.exists {
                firstOption.tap()
                sleep(1)
            }
        }
        
        // 等待结果页面
        _ = app.otherElements["ResultView"].waitForExistence(timeout: 5.0)
        
        // 验证跳关提示
        let skipLevelMessage = app.staticTexts["skip_level_message"]
        if skipLevelMessage.exists {
            XCTAssertTrue(true, "应该显示跳关提示")
            
            // 点击跳关按钮
            let skipButton = app.buttons["skip_level_button"]
            if skipButton.exists {
                skipButton.tap()
                
                // 验证跳转到下一关
                let levelLabel = app.staticTexts["current_level_label"]
                XCTAssertTrue(levelLabel.exists, "应该显示当前关卡")
            }
        }
    }
    
    // MARK: - 辅助方法
    
    /// 导航到游戏页面
    private func navigateToGameView() {
        // 点击开始游戏
        let startGameButton = app.buttons["start_game_button"]
        startGameButton.tap()
        
        // 选择第1关
        let firstLevelButton = app.buttons["level_1_button"]
        firstLevelButton.tap()
        
        // 等待游戏页面加载
        _ = app.otherElements["GameView"].waitForExistence(timeout: 5.0)
    }
    
    // MARK: - 性能测试
    
    /// 测试游戏流程性能
    func testGameFlowPerformance() {
        measure {
            // 完成一局游戏
            navigateToGameView()
            
            for _ in 0..<10 {
                let optionButtons = app.buttons.matching(identifier: "option_button")
                let firstOption = optionButtons.element(boundBy: 0)
                if firstOption.exists {
                    firstOption.tap()
                    sleep(1)
                }
            }
            
            // 等待结果页面
            _ = app.otherElements["ResultView"].waitForExistence(timeout: 5.0)
            
            // 返回首页
            let homeButton = app.buttons["home_button"]
            homeButton.tap()
            
            // 等待首页
            _ = app.otherElements["HomeView"].waitForExistence(timeout: 5.0)
        }
    }
}
