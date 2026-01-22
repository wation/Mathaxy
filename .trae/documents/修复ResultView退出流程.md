# 修复ResultView退出流程

## 问题分析
当前的导航流程导致从ResultView退出时会短暂显示GamePlayView：
1. LevelSelectView → GamePlayView（通过NavigationStack导航）
2. GamePlayView → ResultView（通过fullScreenCover）
3. ResultView.onDisappear → dismiss() 关闭ResultView，返回GamePlayView
4. GamePlayView 短暂显示后 → 才返回LevelSelectView

## 修复方案
修改GamePlayView和ResultView的导航逻辑，让ResultView退出时直接回到LevelSelectView：

### 1. 修改ResultView，添加关闭回调
- 为ResultView添加一个闭包参数，用于通知父视图关闭
- 移除GamePlayView中ResultView.onDisappear的dismiss()调用
- 在ResultView的关闭按钮中，先关闭自己，再调用回调让GamePlayView关闭

### 2. 修改GamePlayView的导航逻辑
- 使用自定义回调代替默认的onDisappear
- 确保当ResultView关闭时，GamePlayView立即关闭，不显示残留

### 3. 调整关闭按钮逻辑
- 在ResultView的关闭按钮中，先播放音效，然后调用dismiss()关闭自己
- 然后通过回调通知GamePlayView关闭

## 具体修改点

1. **ResultView.swift**：
   - 添加`@Environment(\.dismiss) private var dismiss`
   - 添加`let onClose: (() -> Void)?`参数
   - 修改关闭按钮动作，调用onClose回调

2. **GamePlayView.swift**：
   - 修改fullScreenCover的ResultView初始化，传递onClose回调
   - 在回调中调用自己的dismiss()
   - 移除ResultView.onDisappear中的dismiss()调用

## 预期效果
- 从ResultView点击关闭按钮后，直接回到LevelSelectView
- 不显示GamePlayView的残留
- 保持正常的音效播放
- 保持导航栈的正确性

## 代码示例
```swift
// ResultView.swift
struct ResultView: View {
    // ...
    let onClose: (() -> Void)?
    
    var body: some View {
        // ...
        Button(action: {
            SoundService.shared.playButtonClickSound()
            dismiss() // 关闭ResultView
            onClose?() // 通知父视图关闭
        }) {
            // 关闭按钮
        }
        // ...
    }
}

// GamePlayView.swift
.fullScreenCover(isPresented: $viewModel.showGameComplete) {
    ResultView(gameSession: viewModel.gameSession, onClose: {
        dismiss() // 关闭GamePlayView，直接回到LevelSelectView
    })
}
```