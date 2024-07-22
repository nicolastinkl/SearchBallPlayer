//
//  ApplicationS.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/17.
//

import Foundation
import Alamofire

class ApplicationS {
    public static let baseURL: String = "https://api.cloudkit-apple.com"
    
    static func initAppConfig(){
        
        // 假设这是你的应用的业务ID和版本信息
       
         
//        Session.default.headers.add(HTTPHeaderField.authorization, value: "Bearer your_access_token")
//        Session.default.headers.add(HTTPHeaderField.contentType, value: "application/json")
        
        
    }
    
    // 创建一个函数来添加自定义头部
    static func addCustomHeaders() -> HTTPHeaders {
        
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
