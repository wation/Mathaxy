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
    
    // MARK: - 本地状态
    @State private var showResetAlert = false
    @State private var showLanguageSheet = false
    
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
                            // 语言设置
                            SettingRowView(
                                icon: "globe",
                                title: "Language",
                                value: localizationService.currentLanguage.displayName
                            ) {
                                showLanguageSheet = true
                            }
                            
                            Divider()
                                .background(Color.cometWhite.opacity(0.2))
                            
                            // 声音设置
                            SettingToggleView(
                                icon: "speaker.wave.2.fill",
                                title: "Sound Effects",
                                isOn: .constant(true)
                            )
                            
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
            .alert("Reset Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    // 重置数据
                }
            } message: {
                Text("Are you sure you want to reset all data?")
            }
            .confirmationDialog("Select Language", isPresented: $showLanguageSheet, titleVisibility: .visible) {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    Button(language.displayName) {
                        localizationService.switchLanguage(to: language)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
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
