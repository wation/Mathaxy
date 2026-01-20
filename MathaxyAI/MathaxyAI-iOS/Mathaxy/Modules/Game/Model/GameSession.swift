//
//  GameSession.swift
//  Mathaxy
//
//  游戏会话数据模型
//  管理单次游戏会话的状态和数据
//

import Foundation

// MARK: - 最近答题记录结构体
struct RecentAnswer: Codable {
    let answer: Int
    let time: Double
}

// MARK: - 游戏会话结构体
struct GameSession: Identifiable, Codable {
    /// 会话唯一标识
    let id: UUID
    
    /// 关卡编号
    let level: Int
    
    /// 题目列表
    let questions: [Question]
    
    /// 当前题目索引
    var currentIndex: Int
    
    /// 正确数量
    var correctCount: Int
    
    /// 错误数量
    var errorCount: Int
    
    /// 开始时间
    let startTime: Date
    
    /// 总用时（秒）
    var totalTime: Double
    
    /// 是否完成
    var isCompleted: Bool
    
    /// 是否失败
    var isFailed: Bool
    
    /// 答题记录列表
    var answerRecords: [AnswerRecord]
    
    /// 最近10次答题记录（用于跳关检测）
    var lastTenAnswers: [RecentAnswer]
    
    /// 初始化方法
    init(level: Int, questions: [Question]) {
        self.id = UUID()
        self.level = level
        self.questions = questions
        self.currentIndex = 0
        self.correctCount = 0
        self.errorCount = 0
        self.startTime = Date()
        self.totalTime = 0
        self.isCompleted = false
        self.isFailed = false
        self.answerRecords = []
        self.lastTenAnswers = []
    }
    
    /// 获取当前题目
    var currentQuestion: Question? {
        guard currentIndex < questions.count else {
            return nil
        }
        return questions[currentIndex]
    }
    
    /// 获取进度
    var progress: Double {
        return Double(currentIndex) / Double(questions.count)
    }
    
    /// 获取剩余题目数量
    var remainingQuestions: Int {
        return questions.count - currentIndex
    }
    
    /// 获取正确率
    var accuracy: Double {
        let totalAnswered = correctCount + errorCount
        guard totalAnswered > 0 else {
            return 0
        }
        return Double(correctCount) / Double(totalAnswered)
    }
    
    /// 平均每题用时
    var averageTimePerQuestion: Double {
        let totalAnswered = correctCount + errorCount
        guard totalAnswered > 0 else {
            return 0
        }
        return totalTime / Double(totalAnswered)
    }
    
    /// 提交答案
    /// - Returns: 答案是否正确
    @discardableResult
    mutating func submitAnswer(answer: Int, timeTaken: Double) -> Bool {
        guard let question = currentQuestion else {
            return false
        }
        
        let isCorrect = answer == question.correctAnswer
        
        if isCorrect {
            correctCount += 1
            // 只有回答正确才移动到下一题
            currentIndex += 1
        } else {
            errorCount += 1
            // 回答错误停留在当前题目，不增加 currentIndex
        }
        
        // 记录答题信息
        let record = AnswerRecord(
            questionId: question.id,
            userAnswer: answer,
            isCorrect: isCorrect,
            timeTaken: timeTaken
        )
        answerRecords.append(record)
        
        // 更新最近10次答题记录
        lastTenAnswers.append(RecentAnswer(answer: answer, time: timeTaken))
        if lastTenAnswers.count > 10 {
            lastTenAnswers.removeFirst()
        }
        
        // 更新总用时
        totalTime += timeTaken
        
        // 检查是否完成
        if currentIndex >= questions.count {
            isCompleted = true
        }
        
        return isCorrect
    }
    
    /// 标记为失败
    mutating func markAsFailed() {
        isFailed = true
        isCompleted = true
    }
    
    /// 获取已获得的勋章
    func getEarnedBadges() -> [BadgeType] {
        var badges: [BadgeType] = []
        
        // 通关勋章
        if isCompleted && !isFailed {
            badges.append(.levelComplete)
        }
        
        // 完美勋章（20题全对）
        if isCompleted && !isFailed && errorCount == 0 {
            badges.append(.perfectLevel)
        }
        
        return badges
    }
}
