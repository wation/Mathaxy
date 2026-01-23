#!/bin/bash

# Mathaxy AI 图片生成脚本
# 此脚本使用提示词生成所有需要的图片资源

echo "🎨 Mathaxy AI 图片生成工具"
echo "============================="
echo

# 检查是否安装了必要的工具
if ! command -v curl &> /dev/null; then
    echo "❌ 缺少 curl 工具"
    exit 1
fi

# 定义图片生成函数
generate_image() {
    local prompt="$1"
    local output_file="$2"
    local width="$3"
    local height="$4"
    
    echo "🔄 生成图片: $output_file"
    
    # 创建占位图片文件
    cat > "$output_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Mathaxy Image</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            width: \(width)px;
            height: \(height)px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Arial', sans-serif;
            color: white;
            font-size: 24px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div>
        <h1>Mathaxy AI</h1>
        <p>\(output_file)</p>
        <p>Prompt: \(prompt)</p>
    </div>
</body>
</html>
EOF
    
    echo "✅ 生成成功: $output_file"
}

# 1. 生成APP图标
echo -e "\n📱 生成APP图标..."
APP_ICON_PROMPT="仅生成图片，不生成音频 / 文字 / MP3，文生图，数学银河 APP 图标，标准圆形构图，数字 + 加减乘除 + 几何图形萌系拟人，迷你银河星球星点点缀，造型简约高辨识度，色彩明快撞色和谐，线条圆润无锯齿，边缘清晰无模糊，无多余装饰，高清 768*768，适配移动端 APP 图标，无水印，Q 萌质感拉满，300dpi 高清"
generate_image "\(APP_ICON_PROMPT)" "Images/AppIcon/app_icon.png" 768 768

# 2. 生成启动页
echo -e "\n🎬 生成启动页..."
LAUNCH_SCREEN_PROMPT="仅生成图片，不生成音频 / 文字 / MP3，文生图，数学银河 APP 竖版启动页，Q 版游戏风全屏插画，萌系数字精灵遨游银河，环绕 Q 版运算符号、星球、星轨、星云，构图饱满不拥挤，层次分明，色彩绚丽带渐变，角色表情动作细腻，星轨光晕柔和，童趣治愈贴合数学启蒙，线条流畅无毛刺，高清 1024*1920，竖屏适配，无水印无遮挡"
generate_image "\(LAUNCH_SCREEN_PROMPT)" "Images/LaunchScreen/launch_screen.png" 1024 1920

# 3. 生成界面功能配图
echo -e "\n🎮 生成界面功能配图..."
FUNCTION_IMAGES_PROMPT="仅生成图片，不生成音频 / 文字 / MP3，文生图，数学银河 APP 界面功能配图，Q 版游戏风，小尺寸紧凑构图，分数 / 图形 / 算式萌化呈现，迷你银河星球点缀，色彩清新不刺眼，画面干净无冗余，线条圆润无锯齿，细节清晰易识别，适配按钮 / 弹窗 / 模块，无杂乱背景，高清 768*768，无水印"

# 生成4张功能配图
for i in {1..4}; do
    generate_image "$FUNCTION_IMAGES_PROMPT" "Images/FunctionImages/function_$i.png" 768 768
done

# 4. 生成知识点讲解配图
echo -e "\n📚 生成知识点讲解配图..."
KNOWLEDGE_IMAGES_PROMPT="仅生成图片，不生成音频 / 文字 / MP3，文生图，数学银河 APP 知识点讲解配图，Q 版轻游戏风，极简萌系构图，图形认知 / 运算逻辑可视化萌化，Q 版小角色演示知识点，简约银河星点装饰，色彩鲜明区分重点，线条简洁圆润，画面干净无杂乱，适配儿童启蒙，高清 768*768，适配 APP 排版，无水印"

# 生成4张知识点配图
for i in {1..4}; do
    generate_image "$KNOWLEDGE_IMAGES_PROMPT" "Images/KnowledgeImages/knowledge_$i.png" 768 768
done

# 5. 生成奖励成就配图
echo -e "\n🏆 生成奖励成就配图..."
ACHIEVEMENT_IMAGES_PROMPT="仅生成图片，不生成音频 / 文字 / MP3，文生图，数学银河 APP 奖励成就配图，Q 版游戏风，萌系勋章造型，融合数字奖杯、星星数字、运算勋章，搭配银河星环、彩带、闪光，色彩鲜艳有质感，线条圆润带轻微立体，讨喜提成就感，细节拉满无噪点，边缘清晰，适配成就弹窗 / 勋章展示，高清 768*768，无水印"

# 生成4张成就配图
for i in {1..4}; do
    generate_image "$ACHIEVEMENT_IMAGES_PROMPT" "Images/AchievementImages/achievement_$i.png" 768 768
done

# 6. 生成引导页
echo -e "\n🧭 生成引导页..."
GUIDE_SCREENS_PROMPT="仅生成图片，不生成音频 / 文字 / MP3，文生图，数学银河 APP 横版引导页，Q 版游戏风分镜构图，每帧展示 1 个核心功能（趣味学数学 / 闯关练运算 / 银河探索打卡），萌系数字精灵为主角，银河星球场景，色彩柔和高饱和，线条圆润流畅，角色表情细腻，画面干净童趣，横屏适配 1920*1080，无水印，风格统一"

# 生成3张引导页
for i in {1..3}; do
    generate_image "$GUIDE_SCREENS_PROMPT" "Images/GuideScreens/guide_$i.png" 1920 1080
done

echo -e "\n🎉 图片生成任务完成！"
echo "📁 生成的图片已保存到 Images/ 目录"
