//
//  HomeViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/9.
//

import Foundation

//
import UIKit
import SafariServices
import Alamofire
import SDWebImage
import SwiftIcons
import AppTrackingTransparency

//import SwiftLoader
//import SwiftWebVC
// 基本的数据模型
struct Website: Codable {
    let name: String
    let url: String
    let iconurl: String
}

struct SearchRecommendation: Codable {
    let keyword: String
    let url: String
}

 
struct ConfigResponse: Codable {
    let code: String
    let message: String
    let data: DataClass
}

struct DataClass: Codable {
    let classlist: [Website]
    let searchlist: [SearchRecommendation]
    let searchrecommadlist: [SearchRecommendation]
    let blackDomains: [String]
}




//"page":"1","pagecount":1,"limit":"20","total":17,
struct VideoSearchResponse: Codable {
    let code: Int
    let message: String
    let page: Int
    let pagecount: Int
    let limit: Int
    let total: Int
    let data: [Video]
}






// Home Search viewconoller
class HomeViewController: BaseViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
  
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var suggestionsTableView: UICollectionView!
    @IBOutlet weak var iconsCollectionView: UICollectionView!
    var searchSuggestionKeywords = [SearchRecommendation]()   // 搜索建议关键词
    var icons = [Website]() // 图标数组
    var searchlist: [SearchRecommendation]?
    var currentIndex: Int = 0 // 当前展示的搜索项索引

    
    
    let cellId = "SuggestionCell"
    let iconCellId = "IconCell"
    
    var configData:ConfigResponse?
    var currentRecommandURL:String = ""
    @IBOutlet weak var labelSearchBar: UILabel!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var dajiaLabel: UILabel!
    
    var timer: Timer?
    
      func applicationDidBecomeActive( ) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                if #available(iOS 14, *) {
                    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in

                    })
                }
            })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                if #available(iOS 14, *) {
                    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in

                    })
                }
            })
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applicationDidBecomeActive()
    }
    
    let gradientView = GradientView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Example usage:
        
        gradientView.startColor = UIColor.MainColor() // Light blue
        gradientView.endColor = ThemeManager.shared.viewBackgroundColor
        //  UIColor(fromHex: "#eeeff1") //UIColor(red: 0.12, green: 0.56, blue: 1.0, alpha: 1.0)   // Blue
        
        view.insertSubview(gradientView, at: 0)
        
        
        // 设置 Auto Layout 约束
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        gradientView.frame = view.frame
        
        // 设置搜索框背景为透明
        searchBar.backgroundImage = UIImage() // 使用空白的 UIImage
        labelSearchBar.layer.cornerRadius = 11
        labelSearchBar.layer.borderWidth = 1
        labelSearchBar.layer.borderColor = UIColor.MainColor().cgColor
        labelSearchBar.clipsToBounds = true
        
        searchButton.addTarget(self, action: #selector(self.openSearchTarget(_:)), for: UIControl.Event.touchUpInside)
        searchButton.backgroundColor = UIColor.MainColor()
        
        // 设置搜索框背景颜色为白色
        //        searchBar.barTintColor = .white
        
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 0),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: 0),
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo:view.bottomAnchor),
        ])
        
        // 添加圆角
        let maskPath = UIBezierPath(roundedRect: searchButton.bounds,
                                    byRoundingCorners: [.topRight, .bottomRight],
                                    cornerRadii: CGSize(width: 10.0, height: 10.0))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = searchButton.bounds
        maskLayer.path = maskPath.cgPath
        searchButton.layer.mask = maskLayer
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            
        }
         
        suggestionsTableView.dataSource = self
        suggestionsTableView.delegate = self
        //
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 44)
        suggestionsTableView.collectionViewLayout = layout
        
        // 如果使用 storyboard
        suggestionsTableView.register(KeywordCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        //icon list
        iconsCollectionView.dataSource = self
        iconsCollectionView.delegate = self
        iconsCollectionView.register(IconCollectionViewCell.self, forCellWithReuseIdentifier:iconCellId)
        
        
        suggestionsTableView.backgroundColor = UIColor.clear
        iconsCollectionView.backgroundColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        let layout2 = UICollectionViewFlowLayout()
        let width = (iconsCollectionView.frame.width - 60) / 4
        layout2.itemSize = CGSize(width:width, height: width)
        layout2.minimumInteritemSpacing = 10 // 设置图标之间的间距)
        layout2.minimumLineSpacing = 10 // 设置行间距
        
        layout2.sectionInset =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // 设置间距
        iconsCollectionView.collectionViewLayout = layout2
        
        sendRequestGetconfig()
        
        
        // 创建 UISearchBar
        searchBar.delegate = self
         
        if #available(iOS 15, *) {
            
        }
        
        configureNavigationBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(historyItemsUpdated), name: .favitorItemsUpdated, object: nil) 
        
