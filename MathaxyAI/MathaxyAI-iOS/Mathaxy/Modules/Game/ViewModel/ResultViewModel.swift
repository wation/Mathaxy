//
//  ResultViewModel.swift
//  Mathaxy
//
//  游戏结果视图模型
//  管理游戏结果展示和分享逻辑
//

import Foundation
import SwiftUI
import UIKit

// MARK: - 游戏结果视图模型
class ResultViewModel: ObservableObject {
    
    // MARK: - 服务
    private let storageService = StorageService.shared
    private let certificateGenerator = CertificateGenerator.shared
    
    // MARK: - 发布属性
    @Published var starRating: Int = 0
    @Published var isGeneratingCertificate = false
    @Published var shareMessage = ""
    
    // MARK: - 初始化
    init() {}
    
    // MARK: - 保存游戏结果
    func saveGameResult(_ gameSession: GameSession) {
        // 计算星级评价
        calculateStarRating(gameSession)
        
        // 生成分享消息
        generateShareMessage(gameSession)
        
        // 保存游戏会话
        saveGameSession(gameSession)
    }
    
    // MARK: - 计算星级评价
    private func calculateStarRating(_ gameSession: GameSession) {
        let accuracy = gameSession.accuracy
        let averageTime = gameSession.averageTimePerQuestion
        
        // 基于正确率和平均时间计算星级
        if accuracy >= 0.95 && averageTime < 3.0 {
            starRating = 3 // 三星：完美表现
        } else if accuracy >= 0.85 && averageTime < 5.0 {
            starRating = 2 // 二星：优秀表现
        } else if accuracy >= 0.7 {
            starRating = 1 // 一星：通过
        } else {
            starRating = 0 // 无星：未通过
        }
    }
    
    // MARK: - 生成分享消息
    private func generateShareMessage(_ gameSession: GameSession) {
        let accuracy = String(format: "%.1f%%", gameSession.accuracy * 100)
        let time = String(format: "%.0f", gameSession.totalTime)
        
        shareMessage = String(format: 
            LocalizedKeys.shareMessageTemplate.localized,
            gameSession.level,
            accuracy,
            time,
            starRating
        )
    }
    
    // MARK: - 保存游戏会话
    private func saveGameSession(_ gameSession: GameSession) {
        // 获取用户资料
        guard var userProfile = storageService.loadUserProfile() else {
            return
        }
        
        // 添加游戏记录
        userProfile.gameHistory.append(gameSession)
        
        // 限制历史记录数量
        if userProfile.gameHistory.count > 100 {
            userProfile.gameHistory.removeFirst(userProfile.gameHistory.count - 100)
        }
        
        // 更新总游戏时间
        userProfile.totalPlayTime += gameSession.totalTime
        
        // 保存用户资料
        storageService.saveUserProfile(userProfile)
    }
    
    // MARK: - 获取分享内容
    func getShareItems(for gameSession: GameSession) -> [Any] {
        var items: [Any] = []
        
        // 添加文本消息
        items.append(shareMessage)
        
        // 添加应用链接
        if let appURL = URL(string: "https://apps.apple.com/app/mathaxy") {
            items.append(appURL)
        }
        
        // TODO: 添加结果图片
        // items.append(resultImage)
        
        return items
    }
    
