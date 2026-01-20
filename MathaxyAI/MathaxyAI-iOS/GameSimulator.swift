//
//  GameSimulator.swift
//  Mathaxy - 游戏模拟器
//
//  模拟用户在模拟器上玩游戏并通关
//

import Foundation

// MARK: - 游戏模拟器类
class GameSimulator {
    

    
    // MARK: - 题目结构
    struct Question {
        let addend1: Int
        let addend2: Int
        let correctAnswer: Int
        
        var displayText: String {
            return "\(addend1) + \(addend2) = ?"
        }
    }
    
    // MARK: - 游戏会话
    class GameSession {
        let level: Int
        let questions: [Question]
        var currentIndex: Int = 0
        var correctCount: Int = 0
        var errorCount: Int = 0
        var totalTime: Double = 0
        var isCompleted: Bool = false
        var answerRecords: [(answer: Int, isCorrect: Bool, timeTaken: Double)] = []
        
        init(level: Int, questions: [Question]) {
            self.level = level
            self.questions = questions
        }
        
        var currentQuestion: Question? {
            guard currentIndex < questions.count else { return nil }
            return questions[currentIndex]
        }
        
        var progress: Double {
            return Double(currentIndex) / Double(questions.count)
        }
        
        var accuracy: Double {
            let totalAnswered = correctCount + errorCount
            guard totalAnswered > 0 else { return 0 }
            return Double(correctCount) / Double(totalAnswered)
        }
        
        var averageTimePerQuestion: Double {
            guard currentIndex > 0 else { return 0 }
            return totalTime / Double(currentIndex)
        }
        
        func submitAnswer(answer: Int, timeTaken: Double) -> Bool {
            guard let question = currentQuestion else { return false }
            
            let isCorrect = answer == question.correctAnswer
            if isCorrect {
                correctCount += 1
            } else {
                errorCount += 1
            }
            
            answerRecords.append((answer: answer, isCorrect: isCorrect, timeTaken: timeTaken))
            totalTime += timeTaken
            currentIndex += 1
            
            if currentIndex >= questions.count {
                isCompleted = true
            }
            
            return isCorrect
        }
    }
    
    // MARK: - 题目生成器
    class QuestionGenerator {
        func generateQuestions(level: Int, count: Int = GameConstants.questionsPerLevel) -> [Question] {
            var questions: [Question] = []
            var usedCombinations: Set<String> = []
            
            while questions.count < count {
                let addend1 = Int.random(in: 0...9)
                let addend2 = Int.random(in: 0...9)
                let combination = "\(addend1)+\(addend2)"
                
                if !usedCombinations.contains(combination) {
                    usedCombinations.insert(combination)
                    let question = Question(addend1: addend1, addend2: addend2, correctAnswer: addend1 + addend2)
                    questions.append(question)
                }
            }
            
            return questions
        }
    }
    
    // MARK: - 关卡配置
    struct LevelConfig {
        let level: Int
        let mode: String
        let totalTime: Double?
        let perQuestionTime: Double?
        let maxErrors: Int
        let description: String
        
        static func getLevelConfig(_ level: Int) -> LevelConfig {
            switch level {
            case 1:
                return LevelConfig(level: 1, mode: "总时长", totalTime: 300, perQuestionTime: nil, maxErrors: 0, description: "总时长5分钟（平均15秒/题）")
            case 2:
                return LevelConfig(level: 2, mode: "总时长", totalTime: 240, perQuestionTime: nil, maxErrors: 0, description: "总时长4分钟（平均12秒/题）")
            case 3:
                return LevelConfig(level: 3, mode: "总时长", totalTime: 180, perQuestionTime: nil, maxErrors: 0, description: "总时长3分钟（平均9秒/题）")
            case 4:
                return LevelConfig(level: 4, mode: "总时长", totalTime: 120, perQuestionTime: nil, maxErrors: 0, description: "总时长2分钟（平均6秒/题）")
            case 5:
                return LevelConfig(level: 5, mode: "总时长", totalTime: 90, perQuestionTime: nil, maxErrors: 0, description: "总时长1分30秒（平均4.5秒/题）")
            case 6:
                return LevelConfig(level: 6, mode: "单题倒计时", totalTime: nil, perQuestionTime: 4.0, maxErrors: 3, description: "每题4秒")
            case 7:
                return LevelConfig(level: 7, mode: "单题倒计时", totalTime: nil, perQuestionTime: 3.5, maxErrors: 3, description: "每题3.5秒")
            case 8:
                return LevelConfig(level: 8, mode: "单题倒计时", totalTime: nil, perQuestionTime: 3.0, maxErrors: 3, description: "每题3秒")
            case 9:
                return LevelConfig(level: 9, mode: "单题倒计时", totalTime: nil, perQuestionTime: 2.5, maxErrors: 3, description: "每题2.5秒")
            case 10:
                return LevelConfig(level: 10, mode: "单题倒计时", totalTime: nil, perQuestionTime: 2.0, maxErrors: 3, description: "每题2秒")
            default:
                return LevelConfig(level: 1, mode: "总时长", totalTime: 300, perQuestionTime: nil, maxErrors: 0, description: "总时长5分钟（平均15秒/题）")
            }
        }
    }
    
