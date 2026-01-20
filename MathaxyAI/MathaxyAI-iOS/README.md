# Mathaxy iOS 项目

## 项目概述

Mathaxy（数学银河）是一款面向小学一年级学生的数学加法练习游戏，通过闯关模式让用户对10以内加法形成肌肉记忆，达到看到题目2秒内快速作答的熟练程度。

## 技术栈

- **开发语言**: Swift
- **UI框架**: SwiftUI
- **架构模式**: MVVM
- **最低版本**: iOS 18
- **目标设备**: iPhone 13及以上 + iPad（仅竖屏布局）
- **Bundle ID**: com.beverg.mathaxywt

## 项目结构

```
MathaxyAI-iOS/
├── Mathaxy/
│   ├── App/                          # 应用入口
│   ├── Modules/                       # 功能模块
│   │   ├── Login/                    # 登录模块
│   │   │   ├── View/
│   │   │   ├── ViewModel/
│   │   │   └── Model/
│   │   ├── Game/                     # 游戏模块
│   │   │   ├── View/
│   │   │   ├── ViewModel/
│   │   │   └── Model/
│   │   ├── Achievement/              # 成就模块
│   │   │   ├── View/
│   │   │   ├── ViewModel/
│   │   │   └── Model/
│   │   ├── Settings/                # 设置模块
│   │   │   ├── View/
│   │   │   ├── ViewModel/
│   │   │   └── Model/
│   │   └── Home/                    # 首页模块
│   │       ├── View/
│   │       └── ViewModel/
│   ├── Services/                     # 服务层
│   │   ├── StorageService.swift       # 数据存储服务
│   │   ├── QuestionGenerator.swift    # 题目生成引擎
│   │   ├── AdService.swift          # 广告服务
│   │   ├── SoundService.swift       # 音效服务
│   │   ├── LocalizationService.swift  # 本地化服务
│   │   └── LoginTrackingService.swift # 登录追踪服务
│   ├── Models/                       # 数据模型
│   │   ├── GameConstants.swift       # 游戏常量
│   │   └── LevelConfig.swift       # 关卡配置
│   ├── Resources/                    # 资源文件
│   │   ├── Assets.xcassets/
│   │   ├── Sounds/
│   │   └── Colors/
│   ├── Localization/                 # 多语言支持
│   │   ├── zh-Hans.lproj/         # 中文（简体）
│   │   ├── zh-Hant.lproj/         # 繁体中文
│   │   ├── en.lproj/             # 英文
│   │   ├── ja.lproj/             # 日语
│   │   ├── ko.lproj/             # 韩语
│   │   ├── es.lproj/             # 西班牙语
│   │   └── pt.lproj/             # 葡萄牙语
│   └── Utils/                        # 工具类
│       ├── Extensions/            # 扩展
│       │   ├── Color+Extensions.swift
│       │   └── View+Extensions.swift
│       └── Helpers/              # 助手类
│           ├── DateHelper.swift
│           └── CertificateGenerator.swift
```

## 已完成的工作

### 1. 数据模型层 ✅

- **GameConstants.swift**: 游戏常量定义（关卡数、勋章类型、语言列表等）
- **LevelConfig.swift**: 关卡配置（10个关卡的详细配置）
- **Question.swift**: 题目数据模型
- **GameSession.swift**: 游戏会话数据模型
- **UserProfile.swift**: 用户数据模型
- **GuideCharacter.swift**: 卡通角色数据模型
- **AppSettings.swift**: 应用设置数据模型

### 2. 服务层 ✅

- **StorageService.swift**: 数据存储服务（UserDefaults + FileManager）
- **QuestionGenerator.swift**: 题目生成引擎
- **LocalizationService.swift**: 本地化服务
- **LoginTrackingService.swift**: 登录追踪服务
- **SoundService.swift**: 音效服务
- **AdService.swift**: 广告服务（测试广告位）

### 3. 工具类 ✅

- **Color+Extensions.swift**: 颜色扩展
- **View+Extensions.swift**: View扩展（常用修饰符）
- **DateHelper.swift**: 日期助手
- **CertificateGenerator.swift**: 奖状生成助手

### 4. 多语言支持 ✅

- **zh-Hans.lproj/Localizable.strings**: 中文（简体）
- **en.lproj/Localizable.strings**: 英文

### 5. 设计文档 ✅

- **iOS开发计划.md**: 详细的开发计划文档
- **UI设计规范.md**: UI设计规范文档

