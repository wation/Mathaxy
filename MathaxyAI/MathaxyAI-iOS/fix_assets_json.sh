#!/bin/bash

# Mathaxy AI Assets JSON 修复脚本
# 修复 Contents.json 中的转义序列错误

echo "🔧 Mathaxy AI Assets JSON 修复工具"
echo "============================="
echo

# 定义修复函数
fix_json() {
    local file="$1"
    local pattern="$2"
    local replacement="$3"
    
    if [ -f "$file" ]; then
        sed -i "" "s/$pattern/$replacement/g" "$file"
        echo "✅ 修复文件: $file"
    else
        echo "❌ 文件不存在: $file"
    fi
}

# 修复界面功能配图
for i in {1..4}; do
    file="Mathaxy/Resources/Assets.xcassets/function_$i.imageset/Contents.json"
    fix_json "$file" "function_\\\\(i)\\\.png" "function_$i.png"
done

# 修复知识点讲解配图
for i in {1..4}; do
    file="Mathaxy/Resources/Assets.xcassets/knowledge_$i.imageset/Contents.json"
    fix_json "$file" "knowledge_\\(i)\.png" "knowledge_$i.png"
done

# 修复奖励成就配图
for i in {1..4}; do
    file="Mathaxy/Resources/Assets.xcassets/achievement_$i.imageset/Contents.json"
    fix_json "$file" "achievement_\\(i)\.png" "achievement_$i.png"
done

# 修复引导页
for i in {1..3}; do
    file="Mathaxy/Resources/Assets.xcassets/guide_$i.imageset/Contents.json"
    fix_json "$file" "guide_\\(i)\.png" "guide_$i.png"
done

echo -e "\n🎉 JSON 修复完成！"
echo "📁 所有 Contents.json 文件已修复"
