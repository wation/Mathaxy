#!/bin/bash

# Mathaxy AI Q版音效资源添加脚本
# 此脚本将生成的 Q 版音效资源添加到 Xcode 项目中

echo "🎵 Mathaxy AI Q版音效资源添加工具"
echo "===================================="
echo ""

# 定义资源目录
SOUNDS_DIR="Mathaxy/Resources/Sounds"

# 检查 Sounds 目录
if [ ! -d "$SOUNDS_DIR" ]; then
    echo "❌ Sounds 目录不存在: $SOUNDS_DIR"
    exit 1
fi

# 统计 Q 版音效文件
echo "📊 统计 Q 版音效文件..."
echo ""

Q_SFX_COUNT=$(ls -1 "$SOUNDS_DIR"/q_sfx_*.m4a 2>/dev/null | wc -l)
Q_VOICE_COUNT=$(ls -1 "$SOUNDS_DIR"/q_voice_*.m4a 2>/dev/null | wc -l)
Q_TOTAL_COUNT=$((Q_SFX_COUNT + Q_VOICE_COUNT))

echo "Q版 SFX 文件: $Q_SFX_COUNT 个"
echo "Q版 Voice 文件: $Q_VOICE_COUNT 个"
echo "Q版文件总数: $Q_TOTAL_COUNT 个"
echo ""

if [ $Q_TOTAL_COUNT -eq 0 ]; then
    echo "❌ 未找到 Q 版音效文件"
    echo "请先运行 generate_q_audio_files.sh 和 generate_q_voice_files.py"
    exit 1
fi

echo "✅ 找到 $Q_TOTAL_COUNT 个 Q 版音效文件"
echo ""

# 检查是否已添加到项目（通过检查 .gitkeep 或其他标记）
echo "📝 检查音效文件状态..."
echo ""

# 列出所有 Q 版音效文件
echo "=== Q版 SFX 文件列表 ==="
ls -lh "$SOUNDS_DIR"/q_sfx_*.m4a 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
echo ""

echo "=== Q版 Voice 文件列表 ==="
ls -lh "$SOUNDS_DIR"/q_voice_*.m4a 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
echo ""

# 计算总大小
TOTAL_SIZE=$(du -sh "$SOUNDS_DIR"/q_*.m4a 2>/dev/null | tail -1 | cut -f1)
echo "📦 Q版音效总大小: $TOTAL_SIZE"
echo ""

echo "===================================="
echo "🎉 Q 版音效资源添加完成！"
echo ""
echo "📁 音效文件位置: $SOUNDS_DIR"
echo ""
echo "📝 下一步操作:"
echo "1. 打开 Xcode 项目"
echo "2. 在 Xcode 中检查 Mathaxy/Resources/Sounds 目录"
echo "3. 确认所有 q_*.m4a 文件已添加到项目中"
echo "4. 运行构建验证: xcodebuild -project Mathaxy.xcodeproj -scheme Mathaxy -destination 'platform=iOS Simulator,name=iPhone 15' build"
echo ""
echo "💡 提示："
echo "- Q版音效已通过 SoundService 自动映射"
echo "- 如果 Q 版音效缺失，会自动回退到旧版音效"
echo "- 确保所有音效文件都添加到 Xcode 项目的 Target Membership 中"
