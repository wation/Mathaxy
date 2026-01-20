//
//  GameSessionTests.swift
//  MathaxyTests
//
//  测试游戏会话数据模型的功能
//  Created on 2026-01-19
//

import XCTest
@testable import Mathaxy

/// 游戏会话测试类
final class GameSessionTests: XCTestCase {
    
    var gameSession: GameSession!
    var storageService: StorageService!
    
    override func setUp() {
        super.setUp()
        // 每个测试前初始化
        storageService = StorageService.shared
        storageService.clearAll()
        
        // 创建游戏会话
        gameSession = GameSession(level: 1)
    }
    
    override func tearDown() {
        storageService.clearAll()
        gameSession = nil
        storageService = nil
        super.tearDown()
    }
    
    // MARK: - 初始化测试
    
    /// 测试游戏会话初始化
    func testGameSessionInitialization() {
        let session = GameSession(level: 1)
        
        XCTAssertEqual(session.level, 1, "关卡应该正确初始化")
        XCTAssertEqual(session.score, 0, "初始分数应该为0")
        XCTAssertEqual(session.currentQuestionIndex, 0, "当前题目索引应该为0")
        XCTAssertEqual(session.correctAnswers, 0, "正确答案数应该为0")
        XCTAssertEqual(session.incorrectAnswers, 0, "错误答案数应该为0")
        XCTAssertFalse(session.isCompleted, "游戏不应该完成")
        XCTAssertFalse(session.isFailed, "游戏不应该失败")
    }
    
    /// 测试不同关卡的初始化
    func testGameSessionInitializationWithDifferentLevels() {
        let session1 = GameSession(level: 1)
        let session2 = GameSession(level: 5)
        
        XCTAssertEqual(session1.level, 1, "关卡1应该正确初始化")
        XCTAssertEqual(session2.level, 5, "关卡5应该正确初始化")
    }
    
    // MARK: - 答题测试
    
    /// 测试记录正确答案
    func testRecordCorrectAnswer() {
        let question = Question(
            id: "test_1",
            operand1: 5,
            operand2: 3,
            operation: .addition,
            correctAnswer: 8,
            options: [6, 7, 8, 9]
        )
        
        gameSession.recordAnswer(question: question, selectedAnswer: 8, timeSpent: 2.5)
        
        XCTAssertEqual(gameSession.correctAnswers, 1, "正确答案数应该为1")
        XCTAssertEqual(gameSession.incorrectAnswers, 0, "错误答案数应该为0")
        XCTAssertEqual(gameSession.currentQuestionIndex, 1, "当前题目索引应该为1")
    }
    
    /// 测试记录错误答案
    func testRecordIncorrectAnswer() {
        let question = Question(
            id: "test_1",
            operand1: 5,
            operand2: 3,
            operation: .addition,
            correctAnswer: 8,
            options: [6, 7, 8, 9]
        )
        
        gameSession.recordAnswer(question: question, selectedAnswer: 7, timeSpent: 2.5)
        
        XCTAssertEqual(gameSession.correctAnswers, 0, "正确答案数应该为0")
        XCTAssertEqual(gameSession.incorrectAnswers, 1, "错误答案数应该为1")
        XCTAssertEqual(gameSession.currentQuestionIndex, 1, "当前题目索引应该为1")
    }
    
    /// 测试记录多道题的答案
    func testRecordMultipleAnswers() {
        let questions = [
            Question(id: "test_1", operand1: 5, operand2: 3, operation: .addition, correctAnswer: 8, options: [6, 7, 8, 9]),
            Question(id: "test_2", operand1: 10, operand2: 4, operation: .subtraction, correctAnswer: 6, options: [4, 5, 6, 7]),
            Question(id: "test_3", operand1: 3, operand2: 4, operation: .multiplication, correctAnswer: 12, options: [10, 11, 12, 13])
        ]
        
        gameSession.recordAnswer(question: questions[0], selectedAnswer: 8, timeSpent: 2.5)
        gameSession.recordAnswer(question: questions[1], selectedAnswer: 6, timeSpent: 3.0)
        gameSession.recordAnswer(question: questions[2], selectedAnswer: 10, timeSpent: 1.5)
        
        XCTAssertEqual(gameSession.correctAnswers, 2, "正确答案数应该为2")
        XCTAssertEqual(gameSession.incorrectAnswers, 1, "错误答案数应该为1")
        XCTAssertEqual(gameSession.currentQuestionIndex, 3, "当前题目索引应该为3")
    }
    
    // MARK: - 分数计算测试
    
    /// 测试分数计算
    func testScoreCalculation() {
        let question = Question(
            id: "test_1",
            operand1: 5,
            operand2: 3,
            operation: .addition,
            correctAnswer: 8,
            options: [6, 7, 8, 9]
        )
        
        gameSession.recordAnswer(question: question, selectedAnswer: 8, timeSpent: 2.5)
        
        XCTAssertGreaterThan(gameSession.score, 0, "答对应该获得分数")
    }
    
