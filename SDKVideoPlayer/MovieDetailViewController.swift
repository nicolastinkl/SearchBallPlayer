//
//  VideoDetailViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/11.
//

import Foundation
import UIKit
import Alamofire
import SDWebImage
import SwiftIcons
import SwiftfulLoadingIndicators

import MobileCoreServices
import AVFoundation

//import SwiftLoader
//import KSPlayer

// MARK: - Welcome
struct YoutubeResponse: Codable {
    let code: Int
    let message: String
    let data: YoutubeVideoData?
}

// MARK: - DataClass
struct YoutubeVideoData: Codable {
    let videoURL: String
    let title, description: String
    let thumbnail: String
    let uploadDate, uploader: String
    let duration: Int

    enum CodingKeys: String, CodingKey {
        case videoURL = "video_url"
        case title, description, thumbnail
        case uploadDate = "upload_date"
        case uploader, duration
    }
}



class MovieDetailViewController: BaseViewController, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate  {
    
    var movieDetail: Video?
    
    var jishuArray :[String] = [String]()
    var jishuURLArray :[String] = [String]()
    var jishuURLImageArray :[String] = [String]()
    
    private let posterImageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
           
        
        // 创建 UIBlurEffect
       let blurEffect = UIBlurEffect(style: .regular) // 可选的效果：.dark, .extraLight, .light, .regular, .prominent
       
       // 创建 UIVisualEffectView
       let blurEffectView = UIVisualEffectView(effect: blurEffect)
       blurEffectView.frame = imageView.bounds
       
       // 可选：设置自动调整大小掩码以处理旋转或视图大小变化
       blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       
       // 将毛玻璃效果视图添加到 UIImageView
       imageView.addSubview(blurEffectView)
           // 创建渐变层
//           let gradientLayer = CAGradientLayer()
//           gradientLayer.colors = [
//               UIColor.clear.cgColor, // 顶部透明
////               UIColor(fromHex: "#9244a5").cgColor
//               UIColor.black.withAlphaComponent(0.5).cgColor  // 底部黑色
//           ]
//           //gradientLayer.locations = [0.0, 0.95] // 渐变在图片高度的一半开始
//            gradientLayer.locations = [0.0, 0.9, 1.0] // 0.0 表示顶部开始，1.0 表示底部结束
//           gradientLayer.frame = imageView.bounds
//           
//           // 将渐变层添加到图片视图
//           imageView.layer.insertSublayer(gradientLayer, at: 0)
           
        return imageView
    }()
    
    private let posterSmallImageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true 
    
      // 设置圆角
      imageView.layer.cornerRadius = 5 // 设置圆角半径
      imageView.layer.masksToBounds = true // 确保图片也遵循圆角
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = ThemeManager.shared.fontColor.withAlphaComponent(0.5).cgColor
        
//        // 设置阴影颜色为白色
        imageView.layer.shadowColor = UIColor.white.cgColor
              
              // 设置阴影透明度
        imageView.layer.shadowOpacity = 0.9
              
              // 设置阴影偏移为 (0, 0) 使其均匀分布
        imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
              
              // 设置较高的阴影模糊半径以模拟发光效果
        imageView.layer.shadowRadius = 15
              
              // 使用阴影路径优化性能
        imageView.layer.shadowPath = UIBezierPath(roundedRect: imageView.bounds, cornerRadius: imageView.layer.cornerRadius).cgPath
         
        
    return imageView
    }()
    
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        
        label.textColor = ThemeManager.shared.fontColor
        return label
    }()
    
    private let mutibgImageView:MutiGradientImageBgView = {
        let bgview = MutiGradientImageBgView()
        bgview.contentMode = .scaleAspectFill
        bgview.clipsToBounds = true
        bgview.backgroundColor = UIColor.black
        bgview.layer.cornerRadius = 10
        bgview.cornerRadius2 = 10
        bgview.translatesAutoresizingMaskIntoConstraints = false
        return bgview
    }()
    
    private let centerLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    
    
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ThemeManager.shared.fontColor
        return label
    }()
    
    private let remarksLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
