//
//  SettingsView.swift
//  Mathaxy
//
//  设置视图
//  管理应用设置和偏好
//  Q版化改造：使用 QBackground、QListRow、QPopupContainer 等 Q 版组件
//

import SwiftUI

// MARK: - 设置视图
struct SettingsView: View {
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationService: LocalizationService
    @EnvironmentObject private var storageService: StorageService
    
    // MARK: - 视图模型
    @StateObject private var viewModel = SettingsViewModel()
    
    // MARK: - 本地状态
    @State private var showResetAlert = false
    @State private var showAccountList = false
    
    // MARK: - Body
    var body: some View {
        // 使用 Q 版背景容器
        QBackground(pageType: .settings) {
            VStack(spacing: 0) {
                // 标题栏
                headerView
                
                // 设置列表
                ScrollView {
                    VStack(spacing: QSpace.m) {
                        // 声音设置
                        QListRowToggle(
                            icon: "speaker.wave.2.fill",
                            title: "Sound Effects",
                            subtitle: "Enable sound effects",
                            isOn: $viewModel.soundEnabled
                        )
                        .onChange(of: viewModel.soundEnabled) { _, _ in
                            viewModel.toggleSound()
                        }

                        // 音乐设置
                        QListRowToggle(
                            icon: "music.note",
                            title: "Music",
                            subtitle: "Enable background music",
                            isOn: $viewModel.musicEnabled
                        )
                        .onChange(of: viewModel.musicEnabled) { _, _ in
                            viewModel.toggleMusic()
                        }

                        // 震动反馈设置
                        QListRowToggle(
                            icon: "iphone.radiowaves.left.and.right",
                            title: "Haptic Feedback",
                            subtitle: "Enable vibration feedback",
                            isOn: $viewModel.vibrationEnabled
                        )
                        .onChange(of: viewModel.vibrationEnabled) { _, _ in
                            viewModel.toggleVibration()
                        }
                        
                        // 分隔线
                        Divider()
                            .background(Color.white.opacity(0.2))
                            .padding(.vertical, QSpace.s)
                        
                        // 账号切换
                        QListRow(
                            icon: "person.crop.circle",
                            title: "账号切换",
                            subtitle: "Switch to another account",
                            trailing: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(QColor.text.onDarkSecondary)
                            },
                            action: { showAccountList = true }
                        )
                        
                        // 重置数据
                        QListRow(
                            icon: "arrow.clockwise",
                            title: "Reset Data",
                            subtitle: "Clear all data and reset settings",
                            trailing: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(QColor.text.onDarkSecondary)
                            },
                            action: { showResetAlert = true }
                        )
                    }
                    .padding(.top, QSpace.l)
                }
                
                Spacer()
            }
        }
        .overlay {
            // 重置数据确认弹窗
            if showResetAlert {
                resetAlertPopup
            }
        }
        .fullScreenCover(isPresented: $showAccountList) {
            AccountListView(onAccountSwitch: {
                // 账号切换成功，关闭设置页面
                dismiss()
            }, dismissParent: {
                // 关闭设置页面
                dismiss()
            })
        }
    }
    
    // MARK: - 标题栏视图
    private var headerView: some View {
        HStack {
            Text(LocalizedKeys.settings.localized)
                .font(QFont.titlePage)
                .foregroundColor(QColor.text.onDarkPrimary)
            
            Spacer()
            
            // 关闭按钮
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(QColor.text.onDarkPrimary)
            }
        }
        .padding(.top, QSpace.l)
        .padding(.bottom, QSpace.m)
    }
    
    // MARK: - 重置数据确认弹窗
    private var resetAlertPopup: some View {
        QPopupContainer(
            title: "Reset Data",
            content: {
                Text("Are you sure you want to reset all data?")
                    .font(QFont.body)
                    .multilineTextAlignment(.center)
            },
            primaryButtonTitle: "Reset",
            secondaryButtonTitle: "Cancel",
            onPrimary: {
                viewModel.resetAllData()
                showResetAlert = false
            },
            onSecondary: {
                showResetAlert = false
            }
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(LocalizationService.shared)
        .environmentObject(StorageService.shared)
}
