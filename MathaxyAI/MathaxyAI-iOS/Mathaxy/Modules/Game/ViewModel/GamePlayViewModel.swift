//
//  GamePlayViewModel.swift
//  Mathaxy
//
//  游戏玩法视图模型
//  管理游戏核心逻辑和状态
//

import Foundation
import SwiftUI
import Combine

// MARK: - 游戏玩法视图模型
class GamePlayViewModel: ObservableObject {
    
    // MARK: - 服务
    private let storageService = StorageService.shared
    private let questionGenerator = QuestionGenerator.shared
    private let soundService = SoundService.shared
    
    // MARK: - 发布属性
    @Published var gameSession: GameSession
    @Published var currentQuestion: Question?
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswer: Int?
    @Published var timeRemaining: Double = 0
    @Published var isGameCompleted = false
    @Published var showResult = false
    @Published var isCorrectAnswer = false
    @Published var showGameComplete = false
    @Published var isLoading = true
    
    // 用户输入的答案（用于显示在等式上）
    @Published var userInputAnswer: String = ""
    
    // 输入错误状态
    @Published var hasInputError = false
    
    // MARK: - 计算属性
    var level: Int {
        return gameSession.level
    }
    
    var totalQuestions: Int {
        return gameSession.questions.count
    }
    
    var progress: Double {
        return Double(currentQuestionIndex) / Double(totalQuestions)
    }
    
    // MARK: - 定时器
    private var timer: Timer?
    private var questionStartTime: Date?
    
    // MARK: - 初始化
    init(level: Int) {
        let questions = questionGenerator.generateQuestions(level: level, count: GameConstants.questionsPerLevel)
        self.gameSession = GameSession(level: level, questions: questions)
        let config = LevelConfig.getLevelConfig(level)
        if config.mode == .totalTime, let totalTime = config.totalTime {
            self.timeRemaining = totalTime
        } else if config.mode == .perQuestion, let perQuestionTime = config.perQuestionTime {
            self.timeRemaining = perQuestionTime
        } else {
            self.timeRemaining = GameConstants.timePerQuestion * Double(questions.count)
        }
    }
    
    // MARK: - 开始游戏
    func startGame() {
        isLoading = true
        
        // 加载第一题
        loadCurrentQuestion()
        
        // 启动计时器
        startTimer()
        
        isLoading = false
    }
    
    // MARK: - 暂停游戏
    func pauseGame() {
        stopTimer()
    }
    
    // MARK: - 恢复游戏
    func resumeGame() {
        startTimer()
    }
    
    /// 播放按钮点击音效
    func playButtonClickSound() {
        soundService.playButtonClickSound()
    }
    
    // MARK: - 加载当前题目
    private func loadCurrentQuestion() {
        guard currentQuestionIndex < totalQuestions else {
            completeGame()
            return
        }
        
        currentQuestion = gameSession.questions[currentQuestionIndex]
        selectedAnswer = nil
        showResult = false
        hasInputError = false  // 重置错误状态
        userInputAnswer = ""  // 重置用户输入
        questionStartTime = Date()
        // 确保 GameSession 内部索引与视图模型同步，避免 submitAnswer 时使用错误的题目
        gameSession.currentIndex = currentQuestionIndex
    }
    
    // MARK: - 输入处理
    func inputDigit(_ digit: Int) {
        // 播放按钮点击音效
        SoundService.shared.playButtonClickSound()
        
        // 限制输入长度，例如最多两位数
        if userInputAnswer.count < 2 {
            userInputAnswer += "\(digit)"
        }
        
        // 检查答案是否正确，用于更新显示颜色
        checkAnswerForDisplay()
        
        // 如果输入达到最大长度（2位），检查是否可以提交
        if userInputAnswer.count == 2 {
            checkAndSubmitAnswer()
            return
        }
        
        // 支持个位数答案直接提交（第6-10关单题倒计时时会出现个位答案）
        if let currentQuestion = currentQuestion, let userVal = Int(userInputAnswer), userVal == currentQuestion.correctAnswer {
            checkAndSubmitAnswer()
        }
    }
    
    func clearAllInput() {
        // 播放按钮点击音效
        SoundService.shared.playButtonClickSound()
        
        // 重置错误状态和用户输入
        hasInputError = false
        userInputAnswer = ""
    }
    
