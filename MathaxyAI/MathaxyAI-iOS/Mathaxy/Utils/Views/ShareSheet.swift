//
//  ShareSheet.swift
//  Mathaxy
//
//  分享视图
//  封装UIActivityViewController用于SwiftUI
//

import SwiftUI
import UIKit

// MARK: - 分享视图
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
