//
//  LevelConfig.swift
//  Mathaxy
//
//  关卡配置文件
//  定义10个关卡的详细配置信息
//

import Foundation

// MARK: - 关卡配置结构体
struct LevelConfig {
    /// 关卡编号
    let level: Int
    
    /// 游戏模式
    let mode: GameMode
    
    /// 总时长（秒）- 仅总时长模式使用
    let totalTime: Double?
    
    /// 单题时间限制（秒）- 仅单题倒计时模式使用
    let perQuestionTime: Double?
    
    /// 最大错误次数（仅单题倒计时模式使用）
    let maxErrors: Int
    
    /// 关卡描述
    let description: String
    
    /// 获取指定关卡的配置
    static func getLevelConfig(_ level: Int) -> LevelConfig {
        switch level {
        case 1:
            return LevelConfig(
                level: 1,
                mode: .totalTime,
                totalTime: 300,  // 5分钟
                perQuestionTime: nil,
                maxErrors: 0,
                description: "总时长5分钟（平均15秒/题）"
            )
        case 2:
            return LevelConfig(
                level: 2,
                mode: .totalTime,
                totalTime: 240,  // 4分钟
                perQuestionTime: nil,
                maxErrors: 0,
                description: "总时长4分钟（平均12秒/题）"
            )
        case 3:
            return LevelConfig(
                level: 3,
                mode: .totalTime,
                totalTime: 180,  // 3分钟
                perQuestionTime: nil,
                maxErrors: 0,
                description: "总时长3分钟（平均9秒/题）"
            )
        case 4:
            return LevelConfig(
                level: 4,
                mode: .totalTime,
                totalTime: 120,  // 2分钟
                perQuestionTime: nil,
                maxErrors: 0,
                description: "总时长2分钟（平均6秒/题）"
            )
        case 5:
            return LevelConfig(
                level: 5,
                mode: .totalTime,
                totalTime: 90,  // 1分30秒
                perQuestionTime: nil,
                maxErrors: 0,
                description: "总时长1分30秒（平均4.5秒/题）"
            )
        case 6:
            return LevelConfig(
                level: 6,
                mode: .totalTime,
                totalTime: 60.0,  // 60秒总时长
                perQuestionTime: nil,
                maxErrors: GameConstants.maxErrorsPerLevel,
                description: "总时长60秒"
            )
        case 7:
            return LevelConfig(
                level: 7,
                mode: .perQuestion,
                totalTime: nil,
                perQuestionTime: 5.0,  // 5秒
                maxErrors: GameConstants.maxErrorsPerLevel,
                description: "每题5秒"
            )
        case 8:
            return LevelConfig(
                level: 8,
                mode: .perQuestion,
                totalTime: nil,
                perQuestionTime: 4.0,  // 4秒
                maxErrors: GameConstants.maxErrorsPerLevel,
                description: "每题4秒"
            )
        case 9:
            return LevelConfig(
                level: 9,
                mode: .perQuestion,
                totalTime: nil,
                perQuestionTime: 3.0,  // 3秒
                maxErrors: GameConstants.maxErrorsPerLevel,
                description: "每题3秒"
            )
        case 10:
            return LevelConfig(
                level: 10,
                mode: .perQuestion,
                totalTime: nil,
                perQuestionTime: 2.5,  // 2.5秒
                maxErrors: GameConstants.maxErrorsPerLevel,
                description: "每题2.5秒"
            )
        default:
            return LevelConfig(
                level: 1,
                mode: .totalTime,
                totalTime: 300,
                perQuestionTime: nil,
                maxErrors: 0,
                description: "总时长5分钟（平均15秒/题）"
            )
        }
    }
    
    /// 计时上限（秒）兼容层：用于旧代码中统一读取关卡的“计时上限”概念。
    ///
    /// - 总时长模式（第1-6关）：返回 `totalTime`（整关倒计时总时长）。
    /// - 单题倒计时模式（第7-10关）：返回 `perQuestionTime`（单题倒计时上限）。
    ///
    /// 说明：该属性完全由现有字段计算得到，不改变任何存量配置/加载格式，仅用于兼容视图层对 `timeLimit` 的历史引用。
    var timeLimit: Double {
        switch mode {
        case .totalTime:
            // 兜底：若配置缺失，回退到“默认每题时间 * 题数”的总时长估算。
            return totalTime ?? (GameConstants.timePerQuestion * Double(GameConstants.questionsPerLevel))
        case .perQuestion:
            // 兜底：若配置缺失，回退到默认每题时间。
            return perQuestionTime ?? GameConstants.timePerQuestion
        }
    }
    
    /// 计算平均每题时间（仅总时长模式）
    var averageTimePerQuestion: Double? {
        guard mode == .totalTime, let totalTime = totalTime else {
            return nil
        }
        return totalTime / Double(GameConstants.questionsPerLevel)
    }
}
