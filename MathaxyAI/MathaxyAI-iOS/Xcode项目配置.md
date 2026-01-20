# Mathaxy iOS Xcode项目配置

## 如何在Xcode中打开项目

由于SwiftUI项目通常需要通过Xcode创建和管理，以下是两种方式：

### 方式一：使用Xcode创建新项目（推荐）

1. 打开Xcode
2. 选择 "File" > "New" > "Project"
3. 选择 "iOS" > "App"
4. 填写以下信息：
   - Product Name: Mathaxy
   - Team: 选择你的开发团队
   - Organization Identifier: com.beverg
   - Bundle Identifier: com.beverg.mathaxywt
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None
5. 选择保存位置：`MathaxyAI/MathaxyAI-iOS/`
6. 点击 "Create"

7. 将已创建的文件替换为项目中的文件：
   - 删除Xcode自动生成的文件
   - 将`MathaxyAI/MathaxyAI-iOS/Mathaxy/`目录下的所有文件复制到Xcode项目目录

### 方式二：手动配置项目

1. 在Xcode中创建一个空的iOS App项目
2. 将`MathaxyAI/MathaxyAI-iOS/Mathaxy/`目录下的所有文件复制到Xcode项目目录
3. 确保项目结构正确

## 项目配置

### Info.plist

已创建`Mathaxy/Info.plist`文件，包含以下配置：

- Bundle ID: `com.beverg.mathaxywt`
- 最低版本: iOS 18
- 支持的界面方向: 仅竖屏
- 支持的语言: 中文（简体）、繁体中文、英文、日语、韩语、西班牙语、葡萄牙语
- 相册权限: 用于保存奖状

### 本地化配置

已创建以下本地化字符串文件：

- `Mathaxy/Localization/zh-Hans.lproj/Localizable.strings` - 中文（简体）
- `Mathaxy/Localization/en.lproj/Localizable.strings` - 英文

待完成：

- `Mathaxy/Localization/zh-Hant.lproj/Localizable.strings` - 繁体中文
- `Mathaxy/Localization/ja.lproj/Localizable.strings` - 日语
- `Mathaxy/Localization/ko.lproj/Localizable.strings` - 韩语
- `Mathaxy/Localization/es.lproj/Localizable.strings` - 西班牙语
- `Mathaxy/Localization/pt.lproj/Localizable.strings` - 葡萄牙语

### 项目依赖

当前项目使用系统框架，无需额外的依赖：

- SwiftUI
- Foundation
- UIKit
- AVFoundation（音效）
- PhotosUI（相册访问）

后续需要添加的依赖：

- Google Mobile Ads SDK（用于广告）

## 项目结构

```
MathaxyAI-iOS/
├── Mathaxy/
│   ├── App/                          # 应用入口
│   │   ├── MathaxyApp.swift
│   │   └── Info.plist
│   ├── Modules/                       # 功能模块（MVVM）
│   │   ├── Login/                    # 登录模块
│   │   │   ├── View/
│   │   │   │   └── LoginView.swift
│   │   │   ├── ViewModel/
│   │   │   │   └── LoginViewModel.swift
│   │   │   └── Model/
│   │   │       └── UserProfile.swift
│   │   ├── Game/                     # 游戏模块
│   │   │   ├── View/
│   │   │   ├── ViewModel/
│   │   │   └── Model/
│   │   │       ├── Question.swift
│   │   │       └── GameSession.swift
│   │   ├── Achievement/              # 成就模块
│   │   │   ├── View/
│   │   │   ├── ViewModel/
│   │   │   └── Model/
│   │   │       └── GuideCharacter.swift
│   │   ├── Settings/                # 设置模块
│   │   │   ├── View/
│   │   │   ├── ViewModel/
│   │   │   └── Model/
│   │   │       └── AppSettings.swift
│   │   └── Home/                    # 首页模块
│   │       ├── View/
│   │       │   └── HomeView.swift
│   │       └── ViewModel/
│   │           └── HomeViewModel.swift
│   ├── Services/                     # 服务层
│   │   ├── StorageService.swift
│   │   ├── QuestionGenerator.swift
│   │   ├── LocalizationService.swift
│   │   ├── LoginTrackingService.swift
│   │   ├── SoundService.swift
│   │   └── AdService.swift
│   ├── Models/                       # 数据模型
│   │   ├── GameConstants.swift
│   │   └── LevelConfig.swift
│   ├── Resources/                    # 资源文件
│   │   ├── Assets.xcassets/
│   │   ├── Sounds/
│   │   └── Colors/
│   ├── Localization/                 # 多语言支持
│   │   ├── zh-Hans.lproj/
│   │   ├── zh-Hant.lproj/
│   │   ├── en.lproj/
│   │   ├── ja.lproj/
│   │   ├── ko.lproj/
│   │   ├── es.lproj/
│   │   └── pt.lproj/
│   └── Utils/                        # 工具类
│       ├── Extensions/
│       │   ├── Color+Extensions.swift
│       │   └── View+Extensions.swift
│       └── Helpers/
│           ├── DateHelper.swift
│           └── CertificateGenerator.swift
└── README.md
```

## 下一步

1. 在Xcode中创建新项目
2. 将项目文件复制到Xcode项目目录
3. 配置项目的Build Settings
4. 添加资源文件（图片、音效等）
5. 完成剩余的View和ViewModel文件
6. 测试应用

## 注意事项

### COPPA合规

- 涉及广告需调用App Tracking Transparency框架获取用户授权
- 遵守儿童隐私政策
- 所有数据本地存储，不上传服务器

### 权限管理

- 相册访问权限：用于保存奖状
- 首次使用时弹窗说明权限用途（多语言适配）

### 广告配置

- 当前使用测试广告位
- 发布前需替换为真实广告位ID
- 遵守Google AdMob政策

## 开发规范

- 所有代码需添加清晰的中文注释
- 系统权限相关逻辑必须重点标注
- 遵循Swift编码规范
- 使用SwiftUI最佳实践

---

**文档版本**: v1.0  
**创建日期**: 2026-01-19