    // MARK: - 生成奖状
    func generateCertificate(for gameSession: GameSession, completion: @escaping (UIImage?) -> Void) {
        isGeneratingCertificate = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 生成奖状图片
            let certificateImage = self.createCertificateImage(gameSession)
            
            DispatchQueue.main.async {
                self.isGeneratingCertificate = false
                completion(certificateImage)
            }
        }
    }
    
    // MARK: - 创建奖状图片
    private func createCertificateImage(_ gameSession: GameSession) -> UIImage? {
        // 获取用户名称
        let userName = storageService.loadUserProfile()?.nickname ?? "Mathaxy 小勇士"
        
        // 创建奖状视图
        let certificateView = CertificateGenerationView(
            gameSession: gameSession,
            userName: userName
        )
        
        // 渲染为图片
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 800))
        return renderer.image { context in
            certificateView.layer.render(in: context.cgContext)
        }
    }
    
    // MARK: - 保存奖状到相册
    func saveCertificateToPhotoLibrary(_ image: UIImage, completion: @escaping (Bool, String) -> Void) {
        certificateGenerator.saveCertificate(image: image) { success, message in
            DispatchQueue.main.async {
                completion(success, message)
            }
        }
    }
    
    // MARK: - 获取成就描述
    func getAchievementDescription(for gameSession: GameSession) -> String {
        let accuracy = gameSession.accuracy
        
        if accuracy >= 0.95 {
            return LocalizedKeys.perfectPerformance.localized
        } else if accuracy >= 0.85 {
            return LocalizedKeys.excellentPerformance.localized
        } else if accuracy >= 0.7 {
            return LocalizedKeys.goodPerformance.localized
        } else {
            return LocalizedKeys.needsImprovement.localized
        }
    }
    
    // MARK: - 获取建议
    func getSuggestion(for gameSession: GameSession) -> String {
        let accuracy = gameSession.accuracy
        let averageTime = gameSession.averageTimePerQuestion
        
        if accuracy < 0.7 {
            return LocalizedKeys.practiceMore.localized
        } else if averageTime > 10.0 {
            return LocalizedKeys.tryFaster.localized
        } else if accuracy < 0.9 {
            return LocalizedKeys.improveAccuracy.localized
        } else {
            return LocalizedKeys.keepUpGoodWork.localized
        }
    }
    
    // MARK: - 检查是否解锁新内容
    func checkForUnlocks(_ gameSession: GameSession) -> [String] {
        var unlocks: [String] = []
        
        // 检查是否解锁新关卡
        if gameSession.level < GameConstants.totalLevels {
            unlocks.append(LocalizedKeys.nextLevelUnlocked.localized)
        }
        
        // 检查是否获得新勋章
        if starRating >= 3 {
            unlocks.append(LocalizedKeys.perfectBadgeUnlocked.localized)
        }
        
        // 检查是否解锁新角色
        if gameSession.level >= 10 && gameSession.accuracy >= 0.9 {
            unlocks.append(LocalizedKeys.newCharacterUnlocked.localized)
        }
        
        return unlocks
    }
    
    // MARK: - 获取下次游戏建议
    func getNextGameSuggestion(_ gameSession: GameSession) -> String {
        if gameSession.accuracy < 0.7 {
            // 建议重玩当前关卡
            return LocalizedKeys.retryCurrentLevel.localized
        } else if gameSession.level < GameConstants.totalLevels {
            // 建议进入下一关
            return String(format: LocalizedKeys.tryNextLevel.localized, gameSession.level + 1)
        } else {
            // 已完成所有关卡
            return LocalizedKeys.allLevelsCompleted.localized
        }
    }
}

// MARK: - 奖状内容视图
private class CertificateContentView: UIView {
    let gameSession: GameSession
    
    init(gameSession: GameSession) {
        self.gameSession = gameSession
        super.init(frame: CGRect(x: 0, y: 0, width: 600, height: 800))
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 绘制奖状内容
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 设置背景
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // 绘制边框
        context.setStrokeColor(UIColor.systemYellow.cgColor)
        context.setLineWidth(5)
        context.addRect(CGRect(x: 10, y: 10, width: rect.width - 20, height: rect.height - 20))
        context.strokePath()
        
        // 绘制标题
        let titleText = "Mathaxy 成就奖状"
        let titleFont = UIFont.systemFont(ofSize: 36, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.systemBlue
        ]
        let titleSize = titleText.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: (rect.width - titleSize.width) / 2,
            y: 50,
            width: titleSize.width,
            height: titleSize.height
        )
        titleText.draw(in: titleRect, withAttributes: titleAttributes)
        
