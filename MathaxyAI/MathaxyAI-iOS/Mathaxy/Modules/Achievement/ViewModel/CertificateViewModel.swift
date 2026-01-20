//
//  CertificateViewModel.swift
//  Mathaxy
//
//  奖状视图模型
//  管理奖状生成、保存和分享逻辑
//

import Foundation
import SwiftUI

// MARK: - 奖状视图模型
class CertificateViewModel: ObservableObject {
    
    // MARK: - 服务
    private let storageService = StorageService.shared
    private let certificateGenerator = CertificateGenerator.shared
    
    // MARK: - 发布属性
    @Published var isGeneratingCertificate = false
    @Published var certificateImage: UIImage?
    @Published var saveMessage = ""
    @Published var showSaveAlert = false
    
    // MARK: - 生成奖状
    /// 为游戏会话生成奖状
    /// - Parameters:
    ///   - gameSession: 游戏会话
    ///   - completion: 完成回调
    func generateCertificate(for gameSession: GameSession, completion: @escaping (UIImage?) -> Void) {
        isGeneratingCertificate = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 生成奖状图片
            let image = self.createCertificateImage(gameSession)
            
            DispatchQueue.main.async {
                self.isGeneratingCertificate = false
                self.certificateImage = image
                completion(image)
            }
        }
    }
    
    // MARK: - 创建奖状图片
    /// 创建奖状图片
    /// - Parameter gameSession: 游戏会话
    /// - Returns: 奖状图片
    private func createCertificateImage(_ gameSession: GameSession) -> UIImage? {
        // 创建奖状视图
        let certificateView = CertificateGenerationView(
            gameSession: gameSession,
            userName: getUserName()
        )
        
        // 渲染为图片
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 800))
        return renderer.image { context in
            certificateView.layer.render(in: context.cgContext)
        }
    }
    
    // MARK: - 保存奖状到相册
    /// 保存奖状到相册
    /// - Parameters:
    ///   - image: 奖状图片
    ///   - completion: 完成回调
    func saveCertificateToPhotoLibrary(_ image: UIImage, completion: @escaping (Bool, String) -> Void) {
        certificateGenerator.saveCertificate(image: image) { success, message in
            DispatchQueue.main.async {
                self.saveMessage = message
                self.showSaveAlert = true
                completion(success, message)
            }
        }
    }
    
    // MARK: - 获取用户名称
    /// 获取用户名称
    /// - Returns: 用户名称
    private func getUserName() -> String {
        guard let userProfile = storageService.loadUserProfile() else {
            return "Mathaxy 小勇士"
        }
        return userProfile.nickname
    }
    
    // MARK: - 获取成就描述
    /// 获取成就描述
    /// - Parameter gameSession: 游戏会话
    /// - Returns: 成就描述
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
    
    // MARK: - 获取奖状标题
    /// 获取奖状标题
    /// - Parameter gameSession: 游戏会话
    /// - Returns: 奖状标题
    func getCertificateTitle(for gameSession: GameSession) -> String {
        let accuracy = gameSession.accuracy
        
        if accuracy >= 0.95 {
            return "Mathaxy 完美大师"
        } else if accuracy >= 0.85 {
            return "Mathaxy 优秀学员"
        } else if accuracy >= 0.7 {
            return "Mathaxy 进步之星"
        } else {
            return "Mathaxy 努力学员"
        }
    }
    
    // MARK: - 获取分享内容
    /// 获取分享内容
    /// - Parameter gameSession: 游戏会话
    /// - Returns: 分享内容数组
    func getShareItems(for gameSession: GameSession) -> [Any] {
        var items: [Any] = []
        
        // 添加文本消息
        let accuracy = String(format: "%.1f%%", gameSession.accuracy * 100)
        let time = String(format: "%.0f", gameSession.totalTime)
        let message = String(format: 
            LocalizedKeys.shareMessageTemplate.localized,
            gameSession.level,
            accuracy,
            time,
            getStarRating(gameSession)
        )
        items.append(message)
        
        // 添加应用链接
        if let appURL = URL(string: "https://apps.apple.com/app/mathaxy") {
            items.append(appURL)
        }
        
        // 添加奖状图片
        if let image = certificateImage {
            items.append(image)
        }
        
        return items
    }
    
    // MARK: - 获取星级评价
    /// 获取星级评价
    /// - Parameter gameSession: 游戏会话
    /// - Returns: 星级评价（0-3）
    private func getStarRating(_ gameSession: GameSession) -> Int {
        let accuracy = gameSession.accuracy
        let averageTime = gameSession.averageTimePerQuestion
        
        if accuracy >= 0.95 && averageTime < 3.0 {
            return 3 // 三星：完美表现
        } else if accuracy >= 0.85 && averageTime < 5.0 {
            return 2 // 二星：优秀表现
        } else if accuracy >= 0.7 {
            return 1 // 一星：通过
        } else {
            return 0 // 无星：未通过
        }
    }
}

