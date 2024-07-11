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


// search viewconoller 
class HomeViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource,SFSafariViewControllerDelegate {
    
  
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var suggestionsTableView: UICollectionView!
    @IBOutlet weak var iconsCollectionView: UICollectionView!
    var searchSuggestionKeywords = [SearchRecommendation]()   // 搜索建议关键词
    var icons = [Website]() // 图标数组
    let cellId = "SuggestionCell"
    let iconCellId = "IconCell"
    
    var configData:ConfigResponse?
    var currentRecommandURL:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          
            
        }
        
        self.view.backgroundColor = UIColor(fromHex: "#eeeff1")

        searchBar.delegate = self
        suggestionsTableView.dataSource = self
        suggestionsTableView.delegate = self
         
         let layout = UICollectionViewFlowLayout()
         layout.scrollDirection = .horizontal
         layout.itemSize = CGSize(width: 100, height: 44)
         suggestionsTableView.collectionViewLayout = layout
         
 //        suggestionsTableView.backgroundColor = UIColor.lightGray
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
        let width = (iconsCollectionView.frame.width - 30) / 3
        layout2.itemSize = CGSize(width:width, height: 120)
//        layout2.minimumInteritemSpacing = 10 // 设置图标之间的间距)
//        layout2.minimumLineSpacing = 10 // 设置行间距
        layout2.sectionInset =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // 设置间距
        iconsCollectionView.collectionViewLayout = layout2
        

        sendRequestGetconfig()
        
    }
    
    
    func sendRequestGetconfig() {
        /**
         Request (38)
         get https://www.gooapis.com/player/getconfig
         */

        
        
//        // Fetch Request
        
        let requestComplete: (HTTPURLResponse?, Result<String, AFError>) -> Void = { response, result in
//            let end = CACurrentMediaTime()

            //if let response {
//                for (field, value) in response.allHeaderFields {
//                    debugPrint("\(field) \(value)" )
//                }
                switch  result {
                       case .success(let value):
                    // 将 JSON 字符串转换为 Data
                    
                    guard let data = value.data(using: String.Encoding.utf8) else {
                        print("Error: Cannot create data from JSON string.")
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
                                
                                if let s = response_config.data.searchrecommadlist.first?.keyword {
                                    self.searchBar.placeholder = s
                                }
                                // UI 更新代码
                                self.suggestionsTableView.reloadData()
                                self.iconsCollectionView.reloadData()
                                
                                
                            }
                        }
                        
                    } catch {
                        print("Error: \(error)")
                    }
                    
                           // 在主线程更新 UI 或处理数据
                           DispatchQueue.main.async {
                               // UI 更新代码
                           }
                       case .failure(let error):
                           debugPrint("HTTP Request failed: \(error)")
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
                       let safariViewController = SFSafariViewController(url: url)
                       safariViewController.delegate = self
                       present(safariViewController, animated: true, completion: nil)
                   }
        }
    }
    
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           if(collectionView === self.suggestionsTableView) {
               
               guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? KeywordCollectionViewCell else {
                   return UICollectionViewCell()
               }
               
               let keyword:SearchRecommendation = searchSuggestionKeywords[indexPath.item]
               cell.keywordBtn.setTitle(keyword.keyword, for: UIControl.State.normal)
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
                       let safariViewController = SFSafariViewController(url: url)
                       safariViewController.delegate = self
                       present(safariViewController, animated: true, completion: nil)
                   }
        }
       
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            controller.dismiss(animated: true, completion: nil)
        }
    
       // UICollectionViewDelegateFlowLayout 用于自定义布局（如果需要）
//       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//           if(collectionView === self.suggestionsTableView) {
//               return CGSize(width: 100, height: 44)
//           }
//           return CGSize(width: (iconsCollectionView.frame.width - 20) / 3, height: 100) // 每行 3 个图标，宽度平分
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
    var keywordBtn: UIButton!
    
    override init(frame: CGRect) {
          super.init(frame: frame)

          // 取得螢幕寬度
        keywordBtn =  UIButton(type: UIButton.ButtonType.custom)
        keywordBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
//        keywordBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        self.addSubview(keywordBtn)
      }

      required init?(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
    
}