//        self.title = NSLocalizedString("Browser", comment: "")
        
    }    
    @objc func historyItemsUpdated() {
        // 刷新表格视图
        if let newweb = LocalStore.readToWebsiteFaviators()?.first {
//            self.icons.forEach { oldwebsite in
//                if !newweb.url.localizedCaseInsensitiveContains(oldwebsite.url) {
//
//                }
//            }
            self.icons.insert(newweb, at: 0)
            
            self.iconsCollectionView.reloadData()
        }
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(self.icons) {
//            let newStr = String(data: encoded, encoding: String.Encoding.utf8)
//            print("\n" ,  "json: " , newStr!)
//
//        }
     }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { context in
            // 在动画过渡期间更新视图大小
            self.gradientView.frame = CGRect(origin: .zero, size: size)
        }, completion: nil)
    }

    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // 输入开始时停止定时器
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerAction() {
           // 定时器触发时执行的操作
           
           // 在这里添加你想要执行的具体操作
            if let searchlist = searchlist, !searchlist.isEmpty {
                   // 获取当前索引的搜索项的 title 属性
                let currentItemTitle = searchlist[currentIndex].keyword
                   //print("Timer fired! Current item title: \(currentItemTitle)")
                   // self.searchBar.text = currentItemTitle
                   // 在这里可以处理获取的 title，例如更新界面或其他操作
                // 添加动画效果
                // 隐藏老的文字，新的文字移动到上方暂停显示
                // 1. 移动老的文字向上隐藏
                     UIView.animate(withDuration: 0.1, animations: {
                         self.searchBar.transform = CGAffineTransform(translationX: 0, y: -self.searchBar.bounds.height/4)
                     }) { (finished) in
                        
                     }

                // 2. 设置新的文字
                self.searchBar.text = currentItemTitle
                
                // 3. 将新的文字移动到搜索栏位置
                self.searchBar.transform = CGAffineTransform(translationX: 0, y: self.searchBar.bounds.height/4)
                
                // 4. 动画新的文字向下移动显示，并恢复搜索栏原始位置
                UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut, animations: {
                    self.searchBar.transform = .identity
                }, completion: { (finished) in
                    // 5. 动画完成后，恢复搜索栏原始位置
                    self.searchBar.transform = .identity
                })
                   // 移动到下一个索引，循环展示
                   currentIndex = (currentIndex + 1) % searchlist.count
               }
        
    }
    
     

  override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      // 确保在视图将要出现时隐藏导航栏
      navigationController?.setNavigationBarHidden(true, animated: animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      // 确保在视图将要消失时显示导航栏
      navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
    
  private func configureNavigationBar() {
      if #available(iOS 13.0, *) {
          // iOS 13 及以上版本使用 UINavigationBarAppearance
          // iOS 13 及以上版本使用 UINavigationBarAppearance
          let appearance = UINavigationBarAppearance()
          appearance.configureWithTransparentBackground()
          appearance.backgroundColor = .clear
          appearance.shadowColor = .clear

          navigationController?.navigationBar.standardAppearance = appearance
          navigationController?.navigationBar.scrollEdgeAppearance = appearance
      }
  }
    
    @objc func openSearchTarget(_ sender: UIButton){
        
        self.searchBar.endEditing(true)
        if let text =  searchBar.text as? NSString {
            let newText = text as String
            
            if (text.contains("https://")  || text.contains("http://")  || text.contains("www.")  ){
                //target webview
              
                if let _ = URL(string: newText) {
                    let controller = SwiftWebVC(urlString:  newText )
                    controller.hidesBottomBarWhenPushed = true
                    var blackBol = false
                    configData?.data.blackDomains.forEach({ blackurl in
                        if blackurl.localizedCaseInsensitiveContains(newText) {
                            blackBol = true
                        }
                    })
                    controller.proxyHttps = blackBol
                    self.show(controller, sender: self)
                    return
                }
                
            }
            
            if(text.length > 0){
                //search view
                
                //检查是否是推荐的关键词
                var isNotSearchlist:Bool = true
                if let searchlist = searchlist, !searchlist.isEmpty {
                    searchlist.forEach { model in
                        if model.keyword == newText && model.url.count > 10 {
                            let controller = SwiftWebVC(urlString:  model.url )
                            controller.hidesBottomBarWhenPushed = true
                            var blackBol = false
                            configData?.data.blackDomains.forEach({ blackurl in
                                if blackurl.localizedCaseInsensitiveContains(model.url) {
                                    blackBol = true
                                }
                            })
                            controller.proxyHttps = blackBol
                            self.show(controller, sender: self)
                            isNotSearchlist = false
                        }
                    }
                }
                
                if isNotSearchlist{
                    searchRequest(searchText: newText)
                }
                
            }
        }
         
    }
    
    func searchRequest(searchText: String) {
        timer?.invalidate()
        SwiftLoader.show(view: self.view,title: NSLocalizedString("Searching", comment: ""), animated: true)
         
        
        let requestComplete1: (HTTPURLResponse?, Result<String, AFError>) -> Void = { response, result in

            SwiftLoader.hide()
            
            //if let response {
//                for (field, value) in response.allHeaderFields {
//                    debugPrint("\(field) \(value)" )
//                }
                switch  result {
                       case .success(let value):
                    // 将 JSON 字符串转换为 Data
                    
//                    var  s = ""
//                    if let sstr = value as? NSString {
//                        s = sstr.replacingOccurrences(of: "null", with: "\"\"")
//                    }
//                    
//                    print(s)
                    guard let data = value.data(using: String.Encoding.utf8) else {
                        
                         
//                        let error = SearchError.errorWith("Error: Cannot create data from JSON string.")
                        self.showSearchErrorAlert(on:self, error: "Error: Cannot create data from JSON string." )
                        return
                    }
                    
                    
                    // 创建 JSONDecoder 实例
                    let decoder = JSONDecoder()

                        // 使用 JSONDecoder 解码数据
                        do {
                            let response_config = try decoder.decode(VideoSearchResponse.self, from: data)
                            print("Code: \(response_config.code)")
                            
                            if(Int(response_config.code) == 1){
                                
                                //self.movies = response_config.data.videolist
                                
//                                response_config.data.videolist.forEach { VideoCategoryItem in
//  //                                  self.movies?.append(VideoCategoryItem.categoryName)
//                                   // self.videoCategorys.append(VideoCategoryItem)
//                                    VideoCategoryItem.videoListChild.forEach { Videoitem in
//                                        self.movies.append(Videoitem)
//                                    }
//                                }
                                 
                                DispatchQueue.main.async {
 
                                    let searvc = SearcViewController()
                                    searvc.searchList = response_config.data
                                    searvc.searchText =  self.searchBar.text ?? "" // "'\()' 搜索结果"
                                    
                                    
                                    searvc.total = response_config.total
                                    searvc.page = response_config.page
                                    searvc.limit = response_config.limit
                                    searvc.pagecount = response_config.pagecount
                                    
                                    self.show(searvc, sender: self)
                                }
                            }
                            
                        } catch {
                            print("\(error.localizedDescription)")
//                            let error = SearchError.errorWith("Json parse Error: \(error.localizedDescription)")
                            self.showSearchErrorAlert(on:self, error: "Json parse Error: \(error.localizedDescription)" )
                            
                           
                            
                        }
                    
                            
                       case .failure(let error):
                            
//                            let error = SearchError.errorWith("\(error.localizedDescription)")
                            self.showSearchErrorAlert(on:self, error: "\(error.localizedDescription)" )
                    
                     
                       }
                
//            }

           
 
        }
        
         
        var searchTextEncoding = ""
        if let encodedQuery = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            searchTextEncoding = encodedQuery
        }            
        
        AF.request("\(ApplicationS.baseURL)/player/search?keyword=\(searchTextEncoding)", method: .get,headers: ApplicationS.addCustomHeaders())
            .validate(statusCode: 200..<300)
            .responseString(completionHandler: { response in
                requestComplete1(response.response, response.result)
                     
            })
    }
    
    func sendRequestGetconfig() {
        /**
         Request (38)
         get https://www.gooapis.com/player/getconfig
         */

        
        SwiftLoader.show(view: self.view,title: NSLocalizedString("Loading", comment: ""), animated: true)
        
//        // Fetch Request
        
        let requestComplete: (HTTPURLResponse?, Result<String, AFError>) -> Void = { response, result in
//            let end = CACurrentMediaTime()
            SwiftLoader.hide()
            //if let response {
//                for (field, value) in response.allHeaderFields {
//                    debugPrint("\(field) \(value)" )
//                }
                switch  result {
                       case .success(let value):
                    // 将 JSON 字符串转换为 Data
                    
                    
                    guard let data = value.data(using: String.Encoding.utf8) else {
                        print("Error: Cannot create data from JSON string.")
                        DispatchQueue.main.async {
                            self.showNetworkErrorView(errormsg: "Error: Cannot create data from JSON string.", clickBlock: {
                                self.sendRequestGetconfig()
                            })
                        }
                        return
                    }
                    

                    // 创建 JSONDecoder 实例
                    let decoder = JSONDecoder()

                    // 使用 JSONDecoder 解码数据
                    do {
                        let response_config = try decoder.decode(ConfigResponse.self, from: data)
                        print("Code: \(response_config.code)")
                        print("Message: \(response_config.message)")
                        
                        if(Int(response_config.code) == 1){
                            self.configData = response_config
                            self.searchSuggestionKeywords = response_config.data.searchrecommadlist
                            
                            
                            
                            //self.icons = response_config.data.classlist
                            if let olds = LocalStore.readToWebsiteFaviators() {
//                                olds.forEach { web in
//                                    self.icons.append(web)
//                                }
                                self.icons =  olds //response_config.data.classlist
                               
                                
                            }
                            self.icons.append(contentsOf: response_config.data.classlist)
                            self.searchlist = response_config.data.searchlist
                            DispatchQueue.main.async {
                                self.dajiaLabel.text = NSLocalizedString("recommandSearch", comment: "")
                                self.timer =   Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
                                
//                                if let s = response_config.data.searchrecommadlist.first?.keyword {
////                                    self.searchBar.placeholder = s
//                                }
                                // UI 更新代码
                                self.suggestionsTableView.reloadData()
                                self.iconsCollectionView.reloadData()
                                
                                
                            }
                        }
                        
                    } catch {
                        print("Error: \(error)")
                        
                        DispatchQueue.main.async {
                            // UI 更新代码
                            self.showNetworkErrorView (errormsg: "\(error.localizedDescription)", clickBlock: {
                                self.sendRequestGetconfig()
                            })
                        }
                    }
                    
                          
                       case .failure(let error):
                           debugPrint("HTTP Request failed: \(error)")
                            // 在主线程更新 UI 或处理数据
                            DispatchQueue.main.async {
                                // UI 更新代码
                                self.showNetworkErrorView (errormsg: "\(error.localizedDescription)", clickBlock: {
                                    self.sendRequestGetconfig()
                                })
                            }
                           // 错误处理
                       }
                
//            }

 
        }
        
        
        AF.request("\(ApplicationS.baseURL)/player/getconfig", method: .get,headers: ApplicationS.addCustomHeaders())
            .validate(statusCode: 200..<300)
            .responseString(completionHandler: { response in
                requestComplete(response.response, response.result)
                     
            })
             
            //DataResponse<Decodable, AFError>
            
             
        
    }



    
       // UISearchBarDelegate 方法
       func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder()
           // 处理搜索逻辑
           openSearchTarget(UIButton())
       }
     
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if(collectionView === self.suggestionsTableView) {
                return searchSuggestionKeywords.count
            }
            return icons.count
       }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView === self.suggestionsTableView) {
            
            
        }else{
            let keyword:Website = icons[indexPath.item]
            let urlString = keyword.url
            if let _ = URL(string: urlString) {
//                       let safariViewController = SFSafariViewController(url: url)
//                       safariViewController.delegate = self
//                       present(safariViewController, animated: true, completion: nil)
                let controller = SwiftWebVC(urlString: urlString)
                controller.hidesBottomBarWhenPushed = true
                var blackBol = false
                configData?.data.blackDomains.forEach({ blackurl in
                    if blackurl.localizedCaseInsensitiveContains(urlString) {
                        blackBol = true
                    }
                })
                controller.proxyHttps = blackBol
                self.show(controller, sender: self)
                   }
        }
    }
    
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           if(collectionView === self.suggestionsTableView) {
               
               guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? KeywordCollectionViewCell else {
                   return UICollectionViewCell()
               }
               
               let keyword:SearchRecommendation = searchSuggestionKeywords[indexPath.item]
               
               cell.configData(title: keyword.keyword, isFirst: indexPath.item == 0)
               cell.keywordBtn.tag = indexPath.item
               cell.keywordBtn.addTarget(self, action: #selector(self.openRecommandTarget(_:)), for: UIControl.Event.touchUpInside)
               return cell
           }
           
           guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: iconCellId, for: indexPath) as? IconCollectionViewCell else {
               return UICollectionViewCell()
           }
           
           let keyword:Website = icons[indexPath.item]
           
           cell.configure(with: keyword.iconurl, title: keyword.name)
           return cell
           
           
       }
    
        @objc func openRecommandTarget(_ sender: UIButton){
            let keyword:SearchRecommendation =  searchSuggestionKeywords[sender.tag]
            
            let urlString = keyword.url
            print("<\(urlString)>")
            
            if let _ = URL(string: urlString) {
//                       let safariViewController = SFSafariViewController(url: url)
//                       safariViewController.delegate = self
//                       present(safariViewController, animated: true, completion: nil)
                
                let controller = SwiftWebVC(urlString: urlString)
                controller.hidesBottomBarWhenPushed = true
                var blackBol = false
                configData?.data.blackDomains.forEach({ blackurl in
                    if blackurl.localizedCaseInsensitiveContains(urlString) {
                        blackBol = true
                    }
                })
                controller.proxyHttps = blackBol
                self.show(controller, sender: self)
            }else{
                //openSearchTarget
                searchBar.text = keyword.keyword
                openSearchTarget(UIButton())
            }
        }
       
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            controller.dismiss(animated: true, completion: nil)
        }
    
       // UICollectionViewDelegateFlowLayout 用于自定义布局（如果需要）
