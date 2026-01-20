//
//  StorageServiceTests.swift
//  MathaxyTests
//
//  测试数据存储服务的功能
//  Created on 2026-01-19
//

import XCTest
@testable import Mathaxy

/// 数据存储服务测试类
final class StorageServiceTests: XCTestCase {
    
    var storageService: StorageService!
    let testKey = "test_key_\(UUID().uuidString)"
    
    override func setUp() {
        super.setUp()
        // 每个测试前初始化存储服务
        storageService = StorageService.shared
    }
    
    override func tearDown() {
        // 清理测试数据
        storageService.remove(forKey: testKey)
        storageService = nil
        super.tearDown()
    }
    
    // MARK: - 基本存储测试
    
    /// 测试存储和读取字符串
    func testSaveAndLoadString() {
        let testString = "测试字符串"
        
        // 存储字符串
        storageService.save(testString, forKey: testKey)
        
        // 读取字符串
        let loadedString: String? = storageService.load(forKey: testKey)
        
        // 验证数据一致性
        XCTAssertEqual(loadedString, testString, "存储和读取的字符串应该一致")
    }
    
    /// 测试存储和读取整数
    func testSaveAndLoadInt() {
        let testInt = 42
        
        // 存储整数
        storageService.save(testInt, forKey: testKey)
        
        // 读取整数
        let loadedInt: Int? = storageService.load(forKey: testKey)
        
        // 验证数据一致性
        XCTAssertEqual(loadedInt, testInt, "存储和读取的整数应该一致")
    }
    
    /// 测试存储和读取布尔值
    func testSaveAndLoadBool() {
        let testBool = true
        
        // 存储布尔值
        storageService.save(testBool, forKey: testKey)
        
        // 读取布尔值
        let loadedBool: Bool? = storageService.load(forKey: testKey)
        
        // 验证数据一致性
        XCTAssertEqual(loadedBool, testBool, "存储和读取的布尔值应该一致")
    }
    
    /// 测试存储和读取浮点数
    func testSaveAndLoadDouble() {
        let testDouble = 3.14159
        
        // 存储浮点数
        storageService.save(testDouble, forKey: testKey)
        
        // 读取浮点数
        let loadedDouble: Double? = storageService.load(forKey: testKey)
        
        // 验证数据一致性
        XCTAssertEqual(loadedDouble, testDouble, accuracy: 0.00001, "存储和读取的浮点数应该一致")
    }
    
    // MARK: - 复杂数据类型测试
    
    /// 测试存储和读取数组
    func testSaveAndLoadArray() {
        let testArray = [1, 2, 3, 4, 5]
        
        // 存储数组
        storageService.save(testArray, forKey: testKey)
        
        // 读取数组
        let loadedArray: [Int]? = storageService.load(forKey: testKey)
        
        // 验证数据一致性
        XCTAssertEqual(loadedArray, testArray, "存储和读取的数组应该一致")
    }
    
    /// 测试存储和读取字典
    func testSaveAndLoadDictionary() {
        let testDict = ["name": "测试", "age": 10, "score": 100]
        
        // 存储字典
        storageService.save(testDict, forKey: testKey)
        
        // 读取字典
        let loadedDict: [String: Any]? = storageService.load(forKey: testKey)
        
        // 验证数据存在
        XCTAssertNotNil(loadedDict, "应该能读取到字典")
        
        // 验证字典内容
        XCTAssertEqual(loadedDict?["name"] as? String, "测试", "字典内容应该正确")
        XCTAssertEqual(loadedDict?["age"] as? Int, 10, "字典内容应该正确")
        XCTAssertEqual(loadedDict?["score"] as? Int, 100, "字典内容应该正确")
    }
    
    /// 测试存储和读取自定义对象（UserProfile）
    func testSaveAndLoadUserProfile() {
        let userProfile = UserProfile(
            id: "test_user_\(UUID().uuidString)",
            nickname: "测试用户",
            isGuest: true,
            parentEmail: nil,
            createdAt: Date(),
            lastLoginDate: Date()
        )
        
        // 存储用户资料
        storageService.save(userProfile, forKey: testKey)
        
        // 读取用户资料
        let loadedProfile: UserProfile? = storageService.load(forKey: testKey)
        
        // 验证数据一致性
        XCTAssertNotNil(loadedProfile, "应该能读取到用户资料")
        XCTAssertEqual(loadedProfile?.id, userProfile.id, "用户ID应该一致")
        XCTAssertEqual(loadedProfile?.nickname, userProfile.nickname, "用户昵称应该一致")
        XCTAssertEqual(loadedProfile?.isGuest, userProfile.isGuest, "是否为游客应该一致")
    }
    
    // MARK: - 数据删除测试
    
