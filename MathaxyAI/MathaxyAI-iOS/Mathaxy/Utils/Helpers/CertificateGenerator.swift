//
//  CertificateGenerator.swift
//  Mathaxy
//
//  奖状生成助手
//  负责生成电子奖状
//

import SwiftUI
import PhotosUI

// MARK: - 奖状生成助手类
class CertificateGenerator {
    
    // MARK: - 单例
    static let shared = CertificateGenerator()
    
    private init() {}
    
    // MARK: - 生成奖状图片
    
    /// 生成奖状图片
    /// - Parameters:
    ///   - certificate: 奖状数据
    ///   - size: 图片尺寸
    /// - Returns: 奖状图片
    @MainActor
    func generateCertificateImage(
        certificate: Certificate,
        size: CGSize = CGSize(width: 600, height: 800)
    ) -> UIImage? {
        
        // 创建奖状视图
        let certificateView = CertificateContentView(
            nickname: certificate.nickname,
            completionDate: certificate.completionDate,
            totalTime: certificate.totalTime,
            badgeCount: certificate.badgeCount
        )
        .frame(width: size.width, height: size.height)
        
        // 使用ImageRenderer渲染为图片
        let renderer = ImageRenderer(content: certificateView)
        renderer.scale = 3.0  // 高分辨率
        
        return renderer.uiImage
    }
    
    // MARK: - 保存奖状到相册
    
    /// 保存奖状到相册
    /// - Parameters:
    ///   - certificate: 奖状数据
    ///   - completion: 完成回调
    func saveCertificateToAlbum(
        certificate: Certificate,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        // 检查相册访问权限
        checkPhotoLibraryPermission { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                // 生成奖状图片
                Task { @MainActor in
                    guard let image = self.generateCertificateImage(certificate: certificate) else {
                        completion(false, nil)
                        return
                    }
                    
                    // 保存到相册
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { success, error in
                        DispatchQueue.main.async {
                            completion(success, error)
                        }
                    }
                }
            } else {
                // 权限被拒绝
                let error = NSError(
                    domain: "PhotoLibraryPermission",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "相册访问权限被拒绝"]
                )
                completion(false, error)
            }
        }
    }
    
    /// 保存奖状图片到相册
    /// - Parameters:
    ///   - image: 奖状图片
    ///   - completion: 完成回调
    func saveCertificate(image: UIImage, completion: @escaping (Bool, String) -> Void) {
        // 检查相册访问权限
        checkPhotoLibraryPermission { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                // 保存到相册
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(false, "保存失败: \(error.localizedDescription)")
                        } else {
                            completion(true, "保存成功")
                        }
                    }
                }
            } else {
                // 权限被拒绝
                completion(false, "相册访问权限被拒绝")
            }
        }
    }
    
    // MARK: - 检查相册访问权限
    
    /// 检查相册访问权限
    /// - Parameter completion: 完成回调
    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            completion(true)
            
        case .denied, .restricted:
            completion(false)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
            
        default:
            completion(false)
        }
    }
    
    // MARK: - 分享奖状
    
    /// 分享奖状
    /// - Parameters:
    ///   - certificate: 奖状数据
    ///   - view: 用于显示分享面板的视图
    @MainActor
    func shareCertificate(
        certificate: Certificate,
        from view: UIView
    ) {
        // 生成奖状图片
        guard let image = generateCertificateImage(certificate: certificate) else {
            return
        }
        
        // 创建分享内容
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        // 适配iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // 显示分享面板
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

// MARK: - 奖状视图
struct CertificateContentView: View {
    
    // MARK: - 属性
    let nickname: String
    let completionDate: Date
    let totalTime: Double
    let badgeCount: Int
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景
            backgroundView
            
            // 内容
            contentView
        }
    }
    
    // MARK: - 背景视图
    private var backgroundView: some View {
        ZStack {
            // 银河背景渐变
            Color.galaxyGradient
                .ignoresSafeArea()
            
            // 星星装饰
            starsView
        }
    }
    
    // MARK: - 星星装饰
    private var starsView: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<50, id: \.self) { index in
                    Circle()
                        .fill(Color.starlightYellow.opacity(Double.random(in: 0.3...0.8)))
                        .frame(width: CGFloat.random(in: 2...8))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
        }
    }
    
    // MARK: - 内容视图
    private var contentView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // 标题
            titleView
            
            // 小熊猫形象（固定使用小熊猫）
            characterView

            // 昵称
            nicknameView
            
            // 通关信息
            infoView
            
            // 勋章信息
            badgeView

            Spacer()
            
            // 底部装饰
            footerView
        }
        .padding(40)
    }
    
    // MARK: - 标题视图
    private var titleView: some View {
        VStack(spacing: 10) {
            Text("Mathaxy 加法大师")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(Color.starlightYellow)
            
            Text("电子奖状")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Color.cometWhite)
        }
    }
    
    // MARK: - 角色视图
    private var characterView: some View {
        ZStack {
            Circle()
                .fill(Color.starlightYellow.opacity(0.2))
                .frame(width: 150, height: 150)
            
            // 占位图：小熊猫
            Image(systemName: "star.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(Color.starlightYellow)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 昵称视图
    private var nicknameView: some View {
        Text(nickname)
            .font(.system(size: 36, weight: .bold))
            .foregroundColor(Color.cometWhite)
            .padding(.horizontal, 40)
            .padding(.vertical, 15)
            .background(Color.starlightYellow.opacity(0.3))
            .cornerRadius(10)
    }
    
    // MARK: - 信息视图
    private var infoView: some View {
        VStack(spacing: 15) {
            // 通关日期
            infoRow(
                icon: "calendar",
                title: "通关日期",
                value: completionDate.formatted("yyyy年MM月dd日")
            )
            
            // 通关总用时
            infoRow(
                icon: "clock",
                title: "通关总用时",
                value: formatTimeInterval(totalTime)
            )
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 信息行
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color.starlightYellow)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color.cometWhite)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color.nebulaPurple.opacity(0.3))
        .cornerRadius(10)
    }
    
    // MARK: - 勋章视图
    private var badgeView: some View {
        VStack(spacing: 15) {
            Text("获得勋章")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color.cometWhite)
            
            Text("\(badgeCount) 枚")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(Color.starlightYellow)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 底部视图
    private var footerView: some View {
        VStack(spacing: 10) {
            Text("可打印成纸质奖状哦！")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.cometWhite.opacity(0.8))
            
            Text("© \(DateHelper.shared.year(of: Date())) Mathaxy. All rights reserved.")
                .font(.system(size: 12))
                .foregroundColor(Color.cometWhite.opacity(0.6))
        }
    }
    
    // MARK: - 格式化时间间隔
    private func formatTimeInterval(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d分%d秒", minutes, secs)
    }
}

// MARK: - 预览
struct CertificateContentView_Previews: PreviewProvider {
    static var previews: some View {
        CertificateContentView(
            nickname: "小银河123",
            completionDate: Date(),
            totalTime: 135.0,
            badgeCount: 15
        )
        .frame(width: 600, height: 800)
    }
}
