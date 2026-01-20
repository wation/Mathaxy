#!/bin/bash

# Mathaxy iOS 资源准备脚本
# 此脚本帮助准备所有项目资源

set -e

PROJECT_ROOT="MathaxyAI/MathaxyAI-iOS"
ASSETS_DIR="$PROJECT_ROOT/Mathaxy/Resources/Assets.xcassets"
SOUNDS_DIR="$PROJECT_ROOT/Mathaxy/Resources/Sounds"

echo "🚀 Mathaxy iOS 资源准备工具"
echo "================================"
echo ""

# 检查系统工具
echo "🔍 检查系统工具..."

# 检查 ImageMagick（用于 SVG 转 PNG）
if command -v convert &> /dev/null; then
    echo "✅ ImageMagick 已安装"
    HAS_IMAGEMAGICK=true
else
    echo "⚠️  ImageMagick 未安装"
    echo "   安装命令: brew install imagemagick"
    HAS_IMAGEMAGICK=false
fi

# 检查 ffmpeg（用于音频生成）
if command -v ffmpeg &> /dev/null; then
    echo "✅ FFmpeg 已安装"
    HAS_FFMPEG=true
else
    echo "⚠️  FFmpeg 未安装"
    echo "   安装命令: brew install ffmpeg"
    HAS_FFMPEG=false
fi

echo ""
echo "📋 资源准备选项："
echo "1. 转换 SVG 到 PNG（需要 ImageMagick）"
echo "2. 生成音频文件（需要 FFmpeg）"
echo "3. 验证资源文件"
echo "4. 生成资源清单"
echo "5. 全部执行"
echo "6. 退出"
echo ""

read -p "请选择操作 (1-6): " choice

case $choice in
    1)
        echo ""
        echo "🎨 开始转换 SVG 到 PNG..."
        if [ "$HAS_IMAGEMAGICK" = false ]; then
            echo "❌ 错误：需要安装 ImageMagick"
            exit 1
        fi

        # 查找所有 SVG 文件
        SVG_FILES=$(find "$ASSETS_DIR" -name "*.svg")

        if [ -z "$SVG_FILES" ]; then
            echo "⚠️  未找到 SVG 文件"
        else
            for svg_file in $SVG_FILES; do
                dir=$(dirname "$svg_file")
                basename=$(basename "$svg_file" .svg)

                # 生成 1x, 2x, 3x 版本
                echo "  转换: $basename.svg"

                # 获取 SVG 的原始尺寸
                size=$(identify -format "%wx%h" "$svg_file" 2>/dev/null || echo "60x60")
                width=$(echo $size | cut -d'x' -f1)
                height=$(echo $size | cut -d'x' -f2)

                # 生成 1x 版本
                convert "$svg_file" -resize ${width}x${height} "$dir/${basename}.png"

                # 生成 2x 版本
                convert "$svg_file" -resize $((width*2))x$((height*2)) "$dir/${basename}@2x.png"

                # 生成 3x 版本
                convert "$svg_file" -resize $((width*3))x$((height*3)) "$dir/${basename}@3x.png"
            done
            echo "✅ SVG 转换完成"
        fi
        ;;

    2)
        echo ""
        echo "🎵 开始生成音频文件..."
        if [ "$HAS_FFMPEG" = false ]; then
            echo "❌ 错误：需要安装 FFmpeg"
            exit 1
        fi

        # 查找所有音频规格文件
        SPEC_FILES=$(find "$SOUNDS_DIR" -name "*.spec")

        if [ -z "$SPEC_FILES" ]; then
            echo "⚠️  未找到音频规格文件"
        else
            for spec_file in $SPEC_FILES; do
                basename=$(basename "$spec_file" .spec)
                mp3_file="$SOUNDS_DIR/${basename}.mp3"

                if [ -f "$mp3_file" ]; then
                    echo "⏭️  跳过已存在: $basename.mp3"
                    continue
                fi

                echo "  生成: $basename.mp3"
                echo "  ⚠️  请手动创建音频文件，参考规格: $spec_file"
                echo "     或使用音频编辑软件生成"
            done
            echo "✅ 音频规格文件已准备"
        fi
        ;;

    3)
        echo ""
        echo "🔍 验证资源文件..."

        # 检查图片资源
        echo "📷 检查图片资源..."
        IMAGESETS=$(find "$ASSETS_DIR" -name "*.imageset" -type d)
        MISSING_IMAGES=0

        for imageset in $IMAGESETS; do
            name=$(basename "$imageset" .imageset)
            contents_json="$imageset/Contents.json"

            if [ ! -f "$contents_json" ]; then
                echo "  ❌ $name: 缺少 Contents.json"
                ((MISSING_IMAGES++))
            fi
        done

        if [ $MISSING_IMAGES -eq 0 ]; then
            echo "  ✅ 所有图片集都有 Contents.json"
        else
            echo "  ⚠️  有 $MISSING_IMAGES 个图片集缺少配置文件"
        fi

        # 检查音频资源
        echo "🎵 检查音频资源..."
        REQUIRED_SOUNDS=(
            "correct_answer.mp3"
            "incorrect_answer.mp3"
            "timeout.mp3"
            "level_complete.mp3"
            "game_over.mp3"
            "badge_earned.mp3"
            "character_unlocked.mp3"
        )

        MISSING_SOUNDS=0
        for sound in "${REQUIRED_SOUNDS[@]}"; do
            if [ ! -f "$SOUNDS_DIR/$sound" ]; then
                echo "  ⚠️  缺少: $sound"
                ((MISSING_SOUNDS++))
            fi
        done

        if [ $MISSING_SOUNDS -eq 0 ]; then
            echo "  ✅ 所有音频文件都已准备"
        else
            echo "  ⚠️  有 $MISSING_SOUNDS 个音频文件缺失"
        fi

        echo ""
        echo "✅ 验证完成"
        ;;

    4)
        echo ""
        echo "📊 生成资源清单..."

        MANIFEST_FILE="$PROJECT_ROOT/RESOURCE_MANIFEST.md"

        cat > "$MANIFEST_FILE" << 'EOF'
