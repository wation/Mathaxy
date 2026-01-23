#!/bin/bash

# Mathaxy AI 图片资源添加脚本
# 此脚本将生成的图片资源添加到 Xcode 项目中

echo "📦 Mathaxy AI 图片资源添加工具"
echo "============================="
echo

# 检查 Xcode 项目文件
PROJECT_FILE="Mathaxy.xcodeproj"
if [ ! -d "$PROJECT_FILE" ]; then
    echo "❌ Xcode 项目文件不存在: $PROJECT_FILE"
    exit 1
fi

# 定义资源目录
ASSETS_DIR="Mathaxy/Resources/Assets.xcassets"
IMAGES_SOURCE_DIR="Images"

# 检查 Assets 目录
if [ ! -d "$ASSETS_DIR" ]; then
    echo "❌ Assets 目录不存在: $ASSETS_DIR"
    exit 1
fi

# 1. 添加 APP 图标
echo -e "\n📱 添加 APP 图标..."
APP_ICON_SOURCE="$IMAGES_SOURCE_DIR/AppIcon/app_icon.png"
APP_ICON_DEST="$ASSETS_DIR/AppIcon.appiconset"

if [ -f "$APP_ICON_SOURCE" ]; then
    # 复制到 AppIcon 目录
    cp "$APP_ICON_SOURCE" "$APP_ICON_DEST/icon_768x768.png"
    echo "✅ APP 图标已添加"
else
    echo "❌ APP 图标文件不存在: $APP_ICON_SOURCE"
fi

# 2. 添加启动页
echo -e "\n🎬 添加启动页..."
LAUNCH_SCREEN_SOURCE="$IMAGES_SOURCE_DIR/LaunchScreen/launch_screen.png"
LAUNCH_SCREEN_DEST="$ASSETS_DIR/LaunchImage.imageset"

if [ -f "$LAUNCH_SCREEN_SOURCE" ]; then
    # 创建 LaunchImage 目录
    mkdir -p "$LAUNCH_SCREEN_DEST"
    
    # 复制启动页图片
    cp "$LAUNCH_SCREEN_SOURCE" "$LAUNCH_SCREEN_DEST/launch_screen.png"
    
    # 创建 Contents.json
    cat > "$LAUNCH_SCREEN_DEST/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "launch_screen.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "launch_screen.png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "launch_screen.png",
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    echo "✅ 启动页已添加"
    else
        echo "❌ 启动页文件不存在: $LAUNCH_SCREEN_SOURCE"
fi

# 3. 添加界面功能配图
echo -e "\n🎮 添加界面功能配图..."
FUNCTION_IMAGES_SOURCE="$IMAGES_SOURCE_DIR/FunctionImages"
FUNCTION_IMAGES_DEST="$ASSETS_DIR"

for i in {1..4}; do
    SOURCE_FILE="$FUNCTION_IMAGES_SOURCE/function_$i.png"
    DEST_DIR="$FUNCTION_IMAGES_DEST/function_$i.imageset"
    
    if [ -f "$SOURCE_FILE" ]; then
        mkdir -p "$DEST_DIR"
        cp "$SOURCE_FILE" "$DEST_DIR/function_$i.png"
        
        # 创建 Contents.json
        cat > "$DEST_DIR/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "function_\(i).png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "function_\(i).png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "function_\(i).png",
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
        echo "✅ 界面功能配图 $i 已添加"
    else
        echo "❌ 界面功能配图 $i 文件不存在: $SOURCE_FILE"
    fi
done

# 4. 添加知识点讲解配图
echo -e "\n📚 添加知识点讲解配图..."
KNOWLEDGE_IMAGES_SOURCE="$IMAGES_SOURCE_DIR/KnowledgeImages"
KNOWLEDGE_IMAGES_DEST="$ASSETS_DIR"

for i in {1..4}; do
    SOURCE_FILE="$KNOWLEDGE_IMAGES_SOURCE/knowledge_$i.png"
    DEST_DIR="$KNOWLEDGE_IMAGES_DEST/knowledge_$i.imageset"
    
    if [ -f "$SOURCE_FILE" ]; then
        mkdir -p "$DEST_DIR"
        cp "$SOURCE_FILE" "$DEST_DIR/knowledge_$i.png"
        
        # 创建 Contents.json
        cat > "$DEST_DIR/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "knowledge_\(i).png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "knowledge_\(i).png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "knowledge_\(i).png",
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
        echo "✅ 知识点讲解配图 $i 已添加"
    else
        echo "❌ 知识点讲解配图 $i 文件不存在: $SOURCE_FILE"
    fi
done

# 5. 添加奖励成就配图
echo -e "\n🏆 添加奖励成就配图..."
ACHIEVEMENT_IMAGES_SOURCE="$IMAGES_SOURCE_DIR/AchievementImages"
ACHIEVEMENT_IMAGES_DEST="$ASSETS_DIR"

for i in {1..4}; do
    SOURCE_FILE="$ACHIEVEMENT_IMAGES_SOURCE/achievement_$i.png"
    DEST_DIR="$ACHIEVEMENT_IMAGES_DEST/achievement_$i.imageset"
    
    if [ -f "$SOURCE_FILE" ]; then
        mkdir -p "$DEST_DIR"
        cp "$SOURCE_FILE" "$DEST_DIR/achievement_$i.png"
        
        # 创建 Contents.json
        cat > "$DEST_DIR/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "achievement_\(i).png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "achievement_\(i).png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "achievement_\(i).png",
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
        echo "✅ 奖励成就配图 $i 已添加"
    else
        echo "❌ 奖励成就配图 $i 文件不存在: $SOURCE_FILE"
    fi
done

# 6. 添加引导页
echo -e "\n🧭 添加引导页..."
GUIDE_SCREENS_SOURCE="$IMAGES_SOURCE_DIR/GuideScreens"
GUIDE_SCREENS_DEST="$ASSETS_DIR"

for i in {1..3}; do
    SOURCE_FILE="$GUIDE_SCREENS_SOURCE/guide_$i.png"
    DEST_DIR="$GUIDE_SCREENS_DEST/guide_$i.imageset"
    
    if [ -f "$SOURCE_FILE" ]; then
        mkdir -p "$DEST_DIR"
        cp "$SOURCE_FILE" "$DEST_DIR/guide_$i.png"
        
        # 创建 Contents.json
        cat > "$DEST_DIR/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "guide_\(i).png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "guide_\(i).png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "guide_\(i).png",
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
        echo "✅ 引导页 $i 已添加"
    else
        echo "❌ 引导页 $i 文件不存在: $SOURCE_FILE"
    fi
done

echo -e "\n🎉 图片资源添加完成！"
echo "📁 所有图片已添加到: $ASSETS_DIR"
echo -e "\n📝 下一步操作:"
echo "1. 打开 Xcode 项目"
echo "2. 检查 Assets.xcassets 中的资源"
echo "3. 在代码中引用新添加的图片资源"
