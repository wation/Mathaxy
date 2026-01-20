//
//  QuestionGeneratorTests.swift
//  MathaxyTests
//
//  测试题目生成器的功能
//  Created on 2026-01-19
//

import XCTest
@testable import Mathaxy

/// 题目生成器测试类
final class QuestionGeneratorTests: XCTestCase {
    
    var generator: QuestionGenerator!
    
    override func setUp() {
        super.setUp()
        // 每个测试前初始化题目生成器
        generator = QuestionGenerator.shared
    }
    
    override func tearDown() {
        generator = nil
        super.tearDown()
    }
    
    // MARK: - 加法题目生成测试
    
    /// 测试生成加法题目
    func testGenerateAdditionQuestion() {
        let question = generator.generateQuestion(operation: .addition, level: 1)
        
        // 验证题目类型
        XCTAssertEqual(question.operation, .addition, "题目类型应该是加法")
        
        // 验证答案正确性
        let correctAnswer = question.operand1 + question.operand2
        XCTAssertEqual(question.correctAnswer, correctAnswer, "答案应该正确")
        
        // 验证选项中包含正确答案
        XCTAssertTrue(question.options.contains(question.correctAnswer), "选项中应包含正确答案")
        
        // 验证选项数量
        XCTAssertEqual(question.options.count, 4, "应该有4个选项")
        
        // 验证选项唯一性
        let uniqueOptions = Set(question.options)
        XCTAssertEqual(uniqueOptions.count, 4, "所有选项应该唯一")
    }
    
    /// 测试不同难度的加法题目
    func testGenerateAdditionQuestionWithDifferentLevels() {
        let levels = [1, 2, 3, 4, 5]
        
        for level in levels {
            let question = generator.generateQuestion(operation: .addition, level: level)
            
            // 验证题目生成成功
            XCTAssertNotNil(question, "关卡\(level)应该能生成题目")
            
            // 验证答案在合理范围内
            XCTAssertGreaterThan(question.correctAnswer, 0, "答案应该大于0")
            XCTAssertLessThan(question.correctAnswer, 100, "答案应该小于100")
            
            // 验证操作数在合理范围内
            XCTAssertGreaterThanOrEqual(question.operand1, 0, "操作数1应该大于等于0")
            XCTAssertGreaterThanOrEqual(question.operand2, 0, "操作数2应该大于等于0")
        }
    }
    
    // MARK: - 减法题目生成测试
    
    /// 测试生成减法题目
    func testGenerateSubtractionQuestion() {
        let question = generator.generateQuestion(operation: .subtraction, level: 1)
        
        // 验证题目类型
        XCTAssertEqual(question.operation, .subtraction, "题目类型应该是减法")
        
        // 验证答案非负
        XCTAssertGreaterThanOrEqual(question.correctAnswer, 0, "减法答案应该大于等于0")
        
        // 验证答案正确性
        let correctAnswer = question.operand1 - question.operand2
        XCTAssertEqual(question.correctAnswer, correctAnswer, "答案应该正确")
    }
    
    // MARK: - 乘法题目生成测试
    
    /// 测试生成乘法题目
    func testGenerateMultiplicationQuestion() {
        let question = generator.generateQuestion(operation: .multiplication, level: 3)
        
        // 验证题目类型
        XCTAssertEqual(question.operation, .multiplication, "题目类型应该是乘法")
        
        // 验证答案正确性
        let correctAnswer = question.operand1 * question.operand2
        XCTAssertEqual(question.correctAnswer, correctAnswer, "答案应该正确")
        
        // 验证操作数在合理范围内（乘法表范围）
        XCTAssertLessThanOrEqual(question.operand1, 9, "乘法操作数1应该在乘法表范围内")
        XCTAssertLessThanOrEqual(question.operand2, 9, "乘法操作数2应该在乘法表范围内")
    }
    
    // MARK: - 除法题目生成测试
    
    /// 测试生成除法题目
    func testGenerateDivisionQuestion() {
        let question = generator.generateQuestion(operation: .division, level: 4)
        
        // 验证题目类型
        XCTAssertEqual(question.operation, .division, "题目类型应该是除法")
        
        // 验证除数不为0
        XCTAssertNotEqual(question.operand2, 0, "除数不能为0")
        
        // 验证答案为整数
        XCTAssertEqual(question.correctAnswer, question.operand1 / question.operand2, "除法答案应该是整数")
    }
    
    // MARK: - 题目多样性测试
    
    /// 测试生成多道题目的多样性
    func testQuestionDiversity() {
        let questions = (0..<10).map { _ in
            generator.generateQuestion(operation: .addition, level: 1)
        }
        
        // 验证所有题目都生成成功
        XCTAssertEqual(questions.count, 10, "应该生成10道题目")
        
        // 验证题目不是完全相同的
        let uniqueQuestions = Set(questions.map { "\($0.operand1)+\($0.operand2)=\($0.correctAnswer)" })
        XCTAssertGreaterThan(uniqueQuestions.count, 1, "题目应该有多样性")
    }
    
    /// 测试生成混合运算题目
    func testGenerateMixedOperationQuestions() {
        let operations: [Question.Operation] = [.addition, .subtraction, .multiplication, .division]
        let questions = operations.map { generator.generateQuestion(operation: $0, level: 1) }
        
        // 验证每种运算都生成了题目
        XCTAssertEqual(questions.count, 4, "应该生成4种运算的题目")
        
        // 验证每道题都有正确的运算类型
        for (index, question) in questions.enumerated() {
            XCTAssertEqual(question.operation, operations[index], "第\(index+1)题的运算类型应该正确")
        }
    }
    
    // MARK: - 边界条件测试
    
    /// 测试边界条件 - 最小关卡
    func testMinimumLevel() {
        let question = generator.generateQuestion(operation: .addition, level: 1)
        XCTAssertNotNil(question, "最小关卡应该能生成题目")
    }
    
    /// 测试边界条件 - 最大关卡
    func testMaximumLevel() {
        let question = generator.generateQuestion(operation: .addition, level: 5)
        XCTAssertNotNil(question, "最大关卡应该能生成题目")
    }
    
    /// 测试边界条件 - 超出范围的关卡
    func testOutOfRangeLevel() {
        let question = generator.generateQuestion(operation: .addition, level: 100)
        XCTAssertNotNil(question, "超出范围的关卡应该能生成题目（使用默认值）")
    }
    
    // MARK: - 性能测试
    
    /// 测试题目生成性能
    func testQuestionGenerationPerformance() {
        measure {
            for _ in 0..<100 {
                _ = generator.generateQuestion(operation: .addition, level: 1)
            }
        }
    }
}