//       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//           if(collectionView === self.suggestionsTableView) {
//               let keyword:SearchRecommendation = searchSuggestionKeywords[indexPath.item]
//               
//               return CGSize(width: 60 * keyword.keyword.count, height: 44)
//           }
//            
//           return CGSize(width: (iconsCollectionView.frame.width - 40) / 3, height: 120) // 每行 3 个图标，宽度平分
//       }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        cell.layer.cornerRadius = 10 // 设置圆角
//        cell.layer.shadowColor = UIColor.black.cgColor // 设置阴影颜色
//        cell.layer.shadowOffset = CGSize(width: 0, height: 2) // 设置阴影偏移
//        cell.layer.shadowOpacity = 0.3 // 设置阴影透明度
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        cell.layer.shadowPath = nil // 移除阴影
    }

}

// 自定义 UICollectionViewCell
class IconCollectionViewCell: UICollectionViewCell {
//    var iconImageView: SDAnimatedImageView!
//    var icontitle: UILabel!
    
    
     private let iconImageView: SDAnimatedImageView = {
         let imageView = SDAnimatedImageView()
         imageView.contentMode = .scaleAspectFit
         imageView.translatesAutoresizingMaskIntoConstraints = false
         return imageView
     }()
     
     private let titleLabel: UILabel = {
         let label = UILabel()
         label.textAlignment = .center
         label.font = UIFont.systemFont(ofSize: 12)
         label.numberOfLines = 2
         label.lineBreakMode = .byCharWrapping
         label.textColor = ThemeManager.shared.fontColor
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
     }()
     
    
    override init(frame: CGRect) {
          super.init(frame: frame)
        
        
        let currentUserInterfaceStyle = ThemeManager.shared.currentUserInterfaceStyle
        switch currentUserInterfaceStyle {
            case .dark:
                contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            case .light:
                contentView.backgroundColor = UIColor(fromHex: "#eeeff1")
            default:
                contentView.backgroundColor = UIColor(fromHex: "#eeeff1")
        }
        
                contentView.layer.cornerRadius = 5
                contentView.layer.shadowColor = UIColor.white.cgColor
                contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
                contentView.layer.shadowOpacity = 0.1
                contentView.layer.shadowRadius = 1
                contentView.layer.masksToBounds = false
                
                contentView.addSubview(iconImageView)
                contentView.addSubview(titleLabel)
                
                NSLayoutConstraint.activate([
                    iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                    iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
                    iconImageView.widthAnchor.constraint(equalToConstant: 20),
                    iconImageView.heightAnchor.constraint(equalToConstant: 20),
                    
                    titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
                    titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                    titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
                ])
        
      }

