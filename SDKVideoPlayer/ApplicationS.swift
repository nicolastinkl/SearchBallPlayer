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
        
        let headers: HTTPHeaders = [
            "App-Bid": appBid,
            "App-Version": appVersion,
        ]
        return headers
         
    }

}