    func backspaceInput() {
        // 播放按钮点击音效
        SoundService.shared.playButtonClickSound()
        
        if !userInputAnswer.isEmpty {
            userInputAnswer.removeLast()
            // 清除输入时重置错误状态
            hasInputError = false
        }
    }
    
    // MARK: - 检查答案是否正确（用于更新显示颜色）
    private func checkAnswerForDisplay() {
        guard let currentQuestion = currentQuestion,
              let userAnswer = Int(userInputAnswer) else { return }
        
        // 检查答案是否正确
        let isCorrect = userAnswer == currentQuestion.correctAnswer
        
        // 如果答案正确，清除错误状态
        if isCorrect {
            hasInputError = false
        } else {
            // 如果答案不正确，设置错误状态
            hasInputError = true
        }
    }
    
    // MARK: - 检查并提交答案
    private func checkAndSubmitAnswer() {
        // 防止重复提交或在展示结果时提交
        guard !showResult, let currentQuestion = currentQuestion,
              let userAnswer = Int(userInputAnswer) else { return }

        // 先在视图层判断是否正确，避免由于索引不同步造成的错误判定
        let localIsCorrect = userAnswer == currentQuestion.correctAnswer
        isCorrectAnswer = localIsCorrect

        // 在提交前确保 GameSession 的索引与视图模型同步
        gameSession.currentIndex = currentQuestionIndex

        // 提交答案（用于记录和统计）
        _ = gameSession.submitAnswer(answer: userAnswer, timeTaken: 0)

        // 播放音效并处理跳转
        if localIsCorrect {
            SoundService.shared.playCorrectSound()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.moveToNextQuestion()
            }
        } else {
            SoundService.shared.playIncorrectSound()
            // 保持输入，允许用户修改
            hasInputError = true
        }
    }
    
    // MARK: - 移动到下一题
    private func moveToNextQuestion() {
        currentQuestionIndex += 1
        
        if currentQuestionIndex < totalQuestions {
            loadCurrentQuestion()
            // 6-10关每题倒计时，切题时重置并重启计时器
            let config = LevelConfig.getLevelConfig(level)
            if config.mode == .perQuestion, let perQuestionTime = config.perQuestionTime {
                timeRemaining = perQuestionTime
                stopTimer()
                startTimer()
            }
        } else {
            completeGame()
        }
    }
    
    // MARK: - 完成游戏
    private func completeGame() {
        stopTimer()
        isGameCompleted = true
        gameSession.isCompleted = true
        
        // 保存游戏结果
        saveGameResult()
        
        // 播放完成音效
        SoundService.shared.playGameCompleteSound()
        
        // 显示游戏完成界面
        showGameComplete = true
    }
    
    // MARK: - 保存游戏结果
    private func saveGameResult() {
        // 更新用户资料；若未找到用户资料则创建游客资料并保存
        var userProfile = storageService.loadUserProfile() ?? UserProfile()
        
        // 添加完成关卡
        if !userProfile.completedLevels.contains(gameSession.level) {
            userProfile.completedLevels.insert(gameSession.level)
        }
        
        // 更新当前关卡
        if userProfile.currentLevel <= gameSession.level {
            userProfile.currentLevel = min(gameSession.level + 1, GameConstants.totalLevels)
        }
        
        // 检查并授予勋章
        checkAndAwardBadges(userProfile: &userProfile)
        
        // 保存用户资料
        storageService.saveUserProfile(userProfile)
        
        // 通知界面刷新用户资料（用于立即解锁下一关）
        NotificationCenter.default.post(name: .userProfileUpdated, object: nil)
    }
    
    // MARK: - 检查并授予勋章
    private func checkAndAwardBadges(userProfile: inout UserProfile) {
        // 关卡完成勋章
        if !userProfile.badges.contains(where: { $0.type == .levelComplete && $0.level == gameSession.level }) {
            let badge = Badge(type: .levelComplete, level: gameSession.level)
            userProfile.badges.append(badge)
        }
        
        // 神速小能手勋章（连续快速答对）
        if gameSession.accuracy >= 0.9 && gameSession.averageTimePerQuestion < 5.0 {
            if !userProfile.badges.contains(where: { $0.type == .skipLevel && $0.level == gameSession.level }) {
                let badge = Badge(type: .skipLevel, level: gameSession.level)
                userProfile.badges.append(badge)
            }
        }
        
        // 答题小天才勋章（高正确率）
        if gameSession.accuracy >= 0.95 {
            if !userProfile.badges.contains(where: { $0.type == .perfectLevel && $0.level == gameSession.level }) {
                let badge = Badge(type: .perfectLevel, level: gameSession.level)
                userProfile.badges.append(badge)
            }
        }
        
        // 坚持小达人勋章（连续登录）
        var loginRecord = userProfile.loginRecord
        if loginRecord.consecutiveDays >= 7 && !loginRecord.hasEarnedBadge {
            let badge = Badge(type: .consecutiveLogin, level: gameSession.level)
            userProfile.badges.append(badge)
            loginRecord.hasEarnedBadge = true
            userProfile.loginRecord = loginRecord
        }
    }
    
    // MARK: - 启动计时器
    private func startTimer() {
        // 使用0.1s精度的定时器，统一处理总时长模式与单题倒计时模式
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    // MARK: - 停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - 更新计时器
    private func updateTimer() {
        // 每次定时器回调仅减少剩余时间并在时间耗尽时处理超时逻辑。
        // 对于总时长模式（例如第6关）timeRemaining 表示剩余总时长。
        // 对于单题倒计时模式（第7-10关）timeRemaining 表示当前题目的剩余时间（显示精确到0.1s）。
        timeRemaining -= 0.1
        
        // 保证精度：针对需要显示一位小数的关卡，将 timeRemaining 保留到 0.1s
        let config = LevelConfig.getLevelConfig(level)
        if config.mode == .perQuestion {
            // 不允许出现负数的小数误差
            timeRemaining = max(0, (timeRemaining * 10).rounded(.down) / 10)
        } else {
            // 对于总时长，保留整数秒显示（但内部仍跟踪小数）
            timeRemaining = max(0, timeRemaining)
        }
        
        if timeRemaining <= 0 {
            timeUp()
        }
    }
    
    // MARK: - 时间结束
    private func timeUp() {
        stopTimer()
        
        // 标记当前题目为错误
        if let _ = currentQuestion {
            gameSession.submitAnswer(answer: -1, timeTaken: 0)
            // 超时强制推进进度
            gameSession.currentIndex += 1
        }
        
        // 播放时间结束音效
        SoundService.shared.playTimeoutSound()
        
        // 显示结果
        isCorrectAnswer = false
        showResult = true
        
        // 前5关时间到直接退出游戏
        if level <= 5 {
            completeGame()
            return
        }
        // 延迟后进入下一题
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.moveToNextQuestion()
        }
    }
    
    // MARK: - 跳过题目
    func skipQuestion() {
        guard !showResult else { return }
        
        // 标记为错误答案
        gameSession.submitAnswer(answer: -1, timeTaken: 0)
        
        // 播放音效
        SoundService.shared.playButtonClickSound()
        
        // 直接进入下一题
        moveToNextQuestion()
    }
    
    // MARK: - 重新开始游戏
    func restartGame() {
        // 重置状态
        currentQuestionIndex = 0
        selectedAnswer = nil
        showResult = false
        isCorrectAnswer = false
        isGameCompleted = false
        showGameComplete = false
        timeRemaining = GameConstants.timePerQuestion * Double(totalQuestions)
        
        // 重新生成题目
        let questions = questionGenerator.generateQuestions(level: level, count: GameConstants.questionsPerLevel)
        gameSession = GameSession(level: level, questions: questions)
        
        // 开始游戏
        startGame()
    }
    
    // MARK: - 获取正确答案提示
    func getHint() -> Bool {
        guard !showResult, let question = currentQuestion else { return false }
        
        // 检查是否有提示次数
        // TODO: 实现提示系统
        
        // 显示正确答案
        isCorrectAnswer = false
        showResult = true
        
        // 播放提示音效
        SoundService.shared.playButtonClickSound()
        
        // 延迟后进入下一题
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.moveToNextQuestion()
        }
        
        return true
    }
    
    deinit {
        stopTimer()
    }
}