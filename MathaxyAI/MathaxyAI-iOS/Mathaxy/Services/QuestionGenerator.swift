//
//  QuestionGenerator.swift
//  Mathaxy
//
//  题目生成引擎
//  负责生成10以内加法题目
//

import Foundation

// MARK: - 题目生成器类
class QuestionGenerator {
    
    // MARK: - 单例
    static let shared = QuestionGenerator()
    
    private init() {}
    
    // MARK: - 生成题目
    
    /// 生成指定关卡的题目
    /// - Parameters:
    ///   - level: 关卡编号
    ///   - count: 题目数量（默认20题）
    /// - Returns: 题目数组
    func generateQuestions(for level: Int, count: Int = GameConstants.questionsPerLevel) -> [Question] {
        let levelConfig = LevelConfig.getLevelConfig(level)
        var questions: [Question] = []
        var usedCombinations: Set<String> = []
        
        while questions.count < count {
            // 随机生成加数和被加数（0-9）
            let addend1 = Int.random(in: 0...9)
            let addend2 = Int.random(in: 0...9)
            let combination = "\(addend1)+\(addend2)"
            
            // 检查是否已使用过该组合（同一关卡内不重复）
            if !usedCombinations.contains(combination) {
                usedCombinations.insert(combination)
                
                // 根据关卡配置设置时间限制
                let timeLimit = levelConfig.perQuestionTime ?? 0
                
                let question = Question(
                    addend1: addend1,
                    addend2: addend2,
                    timeLimit: timeLimit
                )
                questions.append(question)
            }
        }
        
        return questions
    }
    
    /// 生成指定数量的题目（不关联关卡）
    /// - Parameter count: 题目数量
    /// - Returns: 题目数组
    func generateRandomQuestions(count: Int) -> [Question] {
        var questions: [Question] = []
        var usedCombinations: Set<String> = []
        
        while questions.count < count {
            let addend1 = Int.random(in: 0...9)
            let addend2 = Int.random(in: 0...9)
            let combination = "\(addend1)+\(addend2)"
            
            if !usedCombinations.contains(combination) {
                usedCombinations.insert(combination)
                
                let question = Question(
                    addend1: addend1,
                    addend2: addend2,
                    timeLimit: 0
                )
                questions.append(question)
            }
        }
        
        return questions
    }
    
    /// 生成指定答案范围的题目
    /// - Parameters:
    ///   - minAnswer: 最小答案
    ///   - maxAnswer: 最大答案
    ///   - count: 题目数量
    /// - Returns: 题目数组
    func generateQuestionsWithAnswerRange(minAnswer: Int, maxAnswer: Int, count: Int) -> [Question] {
        var questions: [Question] = []
        var usedCombinations: Set<String> = []
        
        while questions.count < count {
            let addend1 = Int.random(in: 0...9)
            let addend2 = Int.random(in: 0...9)
            let answer = addend1 + addend2
            let combination = "\(addend1)+\(addend2)"
            
            // 检查答案是否在指定范围内
            if answer >= minAnswer && answer <= maxAnswer && !usedCombinations.contains(combination) {
                usedCombinations.insert(combination)
                
                let question = Question(
                    addend1: addend1,
                    addend2: addend2,
                    timeLimit: 0
                )
                questions.append(question)
            }
        }
        
        return questions
    }
    
    /// 生成连续进位题型题目
    /// - Parameter count: 题目数量
    /// - Returns: 题目数组
    /// - Note: 连续进位题型指加数和被加数的和大于等于10，如3+8、5+7等
    func generateCarryQuestions(count: Int) -> [Question] {
        var questions: [Question] = []
        var usedCombinations: Set<String> = []
        
        while questions.count < count {
            let addend1 = Int.random(in: 0...9)
            let addend2 = Int.random(in: 0...9)
            let answer = addend1 + addend2
            let combination = "\(addend1)+\(addend2)"
            
            // 检查是否为进位题型（和大于等于10）
            if answer >= 10 && !usedCombinations.contains(combination) {
                usedCombinations.insert(combination)
                
                let question = Question(
                    addend1: addend1,
                    addend2: addend2,
                    timeLimit: 0
                )
                questions.append(question)
            }
        }
        
        return questions
    }
    
    /// 生成混合题型题目（包含普通题型和进位题型）
    /// - Parameters:
    ///   - carryRatio: 进位题型比例（0-1，默认0.3）
    ///   - count: 题目数量
    /// - Returns: 题目数组
    func generateMixedQuestions(carryRatio: Double = 0.3, count: Int) -> [Question] {
        let carryCount = Int(Double(count) * carryRatio)
        let normalCount = count - carryCount
        
        var carryQuestions = generateCarryQuestions(count: carryCount)
        var normalQuestions = generateRandomQuestions(count: normalCount)
        
        // 合并并打乱顺序
        var allQuestions = carryQuestions + normalQuestions
        allQuestions.shuffle()
        
        return allQuestions
    }
    
    // MARK: - 题目验证
    
    /// 验证题目是否有效
    /// - Parameter question: 题目
    /// - Returns: 是否有效
    func validateQuestion(_ question: Question) -> Bool {
        // 检查加数和被加数是否在0-9范围内
        guard question.addend1 >= 0 && question.addend1 <= 9,
              question.addend2 >= 0 && question.addend2 <= 9 else {
            return false
        }
        
        // 检查答案是否正确
        guard question.correctAnswer == question.addend1 + question.addend2 else {
            return false
        }
        
        return true
    }
    
    /// 验证答案是否正确
    /// - Parameters:
    ///   - question: 题目
    ///   - answer: 用户答案
    /// - Returns: 是否正确
    func validateAnswer(_ question: Question, answer: Int) -> Bool {
        return answer == question.correctAnswer
    }
}

// MARK: - 题目难度分类
extension QuestionGenerator {
    
    /// 题目难度枚举
    enum Difficulty {
        case easy       // 简单：和小于等于5
        case medium     // 中等：和大于5且小于等于10
        case hard       // 困难：和大于10
    }
    
    /// 获取题目难度
    /// - Parameter question: 题目
    /// - Returns: 难度等级
    func getDifficulty(of question: Question) -> Difficulty {
        let sum = question.addend1 + question.addend2
        
        if sum <= 5 {
            return .easy
        } else if sum <= 10 {
            return .medium
        } else {
            return .hard
        }
    }
    
    /// 生成指定难度的题目
    /// - Parameters:
    ///   - difficulty: 难度等级
    ///   - count: 题目数量
    /// - Returns: 题目数组
    func generateQuestions(difficulty: Difficulty, count: Int) -> [Question] {
        var questions: [Question] = []
        var usedCombinations: Set<String> = []
        
        while questions.count < count {
            let addend1 = Int.random(in: 0...9)
            let addend2 = Int.random(in: 0...9)
            _ = addend1 + addend2
            let combination = "\(addend1)+\(addend2)"
            
            // 检查是否符合难度要求
            let questionDifficulty = getDifficulty(of: Question(addend1: addend1, addend2: addend2))
            
            if questionDifficulty == difficulty && !usedCombinations.contains(combination) {
                usedCombinations.insert(combination)
                
                let question = Question(
                    addend1: addend1,
                    addend2: addend2,
                    timeLimit: 0
                )
                questions.append(question)
            }
        }
        
        return questions
    }
}
