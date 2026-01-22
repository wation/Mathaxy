//
//  GameViewModel.swift
//  Mathaxy
//
//  游戏视图模型
//  管理游戏逻辑和状态
//

import Foundation
import SwiftUI

// MARK: - 游戏视图模型
class GameViewModel: ObservableObject {
    
    // MARK: - 发布属性
    @Published var gameSession: GameSession
    @Published var timeRemaining: Double = 0
    @Published var isTimeUp = false
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswer: Int?
    @Published var showResult = false
    @Published var isCorrectAnswer = false
    @Published var showGameOver = false
    
    // MARK: - 服务
    private let storageService = StorageService.shared
    
    // MARK: - 定时器
    private var timer: Timer?
    
    // MARK: - 游戏完成回调
    var onGameComplete: ((Bool, Int) -> Void)?
    
    // MARK: - 初始化
    init(level: Int) {
        let questions = QuestionGenerator.shared.generateQuestions(for: level, count: GameConstants.questionsPerLevel)
        self.gameSession = GameSession(level: level, questions: questions)
        self.timeRemaining = Double(GameConstants.questionsPerLevel * 30) // 默认每题30秒
    }
    
    // MARK: - 提交答案
    func submitAnswer(_ answer: Int) {
        let startTime = Date()
        gameSession.submitAnswer(answer: answer, timeTaken: Date().timeIntervalSince(startTime))
        
        isCorrectAnswer = answer == gameSession.currentQuestion?.correctAnswer
        showResult = true
        
        // 延迟后显示下一题
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.moveToNextQuestion()
        }
    }
    
    // MARK: - 移动到下一题
    private func moveToNextQuestion() {
        if gameSession.currentIndex < gameSession.questions.count {
            currentQuestionIndex = gameSession.currentIndex
            selectedAnswer = nil
            showResult = false
        } else {
            gameSession.isCompleted = true
            showGameOver = true
            saveGameResults()
        }
    }
    
    // MARK: - 启动计时器
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timeRemaining -= 0.1
            if self?.timeRemaining ?? 0 <= 0 {
                self?.timeUp()
            }
        }
    }
    
    // MARK: - 停止计时器
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - 时间结束
    private func timeUp() {
        isTimeUp = true
        stopTimer()
        gameSession.markAsFailed()
        showGameOver = true
        saveGameResults()
    }
    
    // MARK: - 保存游戏结果
    private func saveGameResults() {
        guard var userProfile = storageService.loadUserProfile() else {
            return
        }
        
        let isCompleted = gameSession.isCompleted && !gameSession.isFailed
        
        // 如果关卡完成，更新用户资料
        if isCompleted {
            userProfile.completeLevel(gameSession.level)
            
            // 添加获得的勋章
            let earnedBadges = gameSession.getEarnedBadges()
            for badgeType in earnedBadges {
                let badge = Badge(type: badgeType, level: gameSession.level)
                userProfile.addBadge(badge)
            }
        }
        
        // 保存更新后的用户资料
        storageService.saveUserProfile(userProfile)
        
        // 触发回调
        onGameComplete?(isCompleted, gameSession.level)
    }
    
    // MARK: - 获取进度
    func getProgress() -> Double {
        return gameSession.progress
    }
    
    // MARK: - 获取当前题目
    func getCurrentQuestion() -> Question? {
        return gameSession.currentQuestion
    }
    
    deinit {
        stopTimer()
    }
}
