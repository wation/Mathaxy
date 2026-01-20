#!/bin/bash

# Mathaxy iOS 音频文件生成脚本
# 此脚本使用系统工具生成简单的音频文件

set -e

SOUNDS_DIR="MathaxyAI/MathaxyAI-iOS/Mathaxy/Resources/Sounds"

echo "🎵 Mathaxy 音频文件生成工具"
echo "================================"
echo ""

# 检查系统工具
if command -v afplay &> /dev/null; then
    echo "✅ 使用 macOS afplay 工具"
    AUDIO_TOOL="afplay"
elif command -v sox &> /dev/null; then
    echo "✅ 使用 sox 工具"
    AUDIO_TOOL="sox"
else
    echo "⚠️  未找到音频生成工具"
    echo ""
    echo "请安装以下工具之一："
    echo "  - FFmpeg: brew install ffmpeg"
    echo "  - SoX: brew install sox"
    echo ""
    echo "或使用音频编辑软件手动创建："
    echo "  - Audacity (免费)"
    echo "  - GarageBand (Mac)"
    exit 1
fi

echo ""
echo "📝 音频规格文件已准备："
ls -1 "$SOUNDS_DIR"/*.spec

echo ""
echo "⚠️  注意：此脚本仅创建占位音频文件"
echo "   建议使用专业音频编辑软件创建高质量音频"
echo ""

read -p "是否继续生成占位音频文件？(y/n): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "❌ 已取消"
    exit 0
fi

echo ""
echo "🔄 生成占位音频文件..."

# 创建占位音频文件（使用系统工具）
for spec_file in "$SOUNDS_DIR"/*.spec; do
    basename=$(basename "$spec_file" .spec)
    mp3_file="$SOUNDS_DIR/${basename}.mp3"

    if [ -f "$mp3_file" ]; then
        echo "⏭️  跳过已存在: $basename.mp3"
        continue
    fi

    echo "  生成占位: $basename.mp3"

    # 创建一个空的 MP3 文件作为占位符
    # 注意：这不是真正的音频文件，只是占位符
    # 实际的音频文件需要使用专业工具创建
    touch "$mp3_file"

    # 添加文件信息
    cat > "${mp3_file}.info" << EOF
# 占位音频文件
# 此文件仅用于占位，需要替换为实际音频

## 参考规格
请查看: $spec_file

## 创建方法
1. 使用 Audacity 打开规格文件
2. 根据规格说明创建音频
3. 导出为 MP3 格式
4. 替换此占位文件

## 在线工具
- TwistedWave Online: https://twistedwave.com
- AudioMass: https://audiomass.co
EOF
done

echo ""
echo "✅ 占位音频文件创建完成！"
echo ""
echo "📋 下一步："
echo "1. 查看 $SOUNDS_DIR 目录下的 .spec 文件"
echo "2. 使用音频编辑软件创建实际音频"
echo "3. 替换占位文件"
echo ""
echo "💡 提示：音频规格文件包含详细的技术要求和设计建议"
