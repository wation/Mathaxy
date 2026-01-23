#!/bin/bash

echo "🔧 修复 Assets.xcassets 中的 JSON 错误"
echo "============================="
echo

# 修复界面功能配图
for i in {1..4}; do
    echo "📦 修复 function_$i..."
    cat > "Mathaxy/Resources/Assets.xcassets/function_$i.imageset/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "function_$i.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "function_$i.png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "function_$i.png",
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
done

# 修复知识点讲解配图
for i in {1..4}; do
    echo "📦 修复 knowledge_$i..."
    cat > "Mathaxy/Resources/Assets.xcassets/knowledge_$i.imageset/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "knowledge_$i.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "knowledge_$i.png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "knowledge_$i.png",
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
done

# 修复奖励成就配图
for i in {1..4}; do
    echo "📦 修复 achievement_$i..."
    cat > "Mathaxy/Resources/Assets.xcassets/achievement_$i.imageset/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "achievement_$i.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "achievement_$i.png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "achievement_$i.png",
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
done

# 修复引导页
for i in {1..3}; do
    echo "📦 修复 guide_$i..."
    cat > "Mathaxy/Resources/Assets.xcassets/guide_$i.imageset/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "guide_$i.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "guide_$i.png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "guide_$i.png",
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
done

echo -e "\n🎉 JSON 修复完成！"
echo "📁 所有 Contents.json 文件已修复"