//        label.textColor = .gray
        label.textColor = ThemeManager.shared.fontColor2
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let lineLabel: UILabel = {
        let label = UILabel()
//        label.textColor = .gray
        label.backgroundColor = ThemeManager.shared.fontColor2.withAlphaComponent(0.1)
        
        return label
    }()
    
    private let playButton:UIButton = {
        
        let playButton = UIButton(type: .custom)
        
        playButton.tintColor = UIColor.white
        playButton.setImage(UIImage(named: "Play"), for: UIControl.State.normal)
//          playButton.layer.cornerRadius = 25
          playButton.translatesAutoresizingMaskIntoConstraints = false
          return playButton
    }()
    let scrollView = UIScrollView()
    let contentView = UIView()
    var hdplayurl = ""
    
    // 为 UIImageView 应用绚丽的阴影效果
        func applyFancyShadow(to view: UIView) {
            // 设置阴影颜色
            view.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).cgColor // 黑色半透明阴影
            
            // 设置阴影透明度
            view.layer.shadowOpacity = 0.7
            
            // 设置阴影偏移量
            view.layer.shadowOffset = CGSize(width: 0, height: 5)
            
            // 设置阴影模糊半径
            view.layer.shadowRadius = 10
            
            // 设置阴影路径，优化性能
            view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
            
            // 添加渐变色叠加效果
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [
                UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5).cgColor, // 半透明红色
                UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5).cgColor  // 半透明蓝色
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.cornerRadius = view.layer.cornerRadius
            view.layer.insertSublayer(gradientLayer, below: view.layer)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ThemeManager.shared.viewBackgroundColor
        
        guard let movieDetail = movieDetail else { return }
        
        setupScrollView()
        
        
        setupPosterImageView()
        
        if movieDetail.vodID == 1 || movieDetail.vodID == 2 || movieDetail.vodID == 3 {
            
            setupMutibgImageView()
        }
        setupNameLabel()
        setupSummaryLabel()
        setupRemarksLabel()
        setupLineLabel()
        setupPlayButton()
        
        // 使用提供的JSON数据填充界面
                
        
        //generation back button
        //setupNavigationBar()
        if movieDetail.vodID == 1 || movieDetail.vodID == 2 || movieDetail.vodID == 3 {
            loadLocals(movieDetail)
            if movieDetail.vodID == 1  {
                
                 
                let m3u8Files = CloudKitCentra.getM3u8FilesInDocumentsDirectory()
                if (m3u8Files.count > 0){
                    var index = 1
                    for fileURL in m3u8Files {
                        //print("找到 .m3u8 文件：\(fileURL.absoluteString)")
                        jishuArray.append("\(fileURL.lastPathComponent)")
                        jishuURLArray.append(fileURL.absoluteString)
                        
                        index  = index + 1
                    }
                    
                }else{
                    remarksLabel.text = "No More Data"
                }
                setupButtonLists()
            }
            
            if( movieDetail.vodID == 2){
                let m3u8Files = CloudKitCentra.getM3u8FilesInCachesDirectory()
                if (m3u8Files.count > 0){
                    var index = 1
                    for fileURL in m3u8Files {
                        //print("找到 .m3u8 文件：\(fileURL.absoluteString)")
                        jishuArray.append("\(index)")
                        jishuURLArray.append(fileURL.absoluteString)
                        index  = index + 1
                    }
                    
                }else{
                    remarksLabel.text = "No More Data"
                }
                setupButtonLists()
            }
            
            if(movieDetail.vodID == 3) {
                //
                let m3u8Files = CloudKitCentra.getMP4FilesInDocumentsDirectory()
                
                
                let tempForwardBarButtonItem = UIBarButtonItem(image: UIImage(named: "videobutton"),
                                                               style: UIBarButtonItem.Style.plain,
                                                               target: self,
                                                               action: #selector(MovieDetailViewController.addOpenCloudkitTapped(_:)))
                tempForwardBarButtonItem.width = 18.0
                tempForwardBarButtonItem.tintColor = UIColor.MainColor()
                navigationItem.rightBarButtonItem = tempForwardBarButtonItem
            
                
                if (m3u8Files.count > 0){
                    var index = 1
                    for fileURL in m3u8Files {
                        //print("找到 .m3u8 文件：\(fileURL.absoluteString)")
                        jishuArray.append("\(fileURL.lastPathComponent)")
                        jishuURLArray.append(fileURL.absoluteString)
                        var newString = fileURL.absoluteString.replacingOccurrences(of: ".MP4", with: ".png", options: .literal, range: nil)
                          newString = newString.replacingOccurrences(of: ".mp4", with: ".png", options: .literal, range: nil)
                        jishuURLImageArray.append(newString)
                        index  = index + 1
                    }
                    
                    // 定义支持的文件类型
                    setupButtonLists()
                    
                    
                    
                }else{
                    addOpenCloudkit()
                }
                //add button
                
            }
            
            
            
           
        }else{
            
            let tempForwardBarButtonItem = UIBarButtonItem(image: UIImage(named: "updloadtocloud"),
                                                           style: UIBarButtonItem.Style.plain,
                                                           target: self,
                                                           action: #selector(MovieDetailViewController.uploadtoCloud(_:)))
            tempForwardBarButtonItem.width = 18.0
            tempForwardBarButtonItem.tintColor = UIColor.MainColor()
            navigationItem.rightBarButtonItem = tempForwardBarButtonItem
            loadMovieDetail(movieDetail)
        }
        
        
    }
    
    var addOpenCloudkitButton: UIButton?
    func addOpenCloudkit(){
        let button = UIButton(type: .custom)
        button.setTitle("Add media file", for: .normal)
        button.setTitleColor(ThemeManager.shared.fontColor, for: UIControl.State.normal)
        button.setTitleColor(UIColor.MainColor(), for: UIControl.State.highlighted)
        button.backgroundColor = ThemeManager.shared.fontColor.withAlphaComponent(0.1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
         
        button.layer.cornerRadius = 5
        button.layer.borderColor = ThemeManager.shared.fontColor2.withAlphaComponent(0.2).cgColor
        button.layer.borderWidth = 1
        button.clipsToBounds = true
 
        button.addTarget(self, action: #selector(addOpenCloudkitTapped(_:)), for: .touchUpInside)
        
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        addOpenCloudkitButton = button
        
        let buttonSize: CGFloat = 44
          NSLayoutConstraint.activate([
              
              button.heightAnchor.constraint(equalToConstant: buttonSize),
              button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
              
              button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -10),
              button.topAnchor.constraint(equalTo: remarksLabel.bottomAnchor, constant: 35 )
          ])
        
        var heightSummary:CGFloat = CGFloat(summaryLabel.text?.count ?? 0) * 1.2
        print(heightSummary)
          if ( heightSummary <= 0.0) {
              heightSummary = 200.0
          }
        NSLayoutConstraint.activate([
        
              contentView.heightAnchor.constraint(equalToConstant:self.view.frame.height*0.6 + heightSummary  + 50)
          
        ])
        
    }

    @objc func addOpenCloudkitTapped(_ button: UIButton){
        let m3u8Type = String(kUTTypeM3UPlaylist as CFString) // .m3u8 文件
        let mp4Type = String(kUTTypeMPEG4 as CFString) // .mp4 文件
        
        // 初始化文档选择器
        let documentPicker = UIDocumentPickerViewController(documentTypes: [m3u8Type, mp4Type], in: .open)
 //let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeURL)], in: .open)
       documentPicker.delegate = self
       documentPicker.modalPresentationStyle = .formSheet
//                  documentPicker.sourceView = self.view
       
       // 允许从iCloud选择文件
     
//                  documentPicker.options = [_UIDocumentPickerOptionAllowCloud]
       present(documentPicker, animated: true, completion: nil)
    }
        
    
    // MARK: - UIDocumentPickerDelegate

    
    func generateThumbnail(from videoURL: URL) -> UIImage?{
             
            let asset = AVAsset(url: videoURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true

            // 选择你想要生成缩略图的时间（此处为视频的第1秒）
            let time = CMTime(seconds: 1.0, preferredTimescale: 600)
            do {
                let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: imageRef)
 

                // 将缩略图保存为 PNG 格式
                if let data = thumbnail.pngData() {
                    // 确保文件名和目录
                    let thumbnailFilename = videoURL.deletingPathExtension().lastPathComponent + ".png"
                    let thumbnailURL = videoURL.deletingLastPathComponent().appendingPathComponent(thumbnailFilename)

                    try data.write(to: thumbnailURL)
                    print("缩略图已保存到：\(thumbnailURL.path)")
                    
                }
                return thumbnail
            } catch {
                print("缩略图生成失败：\(error)")
            }
            return nil
        }
    
      func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
          guard let url = urls.first else { return }
          //▿ file:///private/var/mobile/Containers/Shared/AppGroup/B52EBE26-6D27-403D-8EF1-FC1174D21531/File%20Provider%20Storage/ALL%20Michael%20Phelps'%20Olympic%20Medal%20Races%20from%20London%202012%20_%20Top%20Moments.MP4

          
          if(url.pathExtension == "m3u8" || url.pathExtension == "mp4"  || url.pathExtension == "MP4" || url.pathExtension == "M3U8"){
              
              
              // 请求访问文件权限
              let hasAccess = url.startAccessingSecurityScopedResource()
              defer {
                  // 确保在使用完文件后释放访问权限
                  if hasAccess {
                      url.stopAccessingSecurityScopedResource()
                  }
              }
              
              do {
                  let fileManager = FileManager.default
                  // 目标文件的路径（app 的 Documents 目录）
                  if  let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                      let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
                      
                      // 检查文件是否已存在，若存在则删除
                      if fileManager.fileExists(atPath: destinationURL.path) {
                          try fileManager.removeItem(at: destinationURL)
                      }
                      
                      // 复制文件到 Documents 目录
                      try fileManager.copyItem(at: url, to: destinationURL)
                      print("文件复制成功到：\(destinationURL.path)")
                      
                      // 生成视频截图
                      //generateThumbnail(from: destinationURL)
                      self.view.makeToast( NSLocalizedString("SaveSuccess", comment: "")  , duration: 3.0, position: .bottom)
                      
                      //
                      addOpenCloudkitButton?.isHidden = true
                      jishuArray.append("\(destinationURL.lastPathComponent)")
                      jishuURLArray.append("\(destinationURL.absoluteString)")
                      addlastButton()
                      
                  }
                  
              } catch {
                  print("文件操作失败：\(error)")
                  self.view.makeToast(NSLocalizedString("SaveFailed", comment: "") + "\(error)", duration: 3.0, position: .bottom)
              }
          }
      
//
//              let resource = KSPlayerResource(url: url)
//              let controller = DetailViewController()
//              controller.resource = resource
//               
//               if let s = self.movieDetail {
//                   if s.vodID > 10 {
//                       
//                       LocalStore.saveToUserDefaults(RecentlyWatchVideo: s)
//                       //通知刷新列表
//                       
//                       // 发送通知
//                       NotificationCenter.default.post(name: .historyItemsUpdated, object: nil)
//                   }
//               }
//              controller.modalPresentationStyle = .fullScreen
//              self.present(controller, animated:false)
              
//          }
          
          // 使用UIDocument打开文件
          /*let document = UIDocument(fileURL: url)
          document.open(completionHandler: { (success) in
              if success {
                  print("文件打开成功")
                  // 这里可以添加代码来处理打开的文件，例如浏览或编辑
                  
              } else {
                  print("文件打开失败")
              }
          })*/
      }

      // MARK: - UIDocumentInteractionControllerDelegate

    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
          // 处理文件浏览器关闭后的逻辑
      }
    
    @objc func uploadtoCloud(_ button: UIButton){
        
        if let model = self.movieDetail {
            
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(model) {
                // 将编码后的数据转换为字符串
                   if let jsonString = String(data: encodedData, encoding: .utf8)   {
                      
                       // UTF 8 str from original
                       // NSData! type returned (optional)
                       
                       let utf8str = jsonString.data(using: String.Encoding.utf8)

                       // Base64 encode UTF 8 string
                       // fromRaw(0) is equivalent to objc 'base64EncodedStringWithOptions:0'
                       // Notice the unwrapping given the NSData! optional
                       // NSString! returned (optional)
                       
                       let base64Encoded = utf8str?.base64EncodedString() ?? ""
                       
                       
                       let parameters: [String: Any] = [
                           "requestbody": base64Encoded,
                       ]
                       
                       SwiftLoader.show(title: "Saving...", animated: true)
                       // push encodedData to server
                       AF.request("\(ApplicationS.baseURL)/player/saveplaylist", method: .post,parameters: parameters,headers: ApplicationS.addCustomHeaders())
                           .validate(statusCode: 200..<300)
                           .responseString(completionHandler: { response in
                              // debugPrint("\(response.value)")
                               if (response.value?.count ?? 0) > 5 {
                                   
                                   
                                   DispatchQueue.main.async {
                                       SwiftLoader.hide()
                                       self.view.makeToast( NSLocalizedString("SaveSuccess", comment: "") + (response.value ?? ""), duration: 3.0, position: .bottom)
                                       
                                   }
                               }else{
                                   DispatchQueue.main.async {
                                       SwiftLoader.hide()
                                       self.view.makeToast(NSLocalizedString("SaveFailed", comment: ""), duration: 3.0, position: .bottom)
                                   }
                               }
                               
                                
                                    
                           })
                             
                   }
            }
                
        }
      /*
        if hdplayurl.count > 5 ,let _ = URL(string: hdplayurl) {
            SwiftLoader.show(title: "Saving...", animated: true)
            CloudKitCentra.downloadAndSaveToiCloud(urlString: hdplayurl) { result in
                //Result<URL, Error>
                switch result {
                    case .success(let fileURL):
                        print("文件已成功保存到: \(fileURL)")
                        DispatchQueue.main.async {
                            SwiftLoader.hide()
                            self.view.makeToast( NSLocalizedString("SaveSuccess", comment: ""), duration: 3.0, position: .bottom)
                            
                        }
                    case .failure(let error):
                        print("下载或保存文件时发生错误: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            SwiftLoader.hide()
                            self.showSearchErrorAlert(on: self, error: error.localizedDescription)
                        }
                    }
            }                
        }else{
            //保存 list
            SwiftLoader.show(title: "Saving List...", animated: true)
            jishuURLArray.forEach { url in
                CloudKitCentra.downloadAndSaveToiCloud(urlString: url) { result in
                    //Result<URL, Error>
                    switch result {
                        case .success(let fileURL):
                            print("文件已成功保存到: \(fileURL)")
                            DispatchQueue.main.async {
                                SwiftLoader.hide()
                                self.view.makeToast( NSLocalizedString("SaveSuccess", comment: ""), duration: 3.0, position: .bottom)
                                
                            }
                        case .failure(let error):
                            print("下载或保存文件时发生错误: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                SwiftLoader.hide()
                                self.showSearchErrorAlert(on: self, error: error.localizedDescription)
                            }
                        }
                }
            }
            
        }*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func setupNavigationBar() {
        // 创建一个UIButton作为返回按钮
        let backButton = ShadowButton(type: .custom)
        
        // 设置按钮的图片（假设你有一个名为"back_arrow"的图片）
        backButton.setImage(UIImage(named: "back"), for: .normal)
        
        // 设置按钮的颜色
//        backButton.tintColor = UIColor.white
        
        // 添加点击事件
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit

        // 设置按钮的尺寸
//        backButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        // 禁用自动约束
        backButton.translatesAutoresizingMaskIntoConstraints = false
         
        // 添加按钮到主视图
        scrollView.addSubview(backButton)

        // 设置按钮的约束
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -10),
            backButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44) // 根据图片实际比例调整
        ])
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
        
//        self.navigationController?.navigationItem.setLeftBarButton(UIBarButtonItem(customView: backButton), animated: true)
    }
    
    @objc private func backButtonTapped() {
        // 执行返回操作
        
        navigationController?.popViewController(animated: true)
    }
    
    
    
    private func setupScrollView() {
          scrollView.translatesAutoresizingMaskIntoConstraints = false
          contentView.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(scrollView)
          scrollView.addSubview(contentView)
          
          NSLayoutConstraint.activate([
              scrollView.topAnchor.constraint(equalTo: view.topAnchor),
              scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
              
              contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
              contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
              contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
              contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
              contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
              
              // 关键部分：设置contentView的高度，使其大于scrollView的高度，以实现滚动
              //contentView.heightAnchor.constraint(equalToConstant: 1200)
          ])
      }
     
    
    private func setupPosterImageView() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterImageView)
        
        posterSmallImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterSmallImageView)
        
        
        // 约束：顶部对齐刘海屏，宽度占满屏幕，高度根据图片比例设置
          NSLayoutConstraint.activate([
              posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: -100),
              posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
              posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//              posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 16/9) // 根据图片实际比例调整
              posterImageView.heightAnchor.constraint(equalToConstant: 500),
              
              posterSmallImageView.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
              posterSmallImageView.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),
              posterSmallImageView.widthAnchor.constraint(equalToConstant: 180),
              posterSmallImageView.heightAnchor.constraint(equalToConstant: 300),
                          
          ])
          
          // 更新渐变层的位置，确保它适应刘海屏
          posterImageView.layoutIfNeeded()
          let gradientLayer = posterImageView.layer.sublayers?.first as? CAGradientLayer
          gradientLayer?.frame = CGRect(x: 0, y: 0, width: posterImageView.bounds.width, height: posterImageView.bounds.height)

    
    }
    
    private func setupMutibgImageView(){
        contentView.addSubview(mutibgImageView)
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(centerLabel)
        NSLayoutConstraint.activate([
            mutibgImageView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: -100),
            mutibgImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mutibgImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//              posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 16/9) // 根据图片实际比例调整
            mutibgImageView.heightAnchor.constraint(equalToConstant: 400),
            
            centerLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: -100),
            centerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            centerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//              posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 16/9) // 根据图片实际比例调整
            centerLabel.heightAnchor.constraint(equalToConstant: 400),
            
        ])
        
        // 更新渐变层的位置，确保它适应刘海屏
        //mutibgImageView.layoutIfNeeded()
        mutibgImageView.cornerRadius2 = 0
        
    }
    
    private func setupPlayButton(){
//        contentView.addSubview(playButton)
//        
//        NSLayoutConstraint.activate([
//            playButton.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
//            playButton.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor,constant: 10),
//            playButton.widthAnchor.constraint(equalToConstant: 100),
//            playButton.heightAnchor.constraint(equalToConstant: 100)
//        ])
        
        
    }
    
    private func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: -80),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupSummaryLabel() {
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(summaryLabel)
        
        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            summaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            summaryLabel.heightAnchor.constraint(equalToConstant: 40)
//            summaryLabel.bottomAnchor.constraint(equalTo: remarksLabel.topAnchor, constant: 20)
        ])
    }
    
    private func setupRemarksLabel() {
        remarksLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(remarksLabel)
        
        NSLayoutConstraint.activate([
            remarksLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20),
            remarksLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            remarksLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupLineLabel(){
        
        
        lineLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lineLabel)
        
        NSLayoutConstraint.activate([
            lineLabel.topAnchor.constraint(equalTo: remarksLabel.bottomAnchor, constant: 20),
            lineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            lineLabel.heightAnchor.constraint(equalToConstant: 1)
        ])
        
    }
    
    private func loadLocals(_ movie: Video) {
        
        posterSmallImageView.isHidden = true
        centerLabel.text = ApplicationS.isCurrentLanguageEnglishOrChineseSimplified() ? movie.vodName : movie.vodEn
        summaryLabel.text = movie.vodBlurb + movie.vodContent
        
        
    }
    private func loadMovieDetail(_ movie: Video) {
        // 从URL加载图片
        if let imageUrl = URL(string: movie.vodPic) {
            self.posterImageView.sd_setImage(with: imageUrl, placeholderImage:  UIImage(named: "placeholder-image"), context: nil)
            self.posterSmallImageView.sd_setImage(with: imageUrl, placeholderImage:  UIImage(named: "placeholder-image"), context: nil)
        }
        
        nameLabel.text = ApplicationS.isCurrentLanguageEnglishOrChineseSimplified() ? movie.vodName : movie.vodEn
        summaryLabel.text = movie.vodRemarks + " / " + movie.vodLang  + " / " + movie.vodYear
        remarksLabel.text = movie.vodBlurb + movie.vodContent
        let movies = movie.vodPlayURL as NSString
        var newMovices = movies.replacingOccurrences(of: ".m3u8#", with: ".m3u8\n")
        newMovices = newMovices.replacingOccurrences(of: ".mp4#", with: ".mp4\n")
        newMovices = newMovices.replacingOccurrences(of: "$https", with: "\nhttps")
      
        var index = 1
        newMovices.components(separatedBy: "\n").forEach { str in
            //print("\n" + str)
            
            if(str.count > 10){
                let newStr =  str as NSString
                if  newStr.contains(".m3u8") ||  newStr.contains(".mp4"){
                    
                    jishuURLArray.append(newStr as String)
                    jishuArray.append("\(index)")
                    index  = index + 1
                }
                
            }

            
        }
        print("总条数：\(jishuURLArray.count)" )
         
        if jishuURLArray.count > 1 {
            setupButtons()
        }else{
            //只有一个播放列表时
            if let playlistOne  = jishuURLArray.first as? NSString {
                
                
                if playlistOne.contains(".mp4") {
                    let button = UIButton(type: .custom)
                    button.setTitle("Play Video", for: .normal)
                    button.setTitleColor(ThemeManager.shared.fontColor2, for: UIControl.State.normal)
                    button.setTitleColor(UIColor.MainColor(), for: UIControl.State.highlighted)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                    
//                    button.backgroundColor = UIColor(fromHex: "#eeeef0")
                    button.layer.borderColor = ThemeManager.shared.fontColor2.withAlphaComponent(0.2).cgColor
                    button.backgroundColor = ThemeManager.shared.fontColor.withAlphaComponent(0.1)
                    button.layer.cornerRadius = 5
//                    button.layer.borderColor = ThemeManager.shared.fontColor2.cgColor
                    button.layer.borderWidth = 1
                    button.clipsToBounds = true

                    button.tag = index
                    button.addTarget(self, action: #selector(ButtonhdplayurlTapped(_:)), for: .touchUpInside)
                    
                    
                    contentView.addSubview(button)
                    button.translatesAutoresizingMaskIntoConstraints = false
                      
                    let buttonSize: CGFloat = 44
                      NSLayoutConstraint.activate([
                          button.heightAnchor.constraint(equalToConstant: buttonSize),
                          button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  50),
                          button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -50),
                          button.topAnchor.constraint(equalTo: lineLabel.bottomAnchor, constant: 35 )
                      ])
                    
                    
                    jishuURLArray.removeAll()
                    jishuURLArray.append(playlistOne as String )
                    hdplayurl = playlistOne  as String
                    NSLayoutConstraint.activate([
                    
                          contentView.heightAnchor.constraint(equalToConstant:1200)
                      
                    ])
                }
                
                if   playlistOne.contains(".m3u8") ,let url = playlistOne.components(separatedBy: ".m3u8").first   {
                    
                    
                    let button = UIButton(type: .custom)
                    button.setTitle("\(movie.vodRemarks)", for: .normal)
                    button.setTitleColor(ThemeManager.shared.fontColor2, for: UIControl.State.normal)
                    button.setTitleColor(UIColor.MainColor(), for: UIControl.State.highlighted)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                    
                    button.layer.borderColor = ThemeManager.shared.fontColor2.withAlphaComponent(0.2).cgColor
                    button.backgroundColor = ThemeManager.shared.fontColor.withAlphaComponent(0.1)
//                    button.backgroundColor = UIColor(fromHex: "#eeeef0")
                    button.layer.cornerRadius = 10
                    
                    button.layer.borderWidth = 1
                    button.clipsToBounds = true

                    button.tag = index
                    button.addTarget(self, action: #selector(ButtonhdplayurlTapped(_:)), for: .touchUpInside)
                    
                    
                    contentView.addSubview(button)
                    button.translatesAutoresizingMaskIntoConstraints = false
                      
                    let buttonSize: CGFloat = 44
                      NSLayoutConstraint.activate([
                          button.heightAnchor.constraint(equalToConstant: buttonSize),
                          button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  50),
                          button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -50),
                          button.topAnchor.constraint(equalTo: lineLabel.bottomAnchor, constant: 35 )
                      ])
                    
                    
                    jishuURLArray.removeAll()
                    jishuURLArray.append(url+".m3u8")
                    hdplayurl = url+".m3u8"
                    NSLayoutConstraint.activate([
                    
                          contentView.heightAnchor.constraint(equalToConstant:1200)
                      
                    ])
                }
            }else{
                if (self.movieDetail?.vodPlayURL.count ?? 0) > 0 {
                    let button = UIButton(type: .custom)
                    button.setTitle("Play Video", for: .normal)
                    button.setTitleColor(ThemeManager.shared.fontColor2, for: UIControl.State.normal)
                    button.setTitleColor(UIColor.MainColor(), for: UIControl.State.highlighted)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                    
//                    button.backgroundColor = UIColor(fromHex: "#eeeef0")
                    button.layer.borderColor = ThemeManager.shared.fontColor2.withAlphaComponent(0.2).cgColor
                    button.backgroundColor = ThemeManager.shared.fontColor.withAlphaComponent(0.1)
                    button.layer.cornerRadius = 5
//                    button.layer.borderColor = ThemeManager.shared.fontColor2.cgColor
                    button.layer.borderWidth = 1
                    button.clipsToBounds = true

                    button.tag = index
                    button.addTarget(self, action: #selector(ButtonhdplayurlYoutubeTapped(_:)), for: .touchUpInside)
                    
                    
                    contentView.addSubview(button)
                    button.translatesAutoresizingMaskIntoConstraints = false
                      
                    let buttonSize: CGFloat = 44
                      NSLayoutConstraint.activate([
                          button.heightAnchor.constraint(equalToConstant: buttonSize),
                          button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  50),
                          button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -50),
                          button.topAnchor.constraint(equalTo: lineLabel.bottomAnchor, constant: 35 )
                      ])
                    
                     
                    NSLayoutConstraint.activate([
                    
                          contentView.heightAnchor.constraint(equalToConstant:1200)
                      
                    ])
                }
            }
            
            
        }
//        print(movie)
//        print(jishuURLArray)
        
    }
    
    
    
    
    
    func sendRequestGetPlayerURL() {
        
        SwiftLoader.show(view: self.view,title: NSLocalizedString("Gettings play url...", comment: ""), animated: true)
        

      //  LoadingIndicator()
//        // Fetch Request
        
        let requestComplete33: (HTTPURLResponse?, Result<String, AFError>) -> Void = { response, result in

            SwiftLoader.hide()
            
            //if let response {
//                for (field, value) in response.allHeaderFields {
//                    debugPrint("\(field) \(value)" )
//                }
                switch  result {
                       case .success(let value):
                    // 将 JSON 字符串转换为 Data
                    debugPrint("  \(value)" )
                    guard let data = value.data(using: String.Encoding.utf8) else {
                        
                        DispatchQueue.main.async {
                            self.showSearchErrorAlert(on: self, error: "Error: Cannot create data from JSON string.", title: "Network Exception")
                        }
                        
                        return
                    }
                     
                    // 创建 JSONDecoder 实例
                    let decoder = JSONDecoder()

                        // 使用 JSONDecoder 解码数据
                        do {
                            let response_config = try decoder.decode(YoutubeResponse.self, from: data)
                            print("Code: \(response_config.code)")
                            print("Message: \(response_config.message)")
                            
                            if(Int(response_config.code) == 1){
                                
                                //self.movies = response_config.data.videolist
                            
                                DispatchQueue.main.async {
                                    if let u = URL(string: response_config.data?.videoURL ?? "") ,let coverurl =  URL(string: response_config.data?.thumbnail ?? ""){
                                        
                                        let resource = KSPlayerResource(url: u, name: response_config.data?.title ?? "",cover: coverurl)
                                       let controller = DetailViewController()
                                       controller.resource = resource
                                         
                                       controller.modalPresentationStyle = .fullScreen
                                       self.present(controller, animated:false)
                                    }else{
                                       
                                        self.showSearchErrorAlert(on: self , error: "Get Play Video play URL Failed.Please try again.", title: "Error Info")
                                       
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.showSearchErrorAlert(on: self , error: "Get Play Video play URL Failed.Please try again.", title: "Error Info")
                                }
                            }
                            
                        } catch {
                            DispatchQueue.main.async {
                                self.showSearchErrorAlert(on: self, error: "Json parse Error: \(error.localizedDescription)", title: "Network Exception")
                            }
                            
                        }
                    
                            
                       case .failure(let error):
//
//                             debugPrint("HTTP Request failed: ")
                            DispatchQueue.main.async {
                                // UI 更新代码
                                self.showNetworkErrorView (errormsg: "\(error.localizedDescription)", clickBlock: {
                                    self.sendRequestGetPlayerURL()
                                })
                            }
                           // 错误处理
                       }
                
//            }

           
 
        }
        
        let parameters: [String: Any] = [
            "url": self.movieDetail?.vodPlayURL ?? "",
        ]
        
        AF.request("\(ApplicationS.baseURL)/player/youtube", method: .post,parameters: parameters,headers: ApplicationS.addCustomHeaders())
            .validate(statusCode: 200..<300)
            
            .responseString(completionHandler: { response in
                requestComplete33(response.response, response.result)
                     
            })
              
    }

    
    @objc func ButtonhdplayurlYoutubeTapped(_ button: UIButton){
        if ((self.movieDetail?.vodPlayURL.localizedCaseInsensitiveContains("youtube.com")) != nil) {
            
            sendRequestGetPlayerURL()
//            if  let urlString = self.movieDetail?.vodPlayURL, let _ = URL(string: self.movieDetail?.vodPlayURL ?? "") {
//                let controller = SwiftWebVC(urlString: urlString)
//                controller.hidesBottomBarWhenPushed = true
//                controller.proxyHttps = true
//                if let s = self.movieDetail {
//                    LocalStore.saveToUserDefaults(RecentlyWatchVideo: s)
//                    //通知刷新列表
//                    
//                    // 发送通知
//                    NotificationCenter.default.post(name: .historyItemsUpdated, object: nil)
//                    
//                }
//                self.show(controller, sender: self)
//            }
            
        }else{
            self.showSearchErrorAlert(on: self, error: "Play URL Error, Please try again.", title: "Alert URL Error")
        }
    }
    
    func image(fromPngFilePath filePath: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: filePath)
        
        // 使用 UIImage 的 init(contentsOfFile:) 方法从文件路径加载图像
        if let image = UIImage(contentsOfFile: fileURL.path) {
            return image
        } else {
            print("无法从路径加载图像：\(filePath)")
            return nil
        }
    }

    
    
    func getVideoInfo(from fileURL: String) -> String {
        var returnString = ""
        if let url = URL(string: fileURL) {
            let asset = AVAsset(url:url )
                // 获取视频的时长
                let duration = asset.duration
                let durationSeconds = CMTimeGetSeconds(duration)
                print("视频时长: \(durationSeconds) 秒")
                var timespace = 0
                if durationSeconds > 60 {
                    returnString = "\(Int(durationSeconds/60)) min"
                }else{
                    returnString = "\(Int(durationSeconds)) s"
                }
                // 获取视频的创建时间
                if let creationDate = asset.creationDate {
                    let date = creationDate.dateValue
                    print("视频创建时间: \(String(describing: date))")
                    //returnString = "\(returnString)/ \(String(describing: date))"
                } else {
                    print("无法获取视频创建时间")
                }
                
                // 获取视频的其他元数据（例如标题）
                let metadata = asset.metadata
                for item in metadata {
                    if let key = item.commonKey?.rawValue, let value = item.value {
                        print("\(key): \(value)")
                    }
                }
        
        }
        
     return returnString
    }
    
    
    var preButton: UIButton!
    
    func addlastButton(){
        let numberOfColumns: Int = 1
        
        let numberOfRows =   jishuArray.count/numberOfColumns+1
        let spacing: CGFloat = 10
        let buttonSize: CGFloat = (self.view.frame.width - spacing*7) / 6
        let heightBuView: CGFloat = 120
        addnewButtonFunc(jishuURLArray.count-1, spacing, heightBuView, 1, buttonSize)
        
        var heightSummary:CGFloat = CGFloat(jishuArray.count) *   heightBuView
        if ( heightSummary <= 0.0) {
            heightSummary = 200.0
        }
      NSLayoutConstraint.activate([
      
            contentView.heightAnchor.constraint(equalToConstant:self.view.frame.height*0.6 + heightSummary   +  CGFloat(numberOfRows) * (buttonSize + spacing) + spacing)
        
      ])
        
    }
    
    fileprivate func addnewButtonFunc(_ index: Int, _ spacing: CGFloat, _ heightBuView: CGFloat, _ col: Int, _ buttonSize: CGFloat) {
        let button = UIButton(type: .custom)
        //                       button.setTitle(jishuArray[index], for: .normal)
        //                       button.setTitleColor(ThemeManager.shared.fontColor2, for: UIControl.State.normal)
        //                       button.setTitleColor(UIColor.MainColor(), for: UIControl.State.highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.cornerRadius = 5
        
        button.layer.borderWidth = 1
        button.layer.borderColor = ThemeManager.shared.fontColor2.withAlphaComponent(0.2).cgColor
        //                       button.backgroundColor = ThemeManager.shared.fontColor.withAlphaComponent(0.1)
        button.clipsToBounds = true
        
        button.tag = index
        button.addTarget(self, action: #selector(ButtonTapped(_:)), for: .touchUpInside)
        
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        contentView.addSubview(imageView)
//        if let img = image(fromPngFilePath: jishuURLImageArray[index]) {
//            imageView.image = img
//        }else{
//            
//            //重新生成图片
//            
//            
//        }
        if let u = URL(string: jishuURLArray[index]) ,let img = generateThumbnail(from:u ){
            imageView.image = img
        }else{
            
            imageView.image = UIImage(named: "placeholder-image")
        }
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        contentView.addSubview(nameLabel)
        nameLabel.textColor = ThemeManager.shared.fontColor
        nameLabel.numberOfLines = 2
        nameLabel.text = jishuArray[index]
        let returnString = getVideoInfo(from: jishuURLArray[index])
        
        
        let contentLabel = UILabel()
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(contentLabel)
        contentLabel.textColor = ThemeManager.shared.fontColor2
        contentLabel.numberOfLines = 1
        contentLabel.text = returnString
        lineLabel.backgroundColor = UIColor.clear
        if index == 0 {
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: lineLabel.bottomAnchor, constant:   spacing)
            ])
        }else{
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: preButton.bottomAnchor, constant:   spacing)
            ])
        }
        
        let playImageview = UIImageView()
        playImageview.translatesAutoresizingMaskIntoConstraints = false
        playImageview.contentMode = .scaleAspectFit
        playImageview.clipsToBounds = true
        contentView.addSubview(playImageview)
        playImageview.image = UIImage(named: "Play")
        playImageview.tintColor = UIColor.MainColor()
        NSLayoutConstraint.activate([
            
            button.heightAnchor.constraint(equalToConstant: heightBuView),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  spacing),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -spacing),
            
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor,constant: -20),
            nameLabel.heightAnchor.constraint(equalToConstant: 70),
            
            contentLabel.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -10),
            contentLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
            contentLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor,constant: -20),
            contentLabel.heightAnchor.constraint(equalToConstant: 50),
            
            
            playImageview.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: 0),
            playImageview.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            playImageview.widthAnchor.constraint(equalToConstant: 30),
            playImageview.heightAnchor.constraint(equalToConstant: 30),
            
        ])
        
        preButton = button
    }
    
    func setupButtonLists() {
        
        let numberOfColumns: Int = 1
        
        let numberOfRows =   jishuArray.count/numberOfColumns+1
        let spacing: CGFloat = 10
        let buttonSize: CGFloat = (self.view.frame.width - spacing*7) / 6
        let heightBuView: CGFloat = 120
        for row in 0..<numberOfRows { //  6 rows of buttons, adjust as needed

            for col in 0..<numberOfColumns {
                   let index = row * numberOfColumns + col
                     
                   if index < jishuArray.count {
                       addnewButtonFunc(index, spacing, heightBuView, col, buttonSize)
                       
                   }
                  
               }
           }
        
              // 约束内容视图的高度，使其包含所有按钮
                var heightSummary:CGFloat = CGFloat(jishuArray.count) *   heightBuView
                if ( heightSummary <= 0.0) {
                    heightSummary = 200.0
                }
              NSLayoutConstraint.activate([
              
                    contentView.heightAnchor.constraint(equalToConstant:self.view.frame.height*0.6 + heightSummary   +  CGFloat(numberOfRows) * (buttonSize + spacing) + spacing)
                
              ])
    }
 
    func setupButtons() {
        
//        let buttonSize: CGFloat = 40.0
        let numberOfColumns: Int = 6
        
        let numberOfRows =   jishuArray.count/numberOfColumns+1
        let spacing: CGFloat = 10
        let buttonSize: CGFloat = (self.view.frame.width - spacing*7) / 6
        for row in 0..<numberOfRows { //  6 rows of buttons, adjust as needed

            for col in 0..<numberOfColumns {
                   let index = row * numberOfColumns + col
                   if index < jishuArray.count {
                       let button = UIButton(type: .custom)
                       button.setTitle(jishuArray[index], for: .normal)
                       button.setTitleColor(ThemeManager.shared.fontColor2, for: UIControl.State.normal)
                       button.setTitleColor(UIColor.MainColor(), for: UIControl.State.highlighted)
                       
                       button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                       
//                       button.backgroundColor = UIColor(fromHex: "#eeeef0")
                       button.layer.cornerRadius = 5
                       
                       
                       button.layer.borderColor = ThemeManager.shared.fontColor2.withAlphaComponent(0.2).cgColor
                       button.backgroundColor = ThemeManager.shared.fontColor.withAlphaComponent(0.1)
                       button.layer.borderWidth = 1
                       button.clipsToBounds = true

                       button.tag = index
                       button.addTarget(self, action: #selector(ButtonTapped(_:)), for: .touchUpInside)
                       
                       
                       contentView.addSubview(button)
                       button.translatesAutoresizingMaskIntoConstraints = false
                         
                     
                         NSLayoutConstraint.activate([
                             button.widthAnchor.constraint(equalToConstant: buttonSize),
                             button.heightAnchor.constraint(equalToConstant: buttonSize),
                             button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat(col) * (buttonSize + spacing) + spacing),
                             button.topAnchor.constraint(equalTo: lineLabel.bottomAnchor, constant: 35 + CGFloat(row) * (buttonSize + spacing) + spacing)
                         ])
                   }
                  
               }
           }
        
              // 约束内容视图的高度，使其包含所有按钮
        
              var heightSummary:CGFloat = CGFloat(remarksLabel.text?.count ?? 0) * 1.2
              print(heightSummary)
                if ( heightSummary <= 0.0) {
                    heightSummary = 200.0
                }
              NSLayoutConstraint.activate([
              
                    contentView.heightAnchor.constraint(equalToConstant:self.view.frame.height*0.6 + heightSummary   +  CGFloat(numberOfRows) * (buttonSize + spacing) + spacing)
                
              ])
       }
    
    @objc private func ButtonhdplayurlTapped(_ button:UIButton){
        if hdplayurl.count > 5 ,let u = URL(string: hdplayurl),let coverurl =  URL(string: self.movieDetail?.vodPic ?? "")   {
            
            let resource = KSPlayerResource(url: u,name: self.movieDetail?.vodName ?? "",cover: coverurl)
            let controller = DetailViewController()
            controller.resource = resource
//            self.show(controller, sender: self)
            if let s = self.movieDetail {
                LocalStore.saveToUserDefaults(RecentlyWatchVideo: s)
                //通知刷新列表
                
                // 发送通知
                NotificationCenter.default.post(name: .historyItemsUpdated, object: nil)
                
            }
            
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated:false)
        }
        
    }
    
    @objc private func ButtonTapped(_ button:UIButton){
               
        if let u = URL(string: jishuURLArray[button.tag]) ,let coverurl =  URL(string: self.movieDetail?.vodPic ?? "")  {
//           let resource = KSPlayerResource(url: u)
            let resource = KSPlayerResource(url: u ,name: self.movieDetail?.vodName ?? "",cover: coverurl)
           let controller = DetailViewController()
           controller.resource = resource
            
            if let s = self.movieDetail {
                if s.vodID > 10 {
                    
                    LocalStore.saveToUserDefaults(RecentlyWatchVideo: s)
                    //通知刷新列表
                    
                    // 发送通知
                    NotificationCenter.default.post(name: .historyItemsUpdated, object: nil)
                }
            }
            print(jishuURLArray[button.tag])
//            self.show(controller, sender: self)
           controller.modalPresentationStyle = .fullScreen
           self.present(controller, animated:false)
       }
    }
}