    // MARK: - 模拟游戏
    func simulateGame(level: Int, simulatePerfectGame: Bool = true) {
        print("\n" + String(repeating: "=", count: 60))
        print("🎮 开始模拟关卡 \(level) 游戏通关")
        print(String(repeating: "=", count: 60))
        
        let config = LevelConfig.getLevelConfig(level)
        print("\n📋 关卡配置:")
        print("   - 关卡: \(config.level)")
        print("   - 模式: \(config.mode)")
        print("   - 描述: \(config.description)")
        print("   - 题目数量: \(GameConstants.questionsPerLevel) 题")
        
        // 生成题目
        let generator = QuestionGenerator()
        let questions = generator.generateQuestions(level: level)
        let session = GameSession(level: level, questions: questions)
        
        print("\n🎯 开始答题...")
        print(String(repeating: "-", count: 60))
        
        var totalTimeElapsed: Double = 0
        
        for (index, question) in questions.enumerated() {
            // 模拟答题时间（根据关卡难度调整）
            let baseTime = config.perQuestionTime ?? 3.0
            let timeVariation = Double.random(in: -0.5...0.5)
            let timeTaken = max(0.5, baseTime + timeVariation)
            
            // 模拟用户答案
            let userAnswer: Int
            if simulatePerfectGame {
                userAnswer = question.correctAnswer
            } else {
                // 95% 概率答对
                userAnswer = Double.random(in: 0...1) < 0.95 ? question.correctAnswer : question.correctAnswer + 1
            }
            
            // 提交答案
            let isCorrect = session.submitAnswer(answer: userAnswer, timeTaken: timeTaken)
            totalTimeElapsed += timeTaken
            
            // 显示答题结果
            let statusIcon = isCorrect ? "✅" : "❌"
            print("\(statusIcon) 第\(index + 1)题: \(question.displayText) → 回答: \(userAnswer) (用时: \(String(format: "%.2f", timeTaken))秒)")
            
            // 模拟思考时间
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        print(String(repeating: "-", count: 60))
        
        // 显示游戏结果
        print("\n🎉 游戏完成！")
        print(String(repeating: "=", count: 60))
        print("📊 游戏统计:")
        print("   - 关卡: \(session.level)")
        print("   - 正确题数: \(session.correctCount) / \(GameConstants.questionsPerLevel)")
        print("   - 错误题数: \(session.errorCount)")
        print("   - 正确率: \(String(format: "%.1f%%", session.accuracy * 100))")
        print("   - 总用时: \(String(format: "%.2f", totalTimeElapsed))秒")
        print("   - 平均每题: \(String(format: "%.2f", session.averageTimePerQuestion))秒")
        
        // 检查是否通关
        let isLevelComplete = session.correctCount >= GameConstants.questionsPerLevel - config.maxErrors
        let isPerfect = session.errorCount == 0
        
        print("\n🏆 成就:")
        if isLevelComplete {
            print("   ✅ 关卡通关成功！")
        } else {
            print("   ❌ 关卡通关失败（错误次数超过限制）")
        }
        
        if isPerfect {
            print("   🌟 完美通关（全对）！")
        }
        
        // 检查勋章
        print("\n🎖️ 获得勋章:")
        if isLevelComplete {
            print("   - 通关勋章")
        }
        if isPerfect {
            print("   - 完美勋章")
        }
        if session.accuracy >= 0.95 && session.averageTimePerQuestion < 5.0 {
            print("   - 神速小能手勋章")
        }
        if session.accuracy >= 0.95 {
            print("   - 答题小天才勋章")
        }
        
        print(String(repeating: "=", count: 60) + "\n")
    }
    
    // MARK: - 模拟完整游戏通关
    func simulateFullGameCompletion() {
        print("\n" + String(repeating: "🎮", count: 30))
        print("Mathaxy 游戏完整通关模拟")
        print(String(repeating: "🎮", count: 30))
        
        var totalCorrect = 0
        var totalQuestions = 0
        var totalTime: Double = 0
        
        for level in 1...10 {
            simulateGame(level: level, simulatePerfectGame: true)
            
            // 统计数据
            let generator = QuestionGenerator()
            let questions = generator.generateQuestions(level: level)
            totalCorrect += questions.count
            totalQuestions += questions.count
            
            let config = LevelConfig.getLevelConfig(level)
            if let totalTimeLimit = config.totalTime {
                totalTime += totalTimeLimit
            } else if let perQuestionTime = config.perQuestionTime {
                totalTime += perQuestionTime * Double(questions.count)
            }
        }
        
        print("\n" + String(repeating: "🏆", count: 30))
        print("完整通关总结")
        print(String(repeating: "🏆", count: 30))
        print("📊 总体统计:")
        print("   - 完成关卡: 10 / 10")
        print("   - 总答题数: \(totalQuestions)")
        print("   - 正确题数: \(totalCorrect)")
        print("   - 正确率: 100%")
        print("   - 总用时: \(String(format: "%.0f", totalTime))秒 (\(String(format: "%.1f", totalTime / 60))分钟)")
        print("\n🎊 恭喜！您已成功通关所有关卡！")
        print(String(repeating: "🏆", count: 30) + "\n")
    }
}

// MARK: - 运行模拟器
let simulator = GameSimulator()

// 模拟单关卡通关（第1关）
print("\n选择模拟模式:")
print("1. 模拟第1关通关")
print("2. 模拟完整游戏通关（10关）")
print("\n默认执行: 模拟完整游戏通关\n")

// 模拟完整游戏通关
simulator.simulateFullGameCompletion()
