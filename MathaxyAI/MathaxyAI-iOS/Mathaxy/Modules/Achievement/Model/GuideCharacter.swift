//
//  GuideCharacter.swift
//  Mathaxy
//
//  卡通角色数据模型
//  定义卡通向导角色的属性和多语言消息
//

import Foundation

// MARK: - 卡通角色结构体
struct GuideCharacter: Identifiable, Codable {
    /// 角色唯一标识
    let id: UUID
    
    /// 角色类型
    let type: CharacterType
    
    /// 角色名称
    let name: String
    
    /// 解锁所需的勋章数量
    let unlockThreshold: Int
    
    /// 是否已解锁
    var isUnlocked: Bool
    
    /// 多语言消息字典
    let messages: [String: [String]]
    
    /// 初始化方法
    init(type: CharacterType, isUnlocked: Bool = false) {
        self.id = UUID()
        self.type = type
        self.name = type.displayName
        self.unlockThreshold = type.unlockThreshold
        self.isUnlocked = isUnlocked
        self.messages = GuideCharacter.getMessages(for: type)
    }
    
    /// 获取指定语言的鼓励消息
    func getRandomMessage(language: AppLanguage) -> String {
        guard let messages = messages[language.rawValue], !messages.isEmpty else {
            // 如果没有对应语言的消息，返回默认消息
            return messages["en"]?.randomElement() ?? "Great job!"
        }
        
        return messages.randomElement() ?? "Great job!"
    }
    
    /// 获取指定角色的多语言消息
    static func getMessages(for type: CharacterType) -> [String: [String]] {
        switch type {
        case .panda:
            return [
                "zh-Hans": [
                    "你好厉害呀！",
                    "太棒了！",
                    "继续加油！",
                    "你真聪明！",
                    "做得好！"
                ],
                "zh-Hant": [
                    "你好厲害呀！",
                    "太棒了！",
                    "繼續加油！",
                    "你真聰明！",
                    "做得好！"
                ],
                "en": [
                    "Great job!",
                    "Excellent!",
                    "Keep going!",
                    "You're so smart!",
                    "Well done!"
                ],
                "ja": [
                    "すごいですね！",
                    "素晴らしい！",
                    "頑張って！",
                    "賢いですね！",
                    "よくできました！"
                ],
                "ko": [
                    "훌륭해요!",
                    "멋져요!",
                    "계속해요!",
                    "똑똑하네요!",
                    "잘했어요!"
                ],
                "es": [
                    "¡Bien hecho!",
                    "¡Excelente!",
                    "¡Sigue así!",
                    "¡Eres muy inteligente!",
                    "¡Muy bien!"
                ],
                "pt": [
                    "Excelente!",
                    "Muito bem!",
                    "Continue assim!",
                    "Você é muito inteligente!",
                    "Ótimo trabalho!"
                ]
            ]
            
        case .rabbit:
            return [
                "zh-Hans": [
                    "答对啦！",
                    "再想想看？",
                    "加油哦！",
                    "你能行的！",
                    "相信自己！"
                ],
                "zh-Hant": [
                    "答對啦！",
                    "再想想看？",
                    "加油哦！",
                    "你能行的！",
                    "相信自己！"
                ],
                "en": [
                    "You got it!",
                    "Think again?",
                    "You can do it!",
                    "Believe in yourself!",
                    "Keep trying!"
                ],
                "ja": [
                    "正解です！",
                    "もう一度考えてみて？",
                    "頑張って！",
                    "できるよ！",
                    "自分を信じて！"
                ],
                "ko": [
                    "정답이에요!",
                    "다시 생각해볼까요?",
                    "힘내요!",
                    "할 수 있어요!",
                    "자신을 믿어요!"
                ],
                "es": [
                    "¡Correcto!",
                    "¿Piénsalo de nuevo?",
                    "¡Tú puedes!",
                    "¡Cree en ti mismo!",
                    "¡Sigue intentando!"
                ],
                "pt": [
                    "Correto!",
                    "Pense de novo?",
                    "Você consegue!",
                    "Acredite em si mesmo!",
                    "Continue tentando!"
                ]
            ]
        }
    }
    
    /// 获取所有预设角色
    static func getAllCharacters() -> [GuideCharacter] {
        return [
            GuideCharacter(type: .panda),
            GuideCharacter(type: .rabbit)
        ]
    }
}

// MARK: - 卡通角色消息类型
enum CharacterMessageType {
    /// 鼓励消息（答对时）
    case encouragement
    
    /// 提示消息（答错时）
    case hint
    
    /// 问候消息（解锁时）
    case greeting
}
