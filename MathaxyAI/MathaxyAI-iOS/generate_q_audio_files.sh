#!/bin/bash

# Mathaxy iOS Q版音效文件生成脚本
# 此脚本使用 ffmpeg 生成 Q 版风格的音效文件（q_sfx_*）

# 获取脚本所在目录的父目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOUNDS_DIR="$SCRIPT_DIR/Mathaxy/Resources/Sounds"
SAMPLE_RATE=44100  # 采样率 44.1kHz

echo "🎵 Mathaxy Q版音效文件生成工具"
echo "================================"
echo ""
echo "项目根目录: $PROJECT_ROOT"
echo "音效目录: $SOUNDS_DIR"
echo ""

# 检查 ffmpeg 是否安装
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ffmpeg 未安装，请先安装 ffmpeg"
    echo "   macOS: brew install ffmpeg"
    exit 1
fi

echo "✅ 检测到 ffmpeg: $(ffmpeg -version | head -n 1)"
echo ""

# 检查目录
if [ ! -d "$SOUNDS_DIR" ]; then
    echo "❌ 音效目录不存在: $SOUNDS_DIR"
    exit 1
fi

# Q版 SFX 音效清单
# 格式: "文件名|时长(秒)|频率(Hz)|波形类型|音量(dB)|描述"
declare -a Q_SFX_FILES=(
    # 按钮点击音效 - 3个变体
    "q_sfx_button_click_01.m4a|0.08|800|sine|-3|按钮点击音效1 - 高频正弦波"
    "q_sfx_button_click_02.m4a|0.08|600|triangle|-3|按钮点击音效2 - 中频三角波"
    "q_sfx_button_click_03.m4a|0.08|1000|sine|-4|按钮点击音效3 - 高频正弦波"
    
    # 答对音效 - 上升音调（使用单频率简化）
    "q_sfx_correct_01.m4a|0.18|659|sine:-3|答对音效 - 上升音调（E5）"
    
    # 答错音效 - 下降音调（使用单频率简化）
    "q_sfx_incorrect_01.m4a|0.22|300|triangle:-6|答错音效 - 下降音调"
    
    # 超时音效
    "q_sfx_timeout_01.m4a|0.45|350|sine:-5|超时音效 - 中频长音"
    
    # 关卡完成音效（使用单频率简化）
    "q_sfx_level_complete_01.m4a|0.95|784|sine:-4|关卡完成音效 - 高频"
    
    # 游戏结束音效（使用单频率简化）
    "q_sfx_game_over_01.m4a|0.80|200|triangle:-5|游戏结束音效 - 低频"
    
    # 游戏完成音效（使用单频率简化）
    "q_sfx_game_complete_01.m4a|1.05|1047|sine:-4|游戏完成音效 - 高频"
    
    # 获得勋章音效（使用单频率简化）
    "q_sfx_badge_earned_01.m4a|0.90|1100|sine:-5|获得勋章音效 - 高频"
    
    # 解锁角色音效（使用单频率简化）
    "q_sfx_character_unlocked_01.m4a|0.90|880|sine:-4|解锁角色音效 - 高频"
    
    # 通用错误音效
    "q_sfx_error_01.m4a|0.26|300|triangle:-6|通用错误音效 - 低频短促"
    
    # 操作成功音效（使用单频率简化）
    "q_sfx_success_01.m4a|0.37|784|sine:-4|操作成功音效 - 高频"
    
    # 跳关音效（使用单频率简化）
    "q_sfx_skip_level_01.m4a|0.70|1047|sine:-4|跳关音效 - 高频"
)

echo "📝 将生成以下 Q 版音效文件："
echo ""
for item in "${Q_SFX_FILES[@]}"; do
    filename=$(echo "$item" | cut -d'|' -f1)
    duration=$(echo "$item" | cut -d'|' -f2)
    description=$(echo "$item" | cut -d'|' -f6)
    echo "  - $filename ($duration秒) - $description"
done

echo ""
read -p "是否继续生成 Q 版音效文件？(y/n): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "❌ 已取消"
    exit 0
fi

echo ""
echo "🔄 生成 Q 版音效文件..."
echo ""

success_count=0
skip_count=0

