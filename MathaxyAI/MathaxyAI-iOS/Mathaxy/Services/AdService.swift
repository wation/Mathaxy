//
//  AdService.swift
//  Mathaxy
//
//  广告服务
//  负责管理广告展示（使用测试广告位）
//

import Foundation
import UIKit
// 注意：实际项目中需要导入 Google Mobile Ads SDK
// import GoogleMobileAds

// MARK: - 广告服务类
class AdService: NSObject, ObservableObject {
    
    // MARK: - 单例
    static let shared = AdService()
    
    // MARK: - 是否正在加载广告
    @Published var isLoadingAd: Bool = false
    
    // MARK: - 是否已准备好广告
    @Published var isAdReady: Bool = false
    
    // MARK: - 广告完成回调
    var adCompletion: ((Bool) -> Void)?
    
    // MARK: - 测试广告位ID
    /// 注意：这些是测试广告位ID，实际发布时需要替换为真实的广告位ID
    private let testRewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"  // 测试激励视频广告
    
    private override init() {
        super.init()
        // 初始化广告SDK（实际项目中）
        // MobileAds.shared.start(completionHandler: nil)
    }
    
    // MARK: - 加载激励视频广告
    
    /// 加载激励视频广告
    func loadRewardedAd() {
        isLoadingAd = true
        
        // 模拟加载广告（实际项目中使用真实SDK）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoadingAd = false
            self?.isAdReady = true
            print("激励视频广告加载完成（测试模式）")
        }
        
        // 实际项目中的代码：
        /*
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: testRewardedAdUnitID, request: request) { [weak self] ad, error in
            self?.isLoadingAd = false
            
            if let error = error {
                print("加载激励视频广告失败: \(error.localizedDescription)")
                self?.isAdReady = false
                return
            }
            
            self?.rewardedAd = ad
            self?.isAdReady = true
            self?.rewardedAd?.fullScreenContentDelegate = self
            print("激励视频广告加载成功")
        }
        */
    }
    
    // MARK: - 展示激励视频广告
    
    /// 展示激励视频广告
    /// - Parameter completion: 广告完成回调（true表示获得奖励）
    func presentRewardedAd(completion: @escaping (Bool) -> Void) {
        // 保存回调
        adCompletion = completion
        
        guard isAdReady else {
            print("广告未准备好")
            completion(false)
            return
        }
        
        // 模拟展示广告（实际项目中使用真实SDK）
        isAdReady = false
        
        // 模拟广告播放30秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
            print("激励视频广告播放完成（测试模式）")
            self?.adCompletion?(true)
            self?.adCompletion = nil
        }
        
        // 实际项目中的代码：
        /*
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            print("无法获取根视图控制器")
            completion(false)
            return
        }
        
        rewardedAd?.present(fromRootViewController: rootViewController) {
            let reward = self.rewardedAd?.adReward
            print("获得奖励: \(reward?.amount ?? 0) \(reward?.type ?? "")")
            completion(true)
        }
        */
    }
    
    // MARK: - 检查广告是否准备好
    func isRewardedAdReady() -> Bool {
        return isAdReady
    }
    
    // MARK: - 预加载广告
    func preloadRewardedAd() {
        if !isAdReady && !isLoadingAd {
            loadRewardedAd()
        }
    }
}

// MARK: - GADFullScreenContentDelegate（实际项目中使用）
/*
extension AdService: GADFullScreenContentDelegate {
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("广告已展示")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("广告展示失败: \(error.localizedDescription)")
        isAdReady = false
        adCompletion?(false)
        adCompletion = nil
        
        // 重新加载广告
        loadRewardedAd()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("广告已关闭")
        isAdReady = false
        
        // 重新加载广告
        loadRewardedAd()
    }
}
*/

// MARK: - 广告类型枚举
enum AdType {
    case rewardedVideo  // 激励视频广告
    case interstitial   // 插屏广告
    case banner         // 横幅广告
}

// MARK: - 广告事件枚举
enum AdEvent {
    case loaded
    case failedToLoad(Error)
    case opened
    case clicked
    case closed
    case rewarded
    case impressionLogged
}

// MARK: - 广告配置
struct AdConfig {
    /// 是否启用广告（开发阶段可以关闭）
    static let isAdEnabled = true
    
    /// 是否使用测试广告位
    static let useTestAds = true
    
    /// 激励视频广告时长（秒）
    static let rewardedAdDuration = 30
    
    /// 是否在启动时预加载广告
    static let preloadAdsOnLaunch = true
}