    /// 测试快速答题的分数加成
    func testFastAnswerBonus() {
        let question = Question(
            id: "test_1",
            operand1: 5,
            operand2: 3,
            operation: .addition,
            correctAnswer: 8,
            options: [6, 7, 8, 9]
        )
        
        // 快速答题（1秒内）
        gameSession.recordAnswer(question: question, selectedAnswer: 8, timeSpent: 0.8)
        let fastScore = gameSession.score
        
        // 慢速答题（5秒）
        gameSession = GameSession(level: 1)
        gameSession.recordAnswer(question: question, selectedAnswer: 8, timeSpent: 5.0)
        let slowScore = gameSession.score
        
        XCTAssertGreaterThan(fastScore, slowScore, "快速答题应该获得更高分数")
    }
    
    // MARK: - 游戏状态测试
    
    /// 测试游戏完成状态
    func testGameCompletion() {
        // 模拟完成所有题目
        for i in 0..<10 {
            let question = Question(
                id: "test_\(i)",
                operand1: i,
                operand2: 1,
                operation: .addition,
                correctAnswer: i + 1,
                options: [i, i + 1, i + 2, i + 3]
            )
            gameSession.recordAnswer(question: question, selectedAnswer: i + 1, timeSpent: 2.0)
        }
        
        gameSession.completeGame()
        
        XCTAssertTrue(gameSession.isCompleted, "游戏应该标记为完成")
        XCTAssertFalse(gameSession.isFailed, "游戏不应该标记为失败")
    }
    
    /// 测试游戏失败状态
    func testGameFailure() {
        // 模拟答错多题
        for i in 0..<3 {
            let question = Question(
                id: "test_\(i)",
                operand1: i,
                operand2: 1,
                operation: .addition,
                correctAnswer: i + 1,
                options: [i, i + 1, i + 2, i + 3]
            )
            gameSession.recordAnswer(question: question, selectedAnswer: i, timeSpent: 2.0)
        }
        
        gameSession.failGame()
        
        XCTAssertFalse(gameSession.isCompleted, "游戏不应该标记为完成")
        XCTAssertTrue(gameSession.isFailed, "游戏应该标记为失败")
    }
    
    /// 测试游戏是否应该失败
    func testShouldFailGame() {
        // 答错3题
        for i in 0..<3 {
            let question = Question(
                id: "test_\(i)",
                operand1: i,
                operand2: 1,
                operation: .addition,
                correctAnswer: i + 1,
                options: [i, i + 1, i + 2, i + 3]
            )
            gameSession.recordAnswer(question: question, selectedAnswer: i, timeSpent: 2.0)
        }
        
        XCTAssertTrue(gameSession.shouldFailGame(), "答错3题应该失败")
    }
    
    // MARK: - 连续正确答题测试
    
    /// 测试连续正确答题
    func testConsecutiveCorrectAnswers() {
        let questions = [
            Question(id: "test_1", operand1: 5, operand2: 3, operation: .addition, correctAnswer: 8, options: [6, 7, 8, 9]),
            Question(id: "test_2", operand1: 10, operand2: 4, operation: .subtraction, correctAnswer: 6, options: [4, 5, 6, 7]),
            Question(id: "test_3", operand1: 3, operand2: 4, operation: .multiplication, correctAnswer: 12, options: [10, 11, 12, 13])
        ]
        
        gameSession.recordAnswer(question: questions[0], selectedAnswer: 8, timeSpent: 2.5)
        gameSession.recordAnswer(question: questions[1], selectedAnswer: 6, timeSpent: 3.0)
        gameSession.recordAnswer(question: questions[2], selectedAnswer: 12, timeSpent: 1.5)
        
        XCTAssertEqual(gameSession.consecutiveCorrectAnswers, 3, "连续正确答题数应该为3")
    }
    
    /// 测试连续正确答题被中断
    func testConsecutiveCorrectAnswersInterrupted() {
        let questions = [
            Question(id: "test_1", operand1: 5, operand2: 3, operation: .addition, correctAnswer: 8, options: [6, 7, 8, 9]),
            Question(id: "test_2", operand1: 10, operand2: 4, operation: .subtraction, correctAnswer: 6, options: [4, 5, 6, 7]),
            Question(id: "test_3", operand1: 3, operand2: 4, operation: .multiplication, correctAnswer: 12, options: [10, 11, 12, 13])
        ]
        
        gameSession.recordAnswer(question: questions[0], selectedAnswer: 8, timeSpent: 2.5)
        gameSession.recordAnswer(question: questions[1], selectedAnswer: 5, timeSpent: 3.0) // 答错
        gameSession.recordAnswer(question: questions[2], selectedAnswer: 12, timeSpent: 1.5)
        
        XCTAssertEqual(gameSession.consecutiveCorrectAnswers, 1, "答错后连续正确答题数应该重置为1")
    }
    
