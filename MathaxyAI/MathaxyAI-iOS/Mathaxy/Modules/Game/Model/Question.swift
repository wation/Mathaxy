//
//  Question.swift
//  Mathaxy
//
//  题目数据模型
//  定义加法题目的数据结构
//

import Foundation

// MARK: - 题目结构体
struct Question: Identifiable, Codable {
    /// 题目唯一标识
    let id: UUID
    
    /// 被加数 (0-9)
    let addend1: Int
    
    /// 加数 (0-9)
    let addend2: Int
    
    /// 正确答案 (0-18)
    let correctAnswer: Int
    
    /// 时间限制（秒）
    let timeLimit: Double
    
    /// 题目显示文本
    var displayText: String {
        return "\(addend1) + \(addend2) = ?"
    }
    
    /// 初始化方法
    init(addend1: Int, addend2: Int, timeLimit: Double = 0) {
        self.id = UUID()
        self.addend1 = addend1
        self.addend2 = addend2
        self.correctAnswer = addend1 + addend2
        self.timeLimit = timeLimit
    }
    
    /// 从字典初始化
    init?(dictionary: [String: Any]) {
        guard let addend1 = dictionary["addend1"] as? Int,
              let addend2 = dictionary["addend2"] as? Int,
              let timeLimit = dictionary["timeLimit"] as? Double else {
            return nil
        }
        
        self.id = UUID()
        self.addend1 = addend1
        self.addend2 = addend2
        self.correctAnswer = addend1 + addend2
        self.timeLimit = timeLimit
    }
    
    /// 转换为字典
    func toDictionary() -> [String: Any] {
        return [
            "addend1": addend1,
            "addend2": addend2,
            "correctAnswer": correctAnswer,
            "timeLimit": timeLimit
        ]
    }
}

// MARK: - 答题记录结构体
struct AnswerRecord: Identifiable, Codable {
    /// 答题记录唯一标识
    let id: UUID
    
    /// 题目ID
    let questionId: UUID
    
    /// 用户答案
    let userAnswer: Int
    
    /// 是否正确
    let isCorrect: Bool
    
    /// 答题用时（秒）
    let timeTaken: Double
    
    /// 答题时间戳
    let timestamp: Date
    
    /// 初始化方法
    init(questionId: UUID, userAnswer: Int, isCorrect: Bool, timeTaken: Double) {
        self.id = UUID()
        self.questionId = questionId
        self.userAnswer = userAnswer
        self.isCorrect = isCorrect
        self.timeTaken = timeTaken
        self.timestamp = Date()
    }
}
