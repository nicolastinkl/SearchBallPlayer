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
    let searchrecommadlist: [SearchRecommendation]
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
class HomeViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
  
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var suggestionsTableView: UICollectionView!
    @IBOutlet weak var iconsCollectionView: UICollectionView!
    var searchSuggestionKeywords = [SearchRecommendation]()   // 搜索建议关键词
    var icons = [Website]() // 图标数组
    let cellId = "SuggestionCell"
    let iconCellId = "IconCell"
    
    var configData:ConfigResponse?
    var currentRecommandURL:String = ""
    @IBOutlet weak var labelSearchBar: UILabel!
    
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Example usage:
        let gradientView = GradientView(frame: view.bounds)
        gradientView.startColor = UIColor.MainColor() // Light blue
        gradientView.endColor =  UIColor(fromHex: "#eeeff1") //UIColor(red: 0.12, green: 0.56, blue: 1.0, alpha: 1.0)   // Blue
        
        view.insertSubview(gradientView, at: 0)
         
        // 设置搜索框背景为透明
        searchBar.backgroundImage = UIImage() // 使用空白的 UIImage
        labelSearchBar.layer.cornerRadius = 11
        labelSearchBar.layer.borderWidth = 1
        labelSearchBar.layer.borderColor = UIColor.MainColor().cgColor
        labelSearchBar.clipsToBounds = true
        
        searchButton.addTarget(self, action: #selector(self.openSearchTarget(_:)), for: UIControl.Event.touchUpInside)

        
        
            
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
            
          

        searchBar.delegate = self
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
//        layout2.minimumInteritemSpacing = 10 // 设置图标之间的间距)
//        layout2.minimumLineSpacing = 10 // 设置行间距
        layout2.sectionInset =  UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) // 设置间距
        iconsCollectionView.collectionViewLayout = layout2
        

        sendRequestGetconfig()
        
        configureNavigationBar()
        
        
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
          let appearance = UINavigationBarAppearance()
          appearance.configureWithTransparentBackground()
          appearance.backgroundColor = .clear
          appearance.shadowColor = .clear

          navigationController?.navigationBar.standardAppearance = appearance
          navigationController?.navigationBar.scrollEdgeAppearance = appearance
      }
  }
    
    @objc func openSearchTarget(_ sender: UIButton){
        
        if let text =  searchBar.text as? NSString {
            let newText = text as String
            if (text.contains("https://")  || text.contains("http://")  || text.contains("www.")  ){
                //target webview
              
                if let _ = URL(string: newText) {
                    let controller = SwiftWebVC(urlString:  newText )
                    self.show(controller, sender: self)
                    return
                }
              
                
            }
            
            if(text.length > 0){
                //search view
                
                searchRequest(searchText: newText)
            }
        }
        
        
        
    }
    
    func searchRequest(searchText: String) {
        
        SwiftLoader.show(title: "搜索中...", animated: true)
         
        
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
        
         
        
        AF.request("https://www.gooapis.com/player/search?keyword=\(searchText)", method: .get)
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

        
        SwiftLoader.show(title: "加载中...", animated: true)
        
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
                            
                            
                            
                            self.icons = response_config.data.classlist
                            DispatchQueue.main.async {
                                
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
        
        
        AF.request("https://www.gooapis.com/player/getconfig", method: .get)
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
            if let url = URL(string: urlString) {
//                       let safariViewController = SFSafariViewController(url: url)
//                       safariViewController.delegate = self
//                       present(safariViewController, animated: true, completion: nil)
                let controller = SwiftWebVC(urlString: urlString)
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
            if let url = URL(string: urlString) {
//                       let safariViewController = SFSafariViewController(url: url)
//                       safariViewController.delegate = self
//                       present(safariViewController, animated: true, completion: nil)
                
                let controller = SwiftWebVC(urlString: urlString)
                self.show(controller, sender: self)
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
         label.textColor = .darkGray
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
     }()
     
    
    override init(frame: CGRect) {
          super.init(frame: frame)
        
                contentView.backgroundColor = .white
                contentView.layer.cornerRadius = 10
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
        iconImageView.sd_setImage(with:  URL.init(string: iconurl)) { image, error,sdimagetype, url in
           
            if let err = error {
                //
                print("\(err.localizedDescription)  ")
                self.iconImageView.setIcon(icon:  .weather(.rainMix))
            }
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
        return keywordBtn
    }()
    
    override init(frame: CGRect) {
          super.init(frame: frame)

          // 取得螢幕寬度
        
        
        
        self.addSubview(keywordBtn)
        
        NSLayoutConstraint.activate([
            keywordBtn.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10),
            keywordBtn.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -2),
            keywordBtn.topAnchor.constraint(equalTo: topAnchor),
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
            keywordBtn.backgroundColor = UIColor(fromHex: "#fde6de")
//            keywordBtn.titleLabel?.textColor =
            keywordBtn.setTitleColor(UIColor(fromHex: "#e45a50"), for: UIControl.State.normal)
            
//            keywordBtn.setImage(UIImage(named: "fire"), for: .normal)
            // Adjust image and title position relative to each other
//            keywordBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: -5, bottom: 5, right: 15) // Adjust as needed
                   
        }else{
            
            keywordBtn.backgroundColor = UIColor(fromHex: "#e8e8e8")
//            keywordBtn.titleLabel?.textColor =
            keywordBtn.setTitleColor(UIColor(fromHex: "#787878"), for: UIControl.State.normal)
        }
        
    }
    
}

