//
//  MainViewController.swift
//  SDKVideoPlayer
//
//  Created by abc123456 on 2024/7/10.
//

import Foundation
//
import UIKit
import SafariServices
import Alamofire
import SDWebImage
import SwiftIcons
import SwiftfulLoadingIndicators
 

class MovieCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MovieCollectionViewCell"
    
    private let imageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 140),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: Video) {
        
        imageView.sd_setImage(with: URL.init(string: data.coverImageUrl), placeholderImage: UIImage(named: "placeholder-image"), context: nil)
        titleLabel.text = data.title
//        imageView.image = image
//        titleLabel.text = title
          
    }
}

struct VideoListResponse: Codable {
    let code: String
    let message: String
    let data: DataClassMain
}

struct DataClassMain: Codable {
    let videolist: [VideoCategory]
}

struct VideoCategory: Codable {
    let categoryName: String
    let videoListChild: [Video]
    
    enum CodingKeys: String, CodingKey {
        case categoryName = "categordname"
        case videoListChild = "videolistchild"
    }
}

struct Video: Codable {
    let title: String
    let link: String
    let coverImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case link
        case coverImageUrl = "corverimageurl"
    }
}


class HeaderView: UICollectionReusableView {
//    HeaderView
    
    
    static let identifier = "HeaderViewCollectionViewCell"
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
    }
}

// Main viewconoller
class MainViewController: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    //private var collectionView: UICollectionView!
      
      private var movies: [Video] =   [Video]()
      private var videoCategorys:[VideoCategory] = [VideoCategory]()
      
      override func viewDidLoad() {
          super.viewDidLoad()
          view.backgroundColor = UIColor(fromHex: "#f1f4f5")
          
          let layout = UICollectionViewFlowLayout()
          layout.scrollDirection = .vertical
          
          //collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
          collectionView.backgroundColor = .white
          collectionView.dataSource = self
          collectionView.delegate = self
          collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
          
          
          let layout2 = UICollectionViewFlowLayout()
          layout2.headerReferenceSize = CGSize(width: view.frame.width, height: 50)
          layout2.itemSize = CGSize(width: 120, height: 200)
          layout2.minimumInteritemSpacing = 10 // 设置图标之间的间距)
          layout2.minimumLineSpacing = 10 // 设置行间距
          layout2.sectionInset =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // 设置间距
          collectionView.collectionViewLayout = layout2
          
                 
          
          collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
              
          
          
          sendRequestGetconfig()
          
      }
      
      
      func sendRequestGetconfig() {
          
//          LoadingIndicator()
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
                      
                      print(value)

                      // 创建 JSONDecoder 实例
                      let decoder = JSONDecoder()

                      // 使用 JSONDecoder 解码数据
                      do {
                          let response_config = try decoder.decode(VideoListResponse.self, from: data)
                          print("Code: \(response_config.code)")
                          print("Message: \(response_config.message)")
                          
                          if(Int(response_config.code) == 1){
                              
                              //self.movies = response_config.data.videolist
                              
                              response_config.data.videolist.forEach { VideoCategoryItem in
//                                  self.movies?.append(VideoCategoryItem.categoryName)
                                  self.videoCategorys.append(VideoCategoryItem)
                                  VideoCategoryItem.videoListChild.forEach { Videoitem in
                                      self.movies.append(Videoitem)
                                  }
                              }
                              
                              
                               
                              DispatchQueue.main.async {
                                    
                                  self.collectionView.reloadData()
                                  
                                  
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
          
          
          AF.request("https://www.gooapis.com/player/home", method: .get)
              .validate(statusCode: 200..<300)
              .responseString(completionHandler: { response in
                  requestComplete(response.response, response.result)
                       
              })
                
      }

      
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          return videoCategorys[section].videoListChild.count
//          return movies.count
      }
      
    
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return videoCategorys.count
        }
    
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as! MovieCollectionViewCell
//          let  movie = movies[indexPath.item]
          let category = videoCategorys[indexPath.section]
          let  movie =  category.videoListChild[indexPath.item]
            cell.configure(with: movie)
                    
          return cell
      }
    
    
      func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
          let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:  HeaderView.identifier, for: indexPath) as! HeaderView
          let category = videoCategorys[indexPath.section]
          headerView.configure(with: category.categoryName)
          return headerView
      }
      
//      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//          let width = (collectionView.frame.width - 30) / 3
//          return CGSize(width: width, height: width * 1.5)
//      }
//      
//      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//          return 10
//      }
//      
//      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//          return 10
//      }
}
