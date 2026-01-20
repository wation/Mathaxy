//
//  CertificateGenerationView.swift
//  Mathaxy
//
//  奖状生成视图
//  用于生成奖状图片的 UIView 子类
//

import UIKit

// MARK: - 奖状生成视图
class CertificateGenerationView: UIView {
    let gameSession: GameSession
    let userName: String
    
    init(gameSession: GameSession, userName: String) {
        self.gameSession = gameSession
        self.userName = userName
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
        let titleText = LocalizedKeys.certificateOfAchievement.localized
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
        let subtitleText = LocalizedKeys.presentedTo.localized
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
        let userNameFont = UIFont.systemFont(ofSize: 32, weight: .bold)
        let userNameAttributes: [NSAttributedString.Key: Any] = [
            .font: userNameFont,
            .foregroundColor: UIColor.systemOrange
        ]
        let userNameSize = userName.size(withAttributes: userNameAttributes)
        let userNameRect = CGRect(
            x: (rect.width - userNameSize.width) / 2,
            y: 180,
            width: userNameSize.width,
            height: userNameSize.height
        )
        userName.draw(in: userNameRect, withAttributes: userNameAttributes)
        
        // 绘制成就描述
        let achievementText = getAchievementText()
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
        let statsText = String(format: "%@: %d | %@: %.1f%% | %@: %.0f",
                              LocalizedKeys.level.localized,
                              gameSession.level,
                              LocalizedKeys.accuracy.localized,
                              gameSession.accuracy * 100,
                              LocalizedKeys.time.localized,
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
            y: 700,
            width: signatureSize.width,
            height: signatureSize.height
        )
        signatureText.draw(in: signatureRect, withAttributes: signatureAttributes)
    }
    
    private func getAchievementText() -> String {
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
}
