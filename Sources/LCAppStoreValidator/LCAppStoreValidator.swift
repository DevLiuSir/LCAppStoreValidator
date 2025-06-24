//
//  LCAppStoreValidator.swift
//
//  Created by DevLiuSir on 2023/3/2.
//


import Cocoa


/// App 来源验证器
public class LCAppStoreValidator: NSObject {
    
    /// 外部传入的 App Store 应用 ID（由调用方配置）
    private static var appID: String = ""
    
    /// AppGoup 名称
    private static var groupName = ""
    
    
    //MARK: - Public
    
    
    /// 配置 App Store 校验器（建议在 App 启动阶段调用）
    ///
    /// - Parameters:
    ///   - appID: 当前应用在 App Store 中的唯一标识符，用于跳转 App Store 页面。
    ///   - appGroupName: App Group 名称，用于跨进程共享首次启动时间等信息。若为 nil，则使用标准的 UserDefaults。
    public static func configure(appID: String, appGroupName: String? = nil) {
        self.appID = appID
        self.groupName = appGroupName ?? ""
    }
    
    /// 判断`应用是否过期`，如果过期则校验是否来自 App Store，否则弹窗退出
    /// - Parameters:
    ///   - year: 截止年
    ///   - month: 截止月
    ///   - day: 截止日
    public static func checkExpireAndValidateSource(year: Int, month: Int, day: Int) {
        // 获取当前日期
        let calendar = Calendar.current
        let currentDate = Date()
        
        // 获取给定的日期
        guard let expireDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) else {
            print("❌ 无效的过期时间")
            return
        }
        // 比较《给定的日期》是否超过《当前日期》，超过指定日期，显示警告
        if currentDate > expireDate {
            print("⚠️ 当前时间已超过设定过期时间")
            // 判断来源是否为 App Store
            if isFromAppStore() {
                print("✅ 是 App Store 版本，允许继续使用")
            } else {
                print("❌ 非 App Store 安装，弹窗提示并退出")
                // 弹窗提示 + 跳转 App Store + 退出应用
                showAlertAndExit()
            }
        } else {
            print("✅ 当前时间未过期")
        }
    }
    
    /// 主验证入口：在首次安装指定天数后验证是否为 App Store 安装版本
    public static func checkIfInvalid(afterDays days: Int) {
        // Step 1: 判断是否已超过指定天数再执行验证
        guard shouldValidate(afterDays: days) else {
            print("尚未满足验证条件（未超过 \(days) 天），跳过验证")
            return
        }
        
        // Step 2: 判断来源是否为 App Store
        if isFromAppStore() {
            print("是 App Store 下载的")
        } else {
            print("不是 App Store 下载的，弹窗提示并退出")
            showAlertAndExit()
        }
    }
    
    
    //MARK: - Private
    
    /// 判断`当前应用`是否是通过 `App Store` 下载的
    /// - Returns: 如果是通过 App Store 下载并安装的应用，返回 true；否则返回 false
    public static func isFromAppStore() -> Bool {
        // 1、获取 App Store 收据文件的 URL（即购买凭证路径）
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              // 检查收据文件是否存在。如果不存在，说明不是从 App Store 下载的应用
              FileManager.default.fileExists(atPath: receiptURL.path) else {
            return false
        }
        
        // 2、收据文件存在，进一步判断是否为 App Store 正式发布的应用
        
        // 获取可执行文件路径
        if let execPath = Bundle.main.executablePath,
           // 获取可执行文件的文件属性
           let attrInfo = try? FileManager.default.attributesOfItem(atPath: execPath),
           // 获取文件所有者的账户 ID
           let ownerAccountID = attrInfo[.ownerAccountID] as? NSNumber,
           // 如果账户 ID 为 501，表示不是 App Store的应用，可能是通过 Xcode 运行、TestFlight 或其他方式安装
           ownerAccountID.intValue == 501 {
            return false
        } else {
            // 如果所有者账户 ID 不是 501，表示是 App Store 正式下载的应用
            return true
        }
    }
    
    
    /// 检查可执行文件的所有者账户 ID 是否为开发者本地账户（UID == 501）
    ///
    /// - Returns: 如果 UID 为 501，则返回 true（表示开发环境安装）；否则返回 false。
    public static func isOwnedByDeveloperAccount() -> Bool {
        // 获取可执行文件路径
        if let execPath = Bundle.main.executablePath,
           // 获取可执行文件的文件属性
           let attrInfo = try? FileManager.default.attributesOfItem(atPath: execPath),
           // 获取文件所有者的账户 ID
           let ownerAccountID = attrInfo[.ownerAccountID] as? NSNumber,
           // 如果账户 ID 为 501，表示不是 App Store的应用，可能是通过 Xcode 运行、TestFlight 或其他方式安装
           ownerAccountID.intValue == 501 {
            return true
        } else {
            // 如果所有者账户 ID 不是 501，表示是 App Store 正式下载的应用
            return false
        }
    }
    
    /// 判断是否需要进行验证：是否首次启动已经超过指定天数
    private static func shouldValidate(afterDays days: Int) -> Bool {
        let key = "FirstLaunchTimestamp"
        let userDefaults = UserDefaults(suiteName: groupName)
        
        // 获取当前的 UTC 时间戳（单位：秒）
        let nowTimestamp = Date().timeIntervalSince1970
        
        // 一天的秒数（用于将秒转换为天）
        let secondsInDay = 86400.0
        
        if let firstLaunchTimestamp = userDefaults?.double(forKey: key), firstLaunchTimestamp > 0 {
            // Step 2: 读取已记录的首次启动时间戳
            print("首次启动时间戳 (UTC): \(firstLaunchTimestamp)")
            
            // Step 3: 计算从首次启动到现在经过的天数
            let deltaSeconds = nowTimestamp - firstLaunchTimestamp
            let deltaDays = Int(deltaSeconds / secondsInDay)
            
            print("距离首次启动已过天数: \(deltaDays) 天")
            return deltaDays >= days
        } else {
            // Step 1: 首次启动，记录当前 UTC 时间戳作为首次启动时间
            userDefaults?.set(nowTimestamp, forKey: key)
            print("首次启动时间戳已存储: \(nowTimestamp)")
            return false
        }
    }
    
    /// 显示非 App Store 下载提示弹窗并退出应用
    private static func showAlertAndExit() {
        let alert = NSAlert()
        alert.messageText = localizeString("app_source_validator.messageText")
        alert.informativeText = localizeString("app_source_validator.informativeText")
        alert.alertStyle = .critical
        alert.addButton(withTitle: localizeString("button_ok.title"))
        // Step 2: 显示弹窗并等待用户点击“确定”
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Step 3: 打开 App Store 页面（根据配置的 App ID）
            openAppStorePage()
        }
        // Step 4: 安全退出应用（NSApp + exit() 双保险）
        NSApp.terminate(nil)
        exit(0)
    }
    
    
    /// 打开 App Store 页面（使用外部设置的 appID）
    private static func openAppStorePage() {
        guard !appID.isEmpty else {
            print("appID 未设置")
            return
        }
        let appStoreUrlString = "https://apps.apple.com/cn/app/id\(appID)"
        guard let url = URL(string: appStoreUrlString) else {
            print("无效的 URL: \(appStoreUrlString)")
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    private static func localizeString(_ key: String) -> String {
#if SWIFT_PACKAGE
        // 如果是通过 Swift Package Manager 使用
        return Bundle.module.localizedString(forKey: key, value: "", table: "LCAppStoreValidator")
#else
        // 如果是通过 CocoaPods 使用
        return Bundle(for: LCAppStoreValidator.self).localizedString(forKey: key, value: "", table: "LCAppStoreValidator")
#endif
    }
    
    
}