      required init?(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
    
    func configure(with iconurl: String, title: String) {

//            iconImageView.sd_setImage(with: URL.init(string: iconurl), placeholderImage: UIImage(named: "placeholder-image"), context: nil)
        if iconurl.count > 10, let u = URL(string: iconurl){
            iconImageView.sd_setImage(with: u) { image, error,sdimagetype, url in
               
                if let err = error {
                    //
                    print("\(err.localizedDescription)  ")
                    self.iconImageView.image = UIImage(named: "internet")
                    //self.iconImageView.setIcon(icon:  .weather(.rainMix))
                }
            }
        }else{
            self.iconImageView.image = UIImage(named: "internet")
//            self.iconImageView.setIcon(icon:  .weather(.rainMix))
        }
        
            titleLabel.text = title
        }
    
}


class KeywordCollectionViewCell: UICollectionViewCell {
    
//    @IBOutlet weak
    var keywordBtn: UIButton = {
        let keywordBtn  =    UIButton(type: UIButton.ButtonType.custom)
        
        keywordBtn.layer.cornerRadius = 15
        keywordBtn.clipsToBounds = true
        keywordBtn.translatesAutoresizingMaskIntoConstraints = false
        keywordBtn.layer.borderWidth = 1
        keywordBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
    
        return keywordBtn
    }()
    
