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
    func generateQuestions(level: Int, count: Int = GameConstants.questionsPerLevel) -> [Question] {
        let levelConfig = LevelConfig.getLevelConfig(level)
        var questions: [Question] = []
        var usedCombinations: Set<String> = []
        
        // Per-level constraints introduced by product requirement
        // level -> (maxZeroAddendCount, minTwoDigitSumCount, forbidZeroForAll)
        let constraints: [Int: (maxZero: Int, minTwoDigit: Int, forbidZero: Bool)] = [
            6: (maxZero: 2, minTwoDigit: 0, forbidZero: false),
            7: (maxZero: 1, minTwoDigit: 0, forbidZero: false),
            8: (maxZero: 1, minTwoDigit: 3, forbidZero: false),
            9: (maxZero: 1, minTwoDigit: 5, forbidZero: false),
            10: (maxZero: 0, minTwoDigit: 7, forbidZero: true)
        ]
        
        let levelConstraint = constraints[level] ?? (maxZero: Int.max, minTwoDigit: 0, forbidZero: false)
        
        // Helper closures
        let isZeroQuestion: (Int, Int) -> Bool = { a, b in
            return a == 0 || b == 0
        }
        let isTwoDigitSum: (Int, Int) -> Bool = { a, b in
            return (a + b) >= 10
        }
        
        // Pre-generate candidate pools to make it easier to satisfy constraints
        var zeroPool: [Question] = []
        var twoDigitPool: [Question] = []
        var normalPool: [Question] = []
        var allPossible: [Question] = []
        
        for a in 0...9 {
            for b in 0...9 {
                let q = Question(addend1: a, addend2: b, timeLimit: levelConfig.perQuestionTime ?? 0)
                allPossible.append(q)
                if isZeroQuestion(a, b) { zeroPool.append(q) }
                if isTwoDigitSum(a, b) { twoDigitPool.append(q) }
                if !isZeroQuestion(a, b) && !isTwoDigitSum(a, b) { normalPool.append(q) }
            }
        }
        
        // Shuffle pools to get randomness
        zeroPool.shuffle()
        twoDigitPool.shuffle()
        normalPool.shuffle()
        allPossible.shuffle()
        
        var zeroCount = 0
        var twoDigitCount = 0
        var attempt = 0
        let maxAttempts = 10000
        
        // First, try to greedily satisfy minTwoDigit requirement
        if levelConstraint.minTwoDigit > 0 {
            for q in twoDigitPool {
                let combo = "\(q.addend1)+\(q.addend2)"
                if questions.count < count && !usedCombinations.contains(combo) {
                    questions.append(q)
                    usedCombinations.insert(combo)
                    twoDigitCount += 1
                }
                if twoDigitCount >= levelConstraint.minTwoDigit { break }
            }
        }
        
        // Then fill remaining slots respecting zero limits and forbidZero
        while questions.count < count && attempt < maxAttempts {
            attempt += 1
            // Prefer normal and two-digit (to meet counts), but allow others if needed
            var candidatePools: [[Question]] = []
            candidatePools.append(normalPool)
            candidatePools.append(twoDigitPool)
            candidatePools.append(zeroPool)
            candidatePools.append(allPossible)
            
            var picked: Question? = nil
            for pool in candidatePools {
                if pool.isEmpty { continue }
                // pick random index
                let idx = Int.random(in: 0..<pool.count)
                let q = pool[idx]
                let combo = "\(q.addend1)+\(q.addend2)"
                if usedCombinations.contains(combo) { continue }
                // enforce forbidZero
                if levelConstraint.forbidZero && isZeroQuestion(q.addend1, q.addend2) { continue }
                // enforce maxZero
                if isZeroQuestion(q.addend1, q.addend2) && zeroCount >= levelConstraint.maxZero { continue }
                // ok
                picked = q
                break
            }
            
            if let q = picked {
                let combo = "\(q.addend1)+\(q.addend2)"
                usedCombinations.insert(combo)
                questions.append(q)
                if isZeroQuestion(q.addend1, q.addend2) { zeroCount += 1 }
                if isTwoDigitSum(q.addend1, q.addend2) { twoDigitCount += 1 }
            } else {
                // Nothing could be picked under current constraints; relax by allowing any unused
                for q in allPossible {
                    let combo = "\(q.addend1)+\(q.addend2)"
                    if usedCombinations.contains(combo) { continue }
                    // still enforce forbidZero
                    if levelConstraint.forbidZero && isZeroQuestion(q.addend1, q.addend2) { continue }
                    usedCombinations.insert(combo)
                    questions.append(q)
                    if isZeroQuestion(q.addend1, q.addend2) { zeroCount += 1 }
                    if isTwoDigitSum(q.addend1, q.addend2) { twoDigitCount += 1 }
                    break
                }
            }
        }
        
        // Safety deterministic fallback: if constraints not met (due to limited pool), try deterministic construction
        if twoDigitCount < levelConstraint.minTwoDigit {
            // clear and build deterministic two-digit-first list
            questions.removeAll()
            usedCombinations.removeAll()
            twoDigitCount = 0
            zeroCount = 0
            for q in twoDigitPool {
                let combo = "\(q.addend1)+\(q.addend2)"
                if !usedCombinations.contains(combo) {
                    questions.append(q)
                    usedCombinations.insert(combo)
                    twoDigitCount += 1
                }
                if twoDigitCount >= levelConstraint.minTwoDigit { break }
            }
            // fill rest from non-zero pool if forbidZero, else from allPossible
            let fillFrom = levelConstraint.forbidZero ? allPossible.filter { !isZeroQuestion($0.addend1, $0.addend2) } : allPossible
            for q in fillFrom {
                if questions.count >= count { break }
                let combo = "\(q.addend1)+\(q.addend2)"
                if usedCombinations.contains(combo) { continue }
                // enforce maxZero if applicable
                if isZeroQuestion(q.addend1, q.addend2) && zeroCount >= levelConstraint.maxZero { continue }
                questions.append(q)
                usedCombinations.insert(combo)
                if isZeroQuestion(q.addend1, q.addend2) { zeroCount += 1 }
            }
        }
        
        // Final trim in rare case of overshoot
        if questions.count > count {
            questions = Array(questions.prefix(count))
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
