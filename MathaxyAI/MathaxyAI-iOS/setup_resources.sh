#!/bin/bash

# Mathaxy iOS 资源准备脚本
# 此脚本创建所有必要的目录结构和配置文件

set -e

BASE_DIR="MathaxyAI/MathaxyAI-iOS/Mathaxy/Resources/Assets.xcassets"
SOUNDS_DIR="MathaxyAI/MathaxyAI-iOS/Mathaxy/Resources/Sounds"

echo "🚀 开始创建 Mathaxy iOS 资源结构..."

# 创建背景图片目录
echo "📁 创建背景图片目录..."
mkdir -p "$BASE_DIR/home_background.imageset"
mkdir -p "$BASE_DIR/game_background.imageset"
mkdir -p "$BASE_DIR/level_select_background.imageset"

# 创建卡通角色目录
echo "📁 创建卡通角色目录..."
mkdir -p "$BASE_DIR/panda_character.imageset"
mkdir -p "$BASE_DIR/rabbit_character.imageset"

# 创建勋章目录
echo "📁 创建勋章目录..."
mkdir -p "$BASE_DIR/level_complete_badge.imageset"
mkdir -p "$BASE_DIR/speed_master_badge.imageset"
mkdir -p "$BASE_DIR/quiz_genius_badge.imageset"
mkdir -p "$BASE_DIR/persistence_master_badge.imageset"

# 创建按钮和UI元素目录
echo "📁 创建按钮和UI元素目录..."
mkdir -p "$BASE_DIR/start_game_button.imageset"
mkdir -p "$BASE_DIR/continue_game_button.imageset"
mkdir -p "$BASE_DIR/settings_button.imageset"
mkdir -p "$BASE_DIR/close_button.imageset"

# 创建游戏元素目录
echo "📁 创建游戏元素目录..."
mkdir -p "$BASE_DIR/correct_icon.imageset"
mkdir -p "$BASE_DIR/incorrect_icon.imageset"
mkdir -p "$BASE_DIR/timer_icon.imageset"
mkdir -p "$BASE_DIR/level_icon.imageset"

# 创建其他目录
echo "📁 创建其他目录..."
mkdir -p "$BASE_DIR/empty_state.imageset"
mkdir -p "$BASE_DIR/error_state.imageset"

# 创建音效目录
echo "📁 创建音效目录..."
mkdir -p "$SOUNDS_DIR"

echo "✅ 目录结构创建完成！"
echo ""
echo "📝 下一步：创建 Contents.json 配置文件..."