    /// 测试是否应该跳关
    func testShouldSkipLevel() {
        // 连续答对10题
        for i in 0..<10 {
            let question = Question(
                id: "test_\(i)",
                operand1: i,
                operand2: 1,
                operation: .addition,
                correctAnswer: i + 1,
                options: [i, i + 1, i + 2, i + 3]
            )
            gameSession.recordAnswer(question: question, selectedAnswer: i + 1, timeSpent: 1.0)
        }
        
        XCTAssertTrue(gameSession.shouldSkipLevel(), "连续答对10题应该跳关")
    }
    
    // MARK: - 数据持久化测试
    
    /// 测试保存和加载游戏会话
    func testSaveAndLoadGameSession() {
        let question = Question(
            id: "test_1",
            operand1: 5,
            operand2: 3,
            operation: .addition,
            correctAnswer: 8,
            options: [6, 7, 8, 9]
        )
        
        gameSession.recordAnswer(question: question, selectedAnswer: 8, timeSpent: 2.5)
        
        // 保存游戏会话
        gameSession.save()
        
        // 创建新会话并加载
        let loadedSession = GameSession.load(level: 1)
        
        XCTAssertNotNil(loadedSession, "应该能加载游戏会话")
        XCTAssertEqual(loadedSession?.level, gameSession.level, "关卡应该一致")
        XCTAssertEqual(loadedSession?.score, gameSession.score, "分数应该一致")
        XCTAssertEqual(loadedSession?.correctAnswers, gameSession.correctAnswers, "正确答案数应该一致")
    }
    
    // MARK: - 时间统计测试
    
    /// 测试总答题时间
    func testTotalTimeSpent() {
        let question = Question(
            id: "test_1",
            operand1: 5,
            operand2: 3,
            operation: .addition,
            correctAnswer: 8,
            options: [6, 7, 8, 9]
        )
        
        gameSession.recordAnswer(question: question, selectedAnswer: 8, timeSpent: 2.5)
        gameSession.recordAnswer(question: question, selectedAnswer: 8, timeSpent: 3.0)
        gameSession.recordAnswer(question: question, selectedAnswer: 8, timeSpent: 1.5)
        
        XCTAssertEqual(gameSession.totalTimeSpent, 7.0, accuracy: 0.1, "总答题时间应该为7秒")
    }
    
    /// 测试平均答题时间
    func testAverageTimeSpent() {
        let question = Question(
            id: "test_1",
            operand1: 5,
            operand2: 3,
            operation: .addition,
            correctAnswer: 8,
            options: [6, 7, 8, 9]
        )
        
        gameSession.recordAnswer(question: question, selectedAnswer: 8, timeSpent: 2.0)
        gameSession.recordAnswer(question: question, selectedAnswer: 8, timeSpent: 4.0)
        
        XCTAssertEqual(gameSession.averageTimeSpent, 3.0, accuracy: 0.1, "平均答题时间应该为3秒")
    }
    
    // MARK: - 边界条件测试
    
    /// 测试零答题
    func testZeroAnswers() {
        XCTAssertEqual(gameSession.currentQuestionIndex, 0, "初始题目索引应该为0")
        XCTAssertEqual(gameSession.score, 0, "初始分数应该为0")
        XCTAssertEqual(gameSession.totalTimeSpent, 0, "初始总时间应该为0")
    }
    
    /// 测试所有题目都答错
    func testAllIncorrectAnswers() {
        for i in 0..<10 {
            let question = Question(
                id: "test_\(i)",
                operand1: i,
                operand2: 1,
                operation: .addition,
                correctAnswer: i + 1,
                options: [i, i + 1, i + 2, i + 3]
            )
            gameSession.recordAnswer(question: question, selectedAnswer: i, timeSpent: 2.0)
        }
        
        XCTAssertEqual(gameSession.correctAnswers, 0, "正确答案数应该为0")
        XCTAssertEqual(gameSession.incorrectAnswers, 10, "错误答案数应该为10")
        XCTAssertEqual(gameSession.score, 0, "分数应该为0")
    }
    
    // MARK: - 性能测试
    
    /// 测试游戏会话性能
    func testGameSessionPerformance() {
        measure {
            let session = GameSession(level: 1)
            for i in 0..<100 {
                let question = Question(
                    id: "test_\(i)",
                    operand1: i,
                    operand2: 1,
                    operation: .addition,
                    correctAnswer: i + 1,
                    options: [i, i + 1, i + 2, i + 3]
                )
                session.recordAnswer(question: question, selectedAnswer: i + 1, timeSpent: 2.0)
            }
        }
    }
}