        // 绘制副标题
        let subtitleText = "授予"
        let subtitleFont = UIFont.systemFont(ofSize: 24, weight: .medium)
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: subtitleFont,
            .foregroundColor: UIColor.systemPurple
        ]
        let subtitleSize = subtitleText.size(withAttributes: subtitleAttributes)
        let subtitleRect = CGRect(
            x: (rect.width - subtitleSize.width) / 2,
            y: 120,
            width: subtitleSize.width,
            height: subtitleSize.height
        )
        subtitleText.draw(in: subtitleRect, withAttributes: subtitleAttributes)
        
        // 绘制用户名称
        let userNameText = "Mathaxy 小勇士"
        let userNameFont = UIFont.systemFont(ofSize: 32, weight: .bold)
        let userNameAttributes: [NSAttributedString.Key: Any] = [
            .font: userNameFont,
            .foregroundColor: UIColor.systemOrange
        ]
        let userNameSize = userNameText.size(withAttributes: userNameAttributes)
        let userNameRect = CGRect(
            x: (rect.width - userNameSize.width) / 2,
            y: 180,
            width: userNameSize.width,
            height: userNameSize.height
        )
        userNameText.draw(in: userNameRect, withAttributes: userNameAttributes)
        
        // 绘制成就描述
        let achievementText = "在数学学习中表现优异"
        let achievementFont = UIFont.systemFont(ofSize: 20)
        let achievementAttributes: [NSAttributedString.Key: Any] = [
            .font: achievementFont,
            .foregroundColor: UIColor.systemBlue
        ]
        let achievementSize = achievementText.size(withAttributes: achievementAttributes)
        let achievementRect = CGRect(
            x: (rect.width - achievementSize.width) / 2,
            y: 250,
            width: achievementSize.width,
            height: achievementSize.height
        )
        achievementText.draw(in: achievementRect, withAttributes: achievementAttributes)
        
        // 绘制统计信息
        let statsText = String(format: "关卡: %d | 正确率: %.1f%% | 用时: %.0f秒", 
                              gameSession.level, 
                              gameSession.accuracy * 100, 
                              gameSession.totalTime)
        let statsFont = UIFont.systemFont(ofSize: 18)
        let statsAttributes: [NSAttributedString.Key: Any] = [
            .font: statsFont,
            .foregroundColor: UIColor.systemBlue
        ]
        let statsSize = statsText.size(withAttributes: statsAttributes)
        let statsRect = CGRect(
            x: (rect.width - statsSize.width) / 2,
            y: 350,
            width: statsSize.width,
            height: statsSize.height
        )
        statsText.draw(in: statsRect, withAttributes: statsAttributes)
        
        // 绘制签名
        let signatureText = "Mathaxy Team"
        let signatureFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        let signatureAttributes: [NSAttributedString.Key: Any] = [
            .font: signatureFont,
            .foregroundColor: UIColor.systemPurple
        ]
        let signatureSize = signatureText.size(withAttributes: signatureAttributes)
        let signatureRect = CGRect(
            x: (rect.width - signatureSize.width) / 2,
            y: rect.height - 100,
            width: signatureSize.width,
            height: signatureSize.height
        )
        signatureText.draw(in: signatureRect, withAttributes: signatureAttributes)
        
        // 绘制日期
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateText = dateFormatter.string(from: Date())
        let dateFont = UIFont.systemFont(ofSize: 14)
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: dateFont,
            .foregroundColor: UIColor.systemPurple
        ]
        let dateSize = dateText.size(withAttributes: dateAttributes)
        let dateRect = CGRect(
            x: (rect.width - dateSize.width) / 2,
            y: rect.height - 60,
            width: dateSize.width,
            height: dateSize.height
        )
        dateText.draw(in: dateRect, withAttributes: dateAttributes)
    }
}