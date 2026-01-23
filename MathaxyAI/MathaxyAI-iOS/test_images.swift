import SwiftUI

// 测试图片显示功能
struct ImageTestView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. APP 图标
                Section(header: Text("📱 APP 图标")) {
                    Image(AppResources.Images.appIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
                
                // 2. 启动页
                Section(header: Text("🎬 启动页")) {
                    Image(AppResources.Images.launchImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
                
                // 3. 界面功能配图
                Section(header: Text("🎮 界面功能配图")) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        Image(AppResources.Images.function1)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        Image(AppResources.Images.function2)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        Image(AppResources.Images.function3)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        Image(AppResources.Images.function4)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                }
                
                // 4. 知识点讲解配图
                Section(header: Text("📚 知识点讲解配图")) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        Image(AppResources.Images.knowledge1)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        Image(AppResources.Images.knowledge2)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        Image(AppResources.Images.knowledge3)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        Image(AppResources.Images.knowledge4)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                }
                
                // 5. 奖励成就配图
                Section(header: Text("🏆 奖励成就配图")) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        Image(AppResources.Images.achievement1)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        Image(AppResources.Images.achievement2)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        Image(AppResources.Images.achievement3)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        Image(AppResources.Images.achievement4)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                }
                
                // 6. 引导页
                Section(header: Text("🧭 引导页")) {
                    ForEach(1..<4) { index in
                        let imageName = [AppResources.Images.guide1, AppResources.Images.guide2, AppResources.Images.guide3][index-1]
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("图片测试")
    }
}

// 预览
struct ImageTestView_Previews: PreviewProvider {
    static var previews: some View {
        ImageTestView()
    }
}

// 运行测试
func testImageDisplay() {
    print("🖼️  开始测试图片显示功能...")
    
    // 检查所有图片资源
    let imageNames: [String] = [
        AppResources.Images.appIcon,
        AppResources.Images.launchImage,
        AppResources.Images.function1,
        AppResources.Images.function2,
        AppResources.Images.function3,
        AppResources.Images.function4,
        AppResources.Images.knowledge1,
        AppResources.Images.knowledge2,
        AppResources.Images.knowledge3,
        AppResources.Images.knowledge4,
        AppResources.Images.achievement1,
        AppResources.Images.achievement2,
        AppResources.Images.achievement3,
        AppResources.Images.achievement4,
        AppResources.Images.guide1,
        AppResources.Images.guide2,
        AppResources.Images.guide3
    ]
    
    for imageName in imageNames {
        if let image = UIImage(named: imageName) {
            print("✅ 图片加载成功: \(imageName) (\(image.size.width)x\(image.size.height))")
        } else {
            print("❌ 图片加载失败: \(imageName)")
        }
    }
    
    print("\n✅ 图片测试完成！")
}

// 调用测试
testImageDisplay()