//
//  SDKAdServices.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/18.
//

import Foundation

//

import AdServices
import iAd
import AppTrackingTransparency


class SDKAdServices{
    
    func requestTrackingAuthorization() {
        if #available(iOS 14.3, *) {
            ATTrackingManager.requestTrackingAuthorization {   status in
                DispatchQueue.main.async {
                    self.handleTrackingAuthorization(status: status)
                }
            }
        } else {
            // 在iOS 13及以下版本，无需请求权限
            fetchSearchAdsAttribution()
        }
    }

    @available(iOS 14.3, *)
    func handleTrackingAuthorization(status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:
            requestAttributionDetails()
        case .denied, .restricted, .notDetermined:
            print("用户拒绝或未授权跟踪权限")
        @unknown default:
            print("未知的权限状态")
        }
    }
    
    func requestAttributionDetails() {
        if #available(iOS 14.3, *) {
            DispatchQueue.global(qos: .userInitiated).async {
                if let attributionToken = try? AAAttribution.attributionToken() {
                    let request = NSMutableURLRequest(url: URL(string:"https://api-adservices.apple.com/api/v1/")!)
                    request.httpMethod = "POST"
                    request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
                    request.httpBody = Data(attributionToken.utf8)
                    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        do {
                            let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                            print("Search Ads attribution info:", result)
                            /*
                             ["adId": 1234567890, "campaignId": 1234567890, "orgId": 1234567890, "adGroupId": 1234567890, "conversionType": Download, "countryOrRegion": US, "keywordId": 12323222, "attribution": 1, "clickDate": 2024-07-19T07:11Z]
                             Code: 1
                             */
                            if let campaignId = result["campaignId"] as? Int {
                                // Only send data to Amplitude if it is not mock data, in which case the campaign id would be the integer below
                                if campaignId != 1234567890 {
                                    // Send data to your tracking tool, we use Amplitude, with the line of code below.
                                    // Amplitude.instance().logEvent("open_app_from_apple_search_ad, with EventProperties: result)
                                }
                            }
                            self.handleAttributionDetails13(to: result as? [String:NSObject])
                            
                            //push Search Ads attribution info to server
                            
                            
                        } catch {
                            print(error)
                        }
                    }
                    task.resume()
                    
                }else{
                    print("AAAttribution is null")
                }
            }
            
             
        }
    }

    func handleAttributionDetails13(to attributionDetails: [String : NSObject]?) {
        // 将归因数据转换为JSON并发送到服务器
        if let requestdata = attributionDetails {
            let jsonData = try? JSONSerialization.data(withJSONObject: requestdata, options: [])
            guard let url = URL(string: "\(ApplicationS.baseURL)/player/attribution") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error sending attribution details: \(error.localizedDescription)")
                    return
                }
                guard let data = data else { return }
                // 处理服务器响应
                let responseString = String(data: data, encoding: .utf8)
                print("Server response: \(responseString ?? "No response")")
            }
            task.resume()
        }
        
    }

    func handleError(error: Error) {
        // 处理请求归因数据时的错误
        print("Error: \(error.localizedDescription)")
    }
    
    
      func fetchSearchAdsAttribution() {
        if #available(iOS 14.3, *) {
       
            
        } else {
            // iOS 14.3 以下版本的处理
            // 使用 iAd framework 请求 attribution details
//            ADClient.shared()
            ADClient.shared().requestAttributionDetails { attributionDetails, error in
                if let error = error {
                    print("Error fetching attribution details: \(error)")
                    return
                }
                
                if let attribu  = attributionDetails {
                    // 处理 attributionDetails，例如将其发送到你的服务器
                    print("Attribution Details: \(attribu)")
                    
                    self.handleAttributionDetails13(to: attribu as? [String:NSObject])
                }
            }
        }
    }

}
