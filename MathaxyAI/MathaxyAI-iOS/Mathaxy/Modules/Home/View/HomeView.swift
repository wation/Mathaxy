//
//  HomeView.swift
//  Mathaxy
//
//  首页
//  显示用户信息和主要导航
//

import SwiftUI

// MARK: - 首页
struct HomeView: View {
    
    // MARK: - 用户资料
    let userProfile: UserProfile
    
    // MARK: - 视图模型
    @StateObject private var viewModel: HomeViewModel
    @State private var showGameView = false
    
    // MARK: - 初始化
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        self._viewModel = StateObject(wrappedValue: HomeViewModel(userProfile: userProfile))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景
            backgroundView
            
            // 内容
            contentView
        }
        .ignoresSafeArea()
        .sheet(isPresented: $viewModel.showLevelSelect) {
            LevelSelectView(userProfile: userProfile)
        }
        .sheet(isPresented: $viewModel.showAchievement) {
            AchievementView(userProfile: userProfile)
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
        }
    }
    
    // MARK: - 背景视图
    private var backgroundView: some View {
        ZStack {
            // 银河背景渐变
            Color.galaxyGradient
                .ignoresSafeArea()
            
            // 星星装饰
            starsView
        }
    }
    
    // MARK: - 星星装饰
    private var starsView: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<40, id: \.self) { index in
                    Circle()
                        .fill(Color.starlightYellow.opacity(Double.random(in: 0.2...0.6)))
                        .frame(width: CGFloat.random(in: 2...5))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
        }
    }
    
    // MARK: - 内容视图
    private var contentView: some View {
        VStack(spacing: 0) {
            // 顶部导航
            topNavigationView
            
            Spacer()
            
            // 卡通角色和昵称
            characterView
            
            Spacer()
            
            // 开始游戏按钮
            startGameButton
            
            // 关卡进度
            levelProgressView
            
            Spacer()
            
            // 底部导航
            bottomNavigationView
                .padding(.bottom, 40)
        }
    }
    
    // MARK: - 顶部导航视图
    private var topNavigationView: some View {
        HStack {
            Spacer()
            
            // 设置按钮
            Button(action: {
                viewModel.showSettingsView()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(Color.starlightYellow)
            }
            .padding(.trailing, 20)
            .padding(.top, 20)
            
            // 成就按钮
            Button(action: {
                viewModel.showAchievementView()
            }) {
                Image(systemName: "medal.fill")
                    .font(.title2)
                    .foregroundColor(Color.starlightYellow)
            }
            .padding(.trailing, 20)
            .padding(.top, 20)
        }
    }
    
    // MARK: - 卡通角色视图
    private var characterView: some View {
        VStack(spacing: 15) {
            // 卡通角色
            if let characterType = viewModel.getLatestUnlockedCharacter() {
                ZStack {
                    Circle()
                        .fill(Color.starlightYellow.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    // 占位图：角色
                    Image(systemName: characterType == .panda ? "star.fill" : "star.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.starlightYellow)
                }
            } else {
                // 未解锁角色
                ZStack {
                    Circle()
                        .fill(Color.starlightYellow.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color.starlightYellow.opacity(0.5))
                }
            }
            
            // 昵称
            Text(userProfile.nickname)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.cometWhite)
        }
        .padding(.top, 40)
    }
    
    // MARK: - 开始游戏按钮视图
    private var startGameButton: some View {
        Button(action: {
            viewModel.showLevelSelectView()
        }) {
            HStack {
                Image(systemName: "play.fill")
                    .font(.title2)
                
                Text(LocalizedKeys.startGame.localized)
                    .font(.system(size: 24, weight: .semibold))
            }
            .foregroundColor(Color.spaceBlue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .primaryButtonStyle()
        .padding(.horizontal, 40)
    }
    
    // MARK: - 关卡进度视图
    private var levelProgressView: some View {
        VStack(spacing: 10) {
            Text(LocalizedKeys.currentLevel.localized)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.cometWhite.opacity(0.8))
            
            Text(viewModel.getCurrentLevelProgress())
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color.starlightYellow)
        }
        .padding(.top, 30)
    }
    
    // MARK: - 底部导航视图
    private var bottomNavigationView: some View {
        HStack(spacing: 40) {
            // 成就按钮
            Button(action: {
                viewModel.showAchievementView()
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "medal.fill")
                        .font(.title2)
                    
                    Text(LocalizedKeys.achievement.localized)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(Color.starlightYellow)
            }
            
            // 勋章数量
            VStack(spacing: 5) {
                Text("\(viewModel.getTotalBadgeCount())")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.starlightYellow)
                
                Text(LocalizedKeys.badges.localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.8))
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - 预览
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let userProfile = UserProfile(nickname: "小银河123")
        HomeView(userProfile: userProfile)
            .previewInterfaceOrientation(.portrait)
    }
}



// MARK: - 游戏结束原因枚举
enum GameOverReason {
    case completed      // 完成所有题目
    case timeOut       // 时间耗尽
}

// MARK: - 简单游戏视图
private struct SimpleGameView: View {
    let level: Int
    let userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storageService: StorageService
    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: Int?
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var correctCount = 0
    @State private var timeRemaining = 300.0
    @State private var timer: Timer?
    @State private var isLoading = true
    @State private var isGameOver = false
    @State private var gameOverReason: GameOverReason = .completed
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var body: some View {
        ZStack {
            Color.spaceBlue
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 顶部信息栏
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(Color.starlightYellow)
                    }
                    
                    Spacer()
                    
                    Text("Level \(level)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.cometWhite.opacity(0.8))
                    
                    Spacer()
                    
                    Text(String(format: "%.0f", timeRemaining))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(timeRemaining < 10 ? Color.red : Color.starlightYellow)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // 题目显示
                if isLoading {
                    // 加载状态
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.starlightYellow))
                            .scaleEffect(1.5)
                        
                        Text(LocalizedKeys.loading.localized)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.cometWhite.opacity(0.8))
                    }
                } else if let question = currentQuestion {
                    VStack(spacing: 30) {
                        Text("Question \(currentIndex + 1)/20")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.cometWhite.opacity(0.8))
                        
                        HStack(spacing: 20) {
                            Text("\(question.addend1)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color.starlightYellow)
                            
                            Text("+")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(Color.cometWhite)
                            
                            Text("\(question.addend2)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color.starlightYellow)
                            
                            Text("=")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(Color.cometWhite)
                            
                            Text("?")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color.nebulaPurple)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color.nebulaPurple.opacity(0.2))
                        .cornerRadius(12)
                    }
                } else {
                    // 游戏完成状态
                    VStack(spacing: 20) {
                        if gameOverReason == .timeOut {
                            Text("时间到!")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color.alertRed)
                            
                            Text("答对: \(correctCount)/\(currentIndex)")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color.cometWhite)
                        } else {
                            Text("游戏完成!")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color.starlightYellow)
                            
                            Text("答对: \(correctCount)/20")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color.cometWhite)
                        }
                        
                        Button(action: { dismiss() }) {
                            Text("返回关卡选择")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.spaceBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .background(Color.starlightYellow)
                        .cornerRadius(8)
                        .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // 答案选项
                if currentQuestion != nil {
                    VStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(0..<3, id: \.self) { col in
                                    let index = row * 3 + col
                                    if index < 19 {
                                        let answer = index
                                        Button(action: {
                                            if !showResult && timeRemaining > 0 {
                                                selectedAnswer = answer
                                                let correct = answer == currentQuestion?.correctAnswer
                                                isCorrect = correct
                                                showResult = true
                                                
                                                if correct {
                                                    correctCount += 1
                                                }
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                    showResult = false
                                                    selectedAnswer = nil
                                                    currentIndex += 1
                                                    
                                                    // 检查是否所有题目已完成
                                                    if currentIndex >= questions.count {
                                                        stopTimer()
                                                        isGameOver = true
                                                        gameOverReason = .completed
                                                        saveGameProgress()
                                                    }
                                                }
                                            }
                                        }) {
                                            Text("\(answer)")
                                                .font(.system(size: 24, weight: .bold))
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .foregroundColor(Color.cometWhite)
                                                .background(
                                                    selectedAnswer == answer ?
                                                    Color.starlightYellow :
                                                    Color.nebulaPurple
                                                )
                                                .cornerRadius(8)
                                        }
                                        .disabled(showResult || timeRemaining <= 0)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            print("SimpleGameView onAppear - Level: \(level)")
            isLoading = true
            isGameOver = false
            gameOverReason = .completed
            
            // 异步生成题目
            DispatchQueue.main.async {
                questions = QuestionGenerator.shared.generateQuestions(level: level, count: 20)
                print("SimpleGameView - Generated \(questions.count) questions")
                currentIndex = 0
                correctCount = 0
                
                // 完成加载
                isLoading = false
                
                // 启动计时器
                startTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                timeRemaining = 0
                stopTimer()
                isGameOver = true
                gameOverReason = .timeOut
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func saveGameProgress() {
        // 创建可变副本
        var updatedProfile = userProfile
        
        if gameOverReason == .completed && correctCount >= 10 {
            // 答对超过10题，标记为完成
            updatedProfile.completeLevel(level)
            
            // 如果全对，添加勋章
            if correctCount == 20 {
                let badge = Badge(type: .perfectLevel, level: level)
                updatedProfile.addBadge(badge)
            } else {
                // 添加关卡完成勋章
                let badge = Badge(type: .levelComplete, level: level)
                updatedProfile.addBadge(badge)
            }
            
            // 保存更新后的用户资料
            storageService.saveUserProfile(updatedProfile)
        }
    }
}






