//
//  CloudKitCentra.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/29.
//

import Foundation
import CloudKit
import UIKit


typealias DownloadCompletion = (Result<URL, Error>) -> Void


class CloudKitCentra{
    
    

    static func downloadAndSaveToiCloud(urlString: String ,completion: @escaping DownloadCompletion)  {
        guard let url = URL(string: urlString) else { return   }
 
        let task = URLSession.shared.downloadTask(with: url) { (tempFileURL, response, error) in
            guard let tempFileURL = tempFileURL, error == nil else {
                print("Error downloading file: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            if let error = error {
               completion(.failure(error))
               return
           }
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
                if self.moveDownloadedFile(from: tempFileURL, to: documentDirectory) {
                    completion(.success(tempFileURL))
                }else{
                    let error = NSError(domain: "MoveDownloadedFile", code: -2, userInfo: [NSLocalizedDescriptionKey: "Save  Downloaded file URL Error"])
                    completion(.failure(error))
                }
                
            }
            
        }
        task.resume()
    }

    
    static func moveDownloadedFile(from tempFileURL: URL, to directory: URL)-> Bool {
        let fileName = tempFileURL.lastPathComponent
        
        let isM3U8File = fileName.lowercased().hasSuffix(".m3u8")
        let finalFileName = isM3U8File ? fileName : (fileName as NSString).deletingPathExtension + ".m3u8"
        
        let destinationFileURL = directory.appendingPathComponent(finalFileName)
        
        do {
            // 确保目录存在
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            
            // 移动文件
            try FileManager.default.moveItem(at: tempFileURL, to: destinationFileURL)
            print("File moved to: \(destinationFileURL)")
            return true
        } catch {
            // 处理移动文件过程中的错误
            print("Error moving file: \(error.localizedDescription)")
            return false
        }
        
    }
    
    static func saveToiCloud(fileURL: URL) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let iCloudDirectory = documentsDirectory.appendingPathComponent("iCloud")
        let iCloudFileURL = iCloudDirectory.appendingPathComponent(fileURL.lastPathComponent)
        
        do {
            try fileManager.createDirectory(at: iCloudDirectory, withIntermediateDirectories: true, attributes: nil)
            try fileManager.copyItem(at: fileURL, to: iCloudFileURL)
            
            let record = CKRecord(recordType: "File")
            record["fileURL"] = CKAsset(fileURL: iCloudFileURL)
            
            let container = CKContainer.default().publicCloudDatabase
            container.save(record) { (savedRecord, error) in
                if let error = error {
                    print("Error saving file to iCloud: \(error.localizedDescription)")
                } else {
                    print("File saved to iCloud with record ID: \(String(describing: savedRecord?.recordID))")
                }
            }
        } catch {
            print("Error saving file to local directory: \(error.localizedDescription)")
        }
        
        // Clean up the temporary file
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            print("Error removing temporary file: \(error.localizedDescription)")
        }
    }

   
}