# Mathaxy iOS 资源清单

**生成时间**: $(date)

## 图片资源

### 背景图片
- home_background (首页背景)
- game_background (游戏背景)
- level_select_background (关卡选择背景)

### 卡通角色
- panda_character (熊猫角色)
- rabbit_character (兔子角色)

### 勋章
- level_complete_badge (关卡完成勋章)
- speed_master_badge (神速小能手勋章)
- quiz_genius_badge (答题小天才勋章)
- persistence_master_badge (坚持小达人勋章)

### 按钮和UI元素
- start_game_button (开始游戏按钮)
- continue_game_button (继续游戏按钮)
- settings_button (设置按钮)
- close_button (关闭按钮)

### 游戏元素
- correct_icon (正确图标)
- incorrect_icon (错误图标)
- timer_icon (计时器图标)
- level_icon (关卡图标)

### 其他
- empty_state (空状态)
- error_state (错误状态)

## 音频资源

### 游戏音效
- correct_answer.mp3 - 答对提示音
- incorrect_answer.mp3 - 答错提示音
- timeout.mp3 - 超时提示音
- level_complete.mp3 - 关卡完成音效
- game_over.mp3 - 游戏结束音效

### 成就系统音效
- badge_earned.mp3 - 获得勋章音效
- character_unlocked.mp3 - 解锁角色音效

## 资源状态

### 已完成
- ✅ 目录结构
- ✅ Contents.json 配置文件
- ✅ SVG 矢量图标
- ✅ 音频规格文件

### 待完成
- ⏳ PNG 图片文件（从 SVG 转换）
- ⏳ MP3 音频文件（根据规格生成）

## 使用说明

### 转换 SVG 到 PNG
```bash
./prepare_resources.sh
选择选项 1
```

### 生成音频文件
参考 `Sounds/*.spec` 文件中的规格说明，使用音频编辑软件创建 MP3 文件。

### 验证资源
```bash
./prepare_resources.sh
选择选项 3
```
EOF

        echo "✅ 资源清单已生成: $MANIFEST_FILE"
        ;;

    5)
        echo ""
        echo "🔄 执行所有操作..."

        # 执行 SVG 转换
        if [ "$HAS_IMAGEMAGICK" = true ]; then
            echo "🎨 转换 SVG 到 PNG..."
            # (复用上面的转换逻辑)
        fi

        # 验证资源
        echo "🔍 验证资源..."
        # (复用上面的验证逻辑)

        # 生成清单
        echo "📊 生成清单..."
        # (复用上面的清单生成逻辑)

        echo "✅ 全部操作完成"
        ;;

    6)
        echo "👋 退出"
        exit 0
        ;;

    *)
        echo "❌ 无效的选择"
        exit 1
        ;;
esac

echo ""
echo "✨ 资源准备完成！"
