//
//  SettingsView.swift
//  Mathaxy
//
//  设置视图
//  管理应用设置和偏好
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
        NavigationView {
            ZStack {
                // 背景
                Color.spaceBlue
                    .ignoresSafeArea()
                
                // 内容
                VStack {
                    HStack {
                        Text(LocalizedKeys.settings.localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.starlightYellow)
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.cometWhite)
                        }
                    }
                    .padding(20)
                    
                    // 设置列表
                    ScrollView {
                        VStack(spacing: 15) {
                            // 声音设置
                            SettingToggleView(
                                icon: "speaker.wave.2.fill",
                                title: "Sound Effects",
                                isOn: .constant(true)
                            )
                            
                            Divider()
                                .background(Color.cometWhite.opacity(0.2))
                            
                            // 账号切换
                            Button(action: { showAccountList = true }) {
                                SettingRowView(
                                    icon: "person.crop.circle",
                                    title: "账号切换",
                                    value: ""
                                ) {}
                            }
                            
                            Divider()
                                .background(Color.cometWhite.opacity(0.2))
                            
                            // 重置数据
                            Button(action: { showResetAlert = true }) {
                                SettingRowView(
                                    icon: "arrow.clockwise",
                                    title: "Reset Data",
                                    value: ""
                                ) {}
                            }
                        }
                        .padding(20)
                    }
                    
                    Spacer()
                }
            }
        }
        .overlay {
            // 重置数据确认弹出框
            if showResetAlert {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack(spacing: 24) {
                        Text("Reset Data")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color.starlightYellow)
                            .padding(.top, 24)
                        Text("Are you sure you want to reset all data?")
                            .font(.system(size: 16))
                            .foregroundColor(Color.cometWhite.opacity(0.8))
                            .padding(.horizontal, 24)
                        HStack(spacing: 20) {
                            Button(action: { showResetAlert = false }) {
                                Text("Cancel")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color.starlightYellow)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.stardustPurple.opacity(0.7)))
                            }
                            Button(action: { 
                                viewModel.resetAllData()
                                showResetAlert = false
                            }) {
                                Text("Reset")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.alertRed))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.galaxyGradient))
                    .padding(.horizontal, 32)
                    .scaleEffect(showResetAlert ? 1 : 0.8)
                    .opacity(showResetAlert ? 1 : 0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: showResetAlert)
                }
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
}

// MARK: - 设置行视图
private struct SettingRowView: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.starlightYellow)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.cometWhite)
                
                if !value.isEmpty {
                    Text(value)
                        .font(.system(size: 12))
                        .foregroundColor(Color.cometWhite.opacity(0.7))
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color.cometWhite.opacity(0.5))
        }
        .onTapGesture(perform: action)
    }
}

// MARK: - 设置切换视图
private struct SettingToggleView: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.starlightYellow)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.cometWhite)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color.starlightYellow)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LocalizationService.shared)
        .environmentObject(StorageService.shared)
}