    override init(frame: CGRect) {
          super.init(frame: frame)
        
        self.addSubview(keywordBtn)
        
        NSLayoutConstraint.activate([
            keywordBtn.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10),
            keywordBtn.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -2),
            keywordBtn.topAnchor.constraint(equalTo: topAnchor,constant: 2),
//            keywordBtn.bottomAnchor.constraint(equalTo:bottomAnchor),
            keywordBtn.heightAnchor.constraint(equalToConstant: 30)
        ])
        
      }

      required init?(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
    
    func configData(title: String, isFirst: Bool){
        
//        keyword.keyword
        keywordBtn.setTitle(title, for: UIControl.State.normal)
        
//        keywordBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
//        keywordBtn.frame = CGRect(x: 10, y: 0, width: 30 * title.count, height: 44)
        
        if (isFirst){
            //keywordBtn.backgroundColor = UIColor(fromHex: "#fde6de")
//            keywordBtn.titleLabel?.textColor =
            keywordBtn.setTitleColor(UIColor(fromHex: "#e45a50"), for: UIControl.State.normal)
            keywordBtn.layer.borderColor = UIColor(fromHex: "#e45a50").cgColor
//            keywordBtn.setImage(UIImage(named: "fire"), for: .normal)
            // Adjust image and title position relative to each other
//            keywordBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: -5, bottom: 5, right: 15) // Adjust as needed
                   
        }else{
            
            //keywordBtn.backgroundColor = UIColor(fromHex: "#e8e8e8")
//            keywordBtn.titleLabel?.textColor =
            
            keywordBtn.layer.borderColor = ThemeManager.shared.fontColor2.cgColor
            keywordBtn.setTitleColor(ThemeManager.shared.fontColor2, for: UIControl.State.normal)
            //keywordBtn.setTitleColor(UIColor(fromHex: "#787878"), for: UIControl.State.normal)
        }
        
    }
    
}
 