# 生成 Q 版音效文件的函数
generate_sfx() {
    local filename=$1
    local duration=$2
    local freq=$3
    local wave_type=$4
    local volume_db=$5
    local description=$6
    local filepath="$SOUNDS_DIR/$filename"
    
    # 检查文件是否已存在且非空
    if [ -f "$filepath" ] && [ -s "$filepath" ]; then
        echo "⏭️  跳过已存在: $filename"
        return 1
    fi
    
    echo "  生成: $filename ($description)"
    
    # 计算淡出时间
    local fade_out=$(awk "BEGIN {printf \"%.3f\", $duration - 0.02}")
    
    if [ "$wave_type" == "sine" ]; then
        # 正弦波
        ffmpeg -y -f lavfi -i "sine=frequency=$freq:sample_rate=$SAMPLE_RATE:duration=$duration" \
            -af "volume=${volume_db}dB,afade=t=in:st=0:d=0.01,afade=t=out:st=$fade_out:d=0.02" \
            -c:a aac -b:a 128k -ar $SAMPLE_RATE -ac 1 "$filepath" >/dev/null 2>&1
    elif [ "$wave_type" == "triangle" ]; then
        # 三角波通过 sine 添加谐波模拟
        ffmpeg -y -f lavfi -i "sine=frequency=$freq:sample_rate=$SAMPLE_RATE:duration=$duration" \
            -f lavfi -i "sine=frequency=$((freq * 3)):sample_rate=$SAMPLE_RATE:duration=$duration" \
            -filter_complex "[0:a][1:a]amix=inputs=2:weights='0.7 0.3',volume=${volume_db}dB,afade=t=in:st=0:d=0.01,afade=t=out:st=$fade_out:d=0.02" \
            -c:a aac -b:a 128k -ar $SAMPLE_RATE -ac 1 "$filepath" >/dev/null 2>&1
    fi
    
    return 0
}

# 生成所有 Q 版音效文件
for item in "${Q_SFX_FILES[@]}"; do
    filename=$(echo "$item" | cut -d'|' -f1)
    duration=$(echo "$item" | cut -d'|' -f2)
    freq=$(echo "$item" | cut -d'|' -f3)
    wave_type=$(echo "$item" | cut -d'|' -f4)
    volume_db=$(echo "$item" | cut -d'|' -f5)
    description=$(echo "$item" | cut -d'|' -f6)
    
    if generate_sfx "$filename" "$duration" "$freq" "$wave_type" "$volume_db" "$description"; then
        success_count=$((success_count + 1))
    else
        skip_count=$((skip_count + 1))
    fi
done

echo ""
echo "✅ Q 版音效文件生成完成！"
echo ""
echo "📊 统计："
echo "  - 成功: $success_count 个"
echo "  - 跳过: $skip_count 个"
echo ""
echo "📁 文件位置: $SOUNDS_DIR"
echo ""

# 显示生成的文件信息
echo "📋 生成的文件详情："
echo ""
echo "文件名                          | 时长(秒) | 大小    | 状态"
echo "--------------------------------|----------|---------|------"

for item in "${Q_SFX_FILES[@]}"; do
    filename=$(echo "$item" | cut -d'|' -f1)
    duration=$(echo "$item" | cut -d'|' -f2)
    filepath="$SOUNDS_DIR/$filename"
    
    if [ -f "$filepath" ]; then
        file_size=$(ls -lh "$filepath" | awk '{print $5}')
        
        # 使用 ffprobe 获取实际时长
        actual_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$filepath" 2>/dev/null)
        if [ -n "$actual_duration" ]; then
            actual_duration=$(printf "%.3f" "$actual_duration")
        else
            actual_duration="N/A"
        fi
        
        # 检查文件是否为空
        if [ -s "$filepath" ]; then
            status="✅ 可播放"
        else
            status="❌ 空文件"
        fi
    else
        file_size="N/A"
        actual_duration="N/A"
        status="❌ 不存在"
    fi
    
    printf "%-30s | %-8s | %-7s | %s\n" "$filename" "$actual_duration" "$file_size" "$status"
done

echo ""
echo "💡 提示：Q 版音效风格 - 可爱、短促、轻打击乐、软弹、糖果感"
echo "   如需调整音效参数，请修改脚本中的 Q_SFX_FILES 数组"
