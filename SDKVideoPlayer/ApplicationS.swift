//
//  ApplicationS.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/17.
//

import Foundation
import Alamofire

class ApplicationS {
    public static let baseURL: String = "https://api.search-ball.com"
    public static let defaultRegularImageBaseURLString: String = "https://image.tmdb.org/t/p/w185"
    public static let defaultBackdropImageBaseURLString: String = "https://image.tmdb.org/t/p/w500"

    public static let DeviceCustomUUID: String = {
        let userDefaults = UserDefaults.standard
        if let savedID = userDefaults.string(forKey: "com.sdkplayer.souqiuba") {
            return savedID
        } else {
            let newID = UUID().uuidString
            userDefaults.set(newID, forKey: "com.sdkplayer.souqiuba")
            userDefaults.synchronize()
            return newID
        }
    }()
    
    
    public static func isFirstLaunch() -> Bool {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            // 不是第一次启动
            return false
        } else {
            // 是第一次启动
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            UserDefaults.standard.synchronize() // 确保立即保存
            return true
        }
    }

    
    static func initAppConfig(){
        
        // 假设这是你的应用的业务ID和版本信息
       
         
//        Session.default.headers.add(HTTPHeaderField.authorization, value: "Bearer your_access_token")
//        Session.default.headers.add(HTTPHeaderField.contentType, value: "application/json")
        
        
    }
    
    // 创建一个函数来添加自定义头部
    static func addCustomHeaders() -> HTTPHeaders {
        
        
//        App-Version: 1.0.0
//        Accept-Language: en-US;q=1.0, zh-Hans-US;q=0.9
//        User-Agent: SDKVideoPlayer/1.0.0 (com.sdkplayer.souqiuba-1; build:101; iOS 17.2.0) Alamofire/5.9.1
//        App-Bid: com.sdkplayer.souqiuba-1
//
         // 假设这是你的应用的业务ID和版本信息
         let appBid =  Bundle.main.bundleIdentifier ?? ""
         let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let deviceUUID = ApplicationS.DeviceCustomUUID
        let headers: HTTPHeaders = [
            "App-Bid": appBid,
            "App-Version": appVersion,
            "App-DeviceUUID":deviceUUID,
        ]
        return headers
         
    }
    
    static func isCurrentLanguageEnglishOrChineseSimplified() -> Bool {
        let currentLocale = Locale.current
        let languageCode = currentLocale.languageCode ?? ""
        
        if (languageCode == "zh" || languageCode == "zh-Hans" || languageCode == "zh-CN"){
            return true
        }
        if ( languageCode == "en"){
            return false
        }
        return false
    }
    

}