## 核心功能

### 游戏模式

1. **总时长模式**（第1-5关）：
   - 第1关：5分钟（平均15秒/题）
   - 第2关：4分钟（平均12秒/题）
   - 第3关：3分钟（平均9秒/题）
   - 第4关：2分钟（平均6秒/题）
   - 第5关：1分30秒（平均4.5秒/题）

2. **单题倒计时模式**（第6-10关）：
   - 第6关：每题4秒
   - 第7关：每题3.5秒
   - 第8关：每题3秒
   - 第9关：每题2.5秒
   - 第10关：每题2秒

### 勋章系统

- **加法小勇士**: 每通关1关获得（共10枚）
- **神速小能手**: 触发跳关获得（不限次数）
- **答题小天才**: 单关20题全对获得（共10枚）
- **坚持小达人**: 连续登录7天获得（1枚）

### 卡通向导

- **银河小熊猫**: 累计获得3枚勋章解锁
- **银河小兔子**: 累计获得7枚勋章解锁

### 跳关机制

- **第1-5关**: 连续10题平均用时 < 当前关卡平均每题时间的1/2
- **第6-10关**: 连续10题均在倒计时1/2时间内答对
- **奖励**: 跳至当前关卡+3的关卡，获得"神速小能手"勋章

### 失败机制

- 超时未完成或错误次数≥10次触发失败
- 二选一选项：
  1. 观看30秒广告→重新挑战本关
  2. 返回首页→下次再试

### 奖状生成

- 通关第10关后自动生成电子奖状
- 包含：昵称、通关总用时、获得勋章数量、卡通银河背景+小熊猫形象
- 支持保存到相册、分享至社交平台

## 多语言支持

支持7种语言：
- 中文（简体）
- 繁体中文
- 英文
- 日语
- 韩语
- 西班牙语
- 葡萄牙语

## 待完成的工作

### 1. 视图层（View）
- [ ] 登录页面（LoginView、ParentBindView）
- [ ] 首页（HomeView）
- [ ] 关卡选择页（LevelSelectView）
- [ ] 游戏页面（GamePlayView）
- [ ] 结果页面（ResultView）
- [ ] 奖状页面（CertificateView）
- [ ] 设置页面（SettingsView）
- [ ] 成就页面（BadgeCollectionView）

### 2. 视图模型层（ViewModel）
- [ ] LoginViewModel
- [ ] HomeViewModel
- [ ] LevelSelectViewModel
- [ ] GamePlayViewModel
- [ ] ResultViewModel
- [ ] AchievementViewModel
- [ ] SettingsViewModel

### 3. 应用入口
- [ ] MathaxyApp.swift
- [ ] AppDelegate.swift

### 4. 资源文件
- [ ] 图片资源（Logo、图标、角色等）
- [ ] 音效文件（答对、答错、获得勋章等）
- [ ] 语音文件（7种语言的语音）

### 5. 多语言补充
- [ ] 繁体中文（zh-Hant）
- [ ] 日语（ja）
- [ ] 韩语（ko）
- [ ] 西班牙语（es）
- [ ] 葡萄牙语（pt）

### 6. 测试
- [ ] 单元测试
- [ ] UI测试
- [ ] 性能测试

### 7. 发布准备
- [ ] App Store截图和描述
- [ ] 隐私政策
- [ ] App Store Connect配置

## 开发规范

### 代码规范

- 所有代码需添加清晰的中文注释
- 系统权限相关逻辑必须重点标注
- 遵循Swift编码规范
- 使用SwiftUI最佳实践

### 命名规范

- 类名：大驼峰（PascalCase）
- 方法名：小驼峰（camelCase）
- 常量：小驼峰（camelCase）
- 枚举：小驼峰（camelCase）

### Git提交规范

- feat: 新功能
- fix: 修复bug
- docs: 文档更新
- style: 代码格式调整
- refactor: 重构
- test: 测试相关
- chore: 构建/工具相关

## 注意事项

1. **COPPA合规**: 涉及广告需调用App Tracking Transparency框架获取用户授权
2. **相册权限**: 首次使用时弹窗说明权限用途（多语言适配）
3. **本地存储**: 所有数据本地存储，不上传服务器
4. **测试广告**: 当前使用测试广告位，发布前需替换为真实广告位ID

## 联系方式

如有问题，请联系开发团队。

---

**版本**: v1.0.0  
**最后更新**: 2026-01-19
