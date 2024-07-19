//
//  VideoUnities.swift
//  SDKVideoPlayer
//
//  Created by abc123456 on 2024/7/19.
//

import Foundation

class VideoUnities{

    func fetchVideoInfo(from m3u8URLString: String, completion: @escaping (Int?, String?) -> Void) {
        guard let m3u8URL = URL(string: m3u8URLString) else {
            completion(nil, nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: m3u8URL) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, nil)
                return
            }
            
            let m3u8Content = String(data: data, encoding: .utf8)
            let duration = self.parseDuration(from: m3u8Content)
            let resolution = self.parseResolution(from: m3u8Content)
            
            completion(duration, resolution)
        }
        task.resume()
    }

    func parseDuration(from m3u8Content: String?) -> Int? {
        guard let content = m3u8Content else { return nil }
        let lines = content.components(separatedBy: "\n")
        var totalDuration = 0
        
        for line in lines {
            if line.hasPrefix("#EXTINF:"), let durationString = line.split(separator: ",").first?.split(separator: ":").last {
                let duration = Int(durationString)
                totalDuration += duration ?? 0
            }
        }
        
        return totalDuration
    }

    func parseResolution(from m3u8Content: String?) -> String? {
        guard let content = m3u8Content else { return nil }
        let lines = content.components(separatedBy: "\n")
        
        for line in lines {
            if line.hasPrefix("#EXTRESOLUTION:") {
                let resolutionComponents = line.components(separatedBy: ":")
                return resolutionComponents.last ?? "Unknown"
            }
        }
        
        return nil
    }

   
}

