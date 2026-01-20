//
//  LevelSelectView.swift
//  Mathaxy
//
//  关卡选择视图
//  显示可用关卡和用户进度
//

import SwiftUI

// MARK: - 关卡选择视图
struct LevelSelectView: View {
    
    // MARK: - 用户资料
    let userProfile: UserProfile
    
    // MARK: - 导航状态
    @State private var selectedLevel: Int?
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                Color.spaceBlue
                    .ignoresSafeArea()
                
                // 内容
                VStack {
                    Text(LocalizedKeys.levelSelect.localized)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.starlightYellow)
                        .padding(.top, 20)
                    
                    // 关卡网格
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(1...GameConstants.totalLevels, id: \.self) { level in
                                LevelButtonView(
                                    level: level,
                                    isCompleted: userProfile.completedLevels.contains(level),
                                    isCurrentLevel: userProfile.currentLevel == level,
                                    isUnlocked: level == 1 || userProfile.completedLevels.contains(level - 1)
                                ) {
                                    selectedLevel = level
                                }
                            }
                        }
                        .padding(20)
                    }
                    
                    Spacer()
                    
                    // 关闭按钮
                    Button(action: { dismiss() }) {
                        Text(LocalizedKeys.back.localized)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.cometWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.stardustPurple)
                            .cornerRadius(8)
                    }
                    .padding(20)
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedLevel != nil },
                set: { if !$0 { selectedLevel = nil } }
            )) {
                if let level = selectedLevel {
                    GamePlayView(level: level)
                }
            }
        }
    }
}

// MARK: - 关卡按钮视图
private struct LevelButtonView: View {
    let level: Int
    let isCompleted: Bool
    let isCurrentLevel: Bool
    let isUnlocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if isUnlocked {
                SoundService.shared.playButtonClickSound()
                action()
            } else {
                SoundService.shared.playErrorSound()
            }
        }) {
            VStack {
                if isUnlocked {
                    Text("\(level)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isCompleted ? Color.starlightYellow : Color.cometWhite)
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.starlightYellow)
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.cometWhite.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(isCurrentLevel ? Color.stardustPurple : Color.spaceBlue.opacity(0.7))
            .border(isCurrentLevel ? Color.starlightYellow : Color.cometWhite, width: 2)
            .cornerRadius(8)
        }
        .disabled(!isUnlocked)
    }
}

#Preview {
    LevelSelectView(userProfile: UserProfile())
}
