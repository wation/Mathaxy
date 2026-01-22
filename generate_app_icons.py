#!/usr/bin/env python3
# iOS AppIcon生成脚本
# 此脚本使用根目录下的AppIcon.png生成所有需要的iOS图标尺寸

import os
import sys
from PIL import Image

# 根目录
ROOT_DIR = "/Users/yanzhe/workspace/Mathaxy"
# 输入图标路径
INPUT_ICON_PATH = os.path.join(ROOT_DIR, "AppIcon.png")
# 输出目录
OUTPUT_DIR = os.path.join(ROOT_DIR, "MathaxyAI", "MathaxyAI-iOS", "Mathaxy", "Resources", "Assets.xcassets", "AppIcon.appiconset")

# 需要生成的图标尺寸（尺寸，文件名）
ICON_SIZES = [
    (1024, 1024, "AppIcon.png"),           # 通用
    (180, 180, "icon_180x180.png"),         # iPhone 60x60@3x
    (120, 120, "icon_120x120.png"),         # iPhone 60x60@2x
    (167, 167, "icon_167x167.png"),         # iPad 83.5x83.5@2x
    (152, 152, "icon_152x152.png"),         # iPad 76x76@2x
    (76, 76, "icon_76x76.png"),             # iPad 76x76@1x
    (80, 80, "icon_40x40.png"),             # iPhone 40x40@2x
    (58, 58, "icon_29x29.png"),             # iPhone 29x29@2x
    (40, 40, "icon_20x20.png"),             # iPhone 20x20@2x
]

def resize_image(input_path, output_path, size):
    """调整图片尺寸"""
    try:
        # 打开图片
        with Image.open(input_path) as img:
            # 调整尺寸
            resized_img = img.resize(size, Image.Resampling.LANCZOS)
            # 保存图片
            resized_img.save(output_path, "PNG")
            print(f"✅ 生成成功: {os.path.basename(output_path)} ({size[0]}x{size[1]})")
            return True
    except Exception as e:
        print(f"❌ 生成失败 {os.path.basename(output_path)}: {str(e)}")
        return False

def main():
    """主函数"""
    print("🎨 iOS AppIcon生成工具")
    print("=====================")
    print()
    
    # 检查输入文件
    if not os.path.exists(INPUT_ICON_PATH):
        print(f"❌ 输入文件不存在: {INPUT_ICON_PATH}")
        sys.exit(1)
    
    print(f"📁 输入文件: {INPUT_ICON_PATH}")
    
    # 检查输出目录
    if not os.path.exists(OUTPUT_DIR):
        print(f"❌ 输出目录不存在: {OUTPUT_DIR}")
        sys.exit(1)
    
    print(f"📁 输出目录: {OUTPUT_DIR}")
    print()
    
    # 检查依赖
    try:
        from PIL import Image
    except ImportError:
        print("⚠️  缺少依赖库 PIL (Pillow)")
        print("请运行: pip3 install Pillow")
        sys.exit(1)
    
    print(f"📝 预计生成: {len(ICON_SIZES)} 个图标文件")
    print()
    
    # 开始生成
    success_count = 0
    fail_count = 0
    
    for width, height, filename in ICON_SIZES:
        output_path = os.path.join(OUTPUT_DIR, filename)
        if resize_image(INPUT_ICON_PATH, output_path, (width, height)):
            success_count += 1
        else:
            fail_count += 1
    
    print()
    print("=====================")
    print("🎉 AppIcon生成完成！")
    print(f"✅ 成功: {success_count} 个")
    print(f"❌ 失败: {fail_count} 个")
    print()
    
    if success_count > 0:
        print("📁 生成的图标已保存到:")
        print(f"   {os.path.abspath(OUTPUT_DIR)}")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