    /// 测试删除数据
    func testRemoveData() {
        let testString = "待删除的数据"
        
        // 存储数据
        storageService.save(testString, forKey: testKey)
        
        // 验证数据存在
        var loadedString: String? = storageService.load(forKey: testKey)
        XCTAssertNotNil(loadedString, "数据应该存在")
        
        // 删除数据
        storageService.remove(forKey: testKey)
        
        // 验证数据已删除
        loadedString = storageService.load(forKey: testKey)
        XCTAssertNil(loadedString, "数据应该已被删除")
    }
    
    /// 测试删除不存在的数据
    func testRemoveNonExistentData() {
        // 删除不存在的数据不应报错
        XCTAssertNoThrow(storageService.remove(forKey: "non_existent_key"), "删除不存在的数据不应报错")
    }
    
    // MARK: - 数据存在性测试
    
    /// 测试检查数据是否存在
    func testDataExists() {
        // 数据不存在时
        XCTAssertFalse(storageService.exists(forKey: testKey), "数据不存在时应返回false")
        
        // 存储数据
        storageService.save("test", forKey: testKey)
        
        // 数据存在时
        XCTAssertTrue(storageService.exists(forKey: testKey), "数据存在时应返回true")
    }
    
    // MARK: - 清空所有数据测试
    
    /// 测试清空所有数据
    func testClearAllData() {
        // 存储多条数据
        storageService.save("data1", forKey: "key1")
        storageService.save("data2", forKey: "key2")
        storageService.save("data3", forKey: "key3")
        
        // 验证数据存在
        XCTAssertTrue(storageService.exists(forKey: "key1"))
        XCTAssertTrue(storageService.exists(forKey: "key2"))
        XCTAssertTrue(storageService.exists(forKey: "key3"))
        
        // 清空所有数据
        storageService.clearAll()
        
        // 验证数据已清空
        XCTAssertFalse(storageService.exists(forKey: "key1"))
        XCTAssertFalse(storageService.exists(forKey: "key2"))
        XCTAssertFalse(storageService.exists(forKey: "key3"))
    }
    
    // MARK: - 边界条件测试
    
    /// 测试空字符串存储
    func testEmptyString() {
        let emptyString = ""
        storageService.save(emptyString, forKey: testKey)
        
        let loadedString: String? = storageService.load(forKey: testKey)
        XCTAssertEqual(loadedString, emptyString, "空字符串应该能正确存储和读取")
    }
    
    /// 测试空数组存储
    func testEmptyArray() {
        let emptyArray: [Int] = []
        storageService.save(emptyArray, forKey: testKey)
        
        let loadedArray: [Int]? = storageService.load(forKey: testKey)
        XCTAssertEqual(loadedArray, emptyArray, "空数组应该能正确存储和读取")
    }
    
    /// 测试空字典存储
    func testEmptyDictionary() {
        let emptyDict: [String: String] = [:]
        storageService.save(emptyDict, forKey: testKey)
        
        let loadedDict: [String: String]? = storageService.load(forKey: testKey)
        XCTAssertEqual(loadedDict, emptyDict, "空字典应该能正确存储和读取")
    }
    
    /// 测试特殊字符存储
    func testSpecialCharacters() {
        let specialString = "测试@#$%^&*()_+-=[]{}|;':\",./<>?"
        storageService.save(specialString, forKey: testKey)
        
        let loadedString: String? = storageService.load(forKey: testKey)
        XCTAssertEqual(loadedString, specialString, "特殊字符应该能正确存储和读取")
    }
    
    /// 测试长字符串存储
    func testLongString() {
        let longString = String(repeating: "测试", count: 1000)
        storageService.save(longString, forKey: testKey)
        
        let loadedString: String? = storageService.load(forKey: testKey)
        XCTAssertEqual(loadedString, longString, "长字符串应该能正确存储和读取")
    }
    
    // MARK: - 数据覆盖测试
    
    /// 测试数据覆盖
    func testDataOverwrite() {
        // 存储初始数据
        storageService.save("initial", forKey: testKey)
        var loadedString: String? = storageService.load(forKey: testKey)
        XCTAssertEqual(loadedString, "initial", "初始数据应该正确")
        
        // 覆盖数据
        storageService.save("updated", forKey: testKey)
        loadedString = storageService.load(forKey: testKey)
        XCTAssertEqual(loadedString, "updated", "覆盖后的数据应该正确")
    }
    
    // MARK: - 性能测试
    
    /// 测试存储性能
    func testStoragePerformance() {
        measure {
            for i in 0..<100 {
                storageService.save("data_\(i)", forKey: "perf_key_\(i)")
            }
        }
    }
    
    /// 测试读取性能
    func testLoadPerformance() {
        // 预先存储数据
        for i in 0..<100 {
            storageService.save("data_\(i)", forKey: "perf_key_\(i)")
        }
        
        measure {
            for i in 0..<100 {
                _ = storageService.load(forKey: "perf_key_\(i)") as String?
            }
        }
    }
}
