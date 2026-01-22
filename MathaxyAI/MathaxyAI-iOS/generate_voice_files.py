#!/usr/bin/env python3
# Mathaxy iOS 语音文件生成脚本
# 此脚本使用 gTTS 库生成游戏所需的语音文件

import os
import sys
from gtts import gTTS

# 音效目录
SOUNDS_DIR = "/Users/yanzhe/workspace/Mathaxy/MathaxyAI/MathaxyAI-iOS/Mathaxy/Resources/Sounds"

# 支持的语言
LANGUAGES = {
    "zh-Hans": "zh-cn",  # 中文（简体）
    "zh-Hant": "zh-tw",  # 繁体中文
    "en": "en",          # 英文
    "ja": "ja",          # 日语
    "ko": "ko",          # 韩语
    "es": "es",          # 西班牙语
    "pt": "pt"           # 葡萄牙语
}

# 语音内容
VOICE_CONTENT = {
    "correct": {
        "zh-Hans": "答对了！",
        "zh-Hant": "答對了！",
        "en": "Correct!",
        "ja": "正解！",
        "ko": "정답입니다!",
        "es": "¡Correcto!",
        "pt": "Correto!"
    },
    "incorrect": {
        "zh-Hans": "再试一次！",
        "zh-Hant": "再試一次！",
        "en": "Try again!",
        "ja": "もう一度やってみて！",
        "ko": "다시 시도해 보세요!",
        "es": "¡Inténtalo de nuevo!",
        "pt": "Tente novamente!"
    },
    "encouragement": {
        "zh-Hans": "加油！",
        "zh-Hant": "加油！",
        "en": "Keep going!",
        "ja": "頑張って！",
        "ko": "파이팅!",
        "es": "¡Ánimo!",
        "pt": "Vamos lá!"
    },
    "panda_greeting": {
        "zh-Hans": "你好，我是熊猫！",
        "zh-Hant": "你好，我是熊貓！",
        "en": "Hello, I'm Panda!",
        "ja": "こんにちは、パンダです！",
        "ko": "안녕하세요, 팬더예요!",
        "es": "¡Hola, soy Panda!",
        "pt": "Olá, sou Panda!"
    },
    "rabbit_greeting": {
        "zh-Hans": "你好，我是兔子！",
        "zh-Hant": "你好，我是兔子！",
        "en": "Hello, I'm Rabbit!",
        "ja": "こんにちは、ウサギです！",
        "ko": "안녕하세요, 토끼예요!",
        "es": "¡Hola, soy Conejo!",
        "pt": "Olá, sou Coelho!"
    }
}

def generate_voice_file(text, language, filename):
    """生成单个语音文件"""
    try:
        # 创建 gTTS 对象
        tts = gTTS(text=text, lang=language, slow=False)
        
        # 保存文件
        tts.save(filename)
        print(f"✅ 生成成功: {os.path.basename(filename)}")
        return True
    except Exception as e:
        print(f"❌ 生成失败 {os.path.basename(filename)}: {str(e)}")
        return False

def main():
    """主函数"""
    # 检查目录
    if not os.path.exists(SOUNDS_DIR):
        print(f"❌ 目录不存在: {SOUNDS_DIR}")
        sys.exit(1)
    
    print("🎵 Mathaxy 语音文件生成工具")
    print("=============================")
    print()
    
    # 检查依赖
    try:
        from gtts import gTTS
    except ImportError:
        print("⚠️  缺少依赖库 gTTS")
        print("请运行: pip3 install gtts")
        sys.exit(1)
    
    print(f"📁 输出目录: {SOUNDS_DIR}")
    print(f"🌍 支持语言: {len(LANGUAGES)} 种")
    print(f"🔊 语音类型: {len(VOICE_CONTENT)} 种")
    print()
    
    # 计算总数
    total_files = len(LANGUAGES) * len(VOICE_CONTENT)
    print(f"📝 预计生成: {total_files} 个语音文件")
    print()
    
    # 开始生成
    success_count = 0
    fail_count = 0
    
    for voice_type, contents in VOICE_CONTENT.items():
        print(f"\n🔄 生成 {voice_type} 语音...")
        
        for lang_code, content in contents.items():
            # 获取 gTTS 语言代码
            gtts_lang = LANGUAGES[lang_code]
            
            # 生成文件名
            filename = f"{voice_type}_{lang_code}.mp3"
            filepath = os.path.join(SOUNDS_DIR, filename)
            
            # 生成语音文件
            if generate_voice_file(content, gtts_lang, filepath):
                success_count += 1
            else:
                fail_count += 1
    
    print()
    print("=============================")
    print("🎉 语音文件生成完成！")
    print(f"✅ 成功: {success_count} 个")
    print(f"❌ 失败: {fail_count} 个")
    print()
    
    if success_count > 0:
        print("📁 生成的文件已保存到:")
        print(f"   {os.path.abspath(SOUNDS_DIR)}")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
