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
////import SwiftLoader
////import KSPlayer
 

class MovieCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MovieCollectionViewCell"
    
    private let imageView: RoundedCornersImageView = {
        let imageView = RoundedCornersImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
//        imageView.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = ThemeManager.shared.fontColor
        label.numberOfLines = 2
        label.lineBreakMode = .byCharWrapping
//        label.layer.borderColor = ThemeManager.shared.fontColor.withAlphaComponent(0.6).cgColor
//        label.layer.borderWidth = 1 
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mutibgImageView:MutiGradientImageBgView = {
        let bgview = MutiGradientImageBgView()
        bgview.contentMode = .scaleAspectFill
        bgview.clipsToBounds = true
        bgview.layer.cornerRadius = 10
        bgview.backgroundColor = UIColor.black
        bgview.cornerRadius2 = 10
        bgview.translatesAutoresizingMaskIntoConstraints = false
        return bgview
    }()
    
    private let CenterLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
//        label.layer.borderColor = ThemeManager.shared.fontColor.withAlphaComponent(0.6).cgColor
//        label.layer.borderWidth = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(mutibgImageView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
//        contentView.backgroundColor = UIColor.lightGray
        
        contentView.addSubview(CenterLabel)
        NSLayoutConstraint.activate([
            
            
            mutibgImageView.topAnchor.constraint(equalTo: contentView.topAnchor ,constant: 10),
            mutibgImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mutibgImageView.widthAnchor.constraint(equalToConstant: 110),
            mutibgImageView.heightAnchor.constraint(equalToConstant: 140),
            
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor ,constant: 10),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 110),
            imageView.heightAnchor.constraint(equalToConstant: 140),
            
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            
            CenterLabel.topAnchor.constraint(equalTo: contentView.topAnchor ,constant: 10),
            CenterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            CenterLabel.widthAnchor.constraint(equalToConstant: 110),
            CenterLabel.heightAnchor.constraint(equalToConstant: 140),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(with data: Video) {
        
        if(data.vodID > 10){
            imageView.sd_setImage(with: URL.init(string: data.vodPic), placeholderImage: UIImage(named: "placeholder-image"), context: nil)
            titleLabel.text = ApplicationS.isCurrentLanguageEnglishOrChineseSimplified() ? data.vodName : data.vodEn
            imageView.isHidden = false
            mutibgImageView.isHidden = true
            CenterLabel.text = ""
        }else{
            titleLabel.text = ""
            imageView.image = UIImage()
            imageView.isHidden = true
            mutibgImageView.isHidden = false
            CenterLabel.text = ApplicationS.isCurrentLanguageEnglishOrChineseSimplified() ? data.vodName : data.vodEn
        }
         
          
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
    let vodID, typeID: Int
    let vodName, vodSub, vodEn: String
    let vodBlurb: String
    let vodRemarks, vodPubdate: String
    let vodStatus: Int
    let vodLetter, vodColor, vodTag, vodClass: String
    let vodPic: String

    let vodDirector, vodWriter, vodBehind: String?
    let vodLang, vodYear, vodVersion, vodState: String
    let vodPlot: Int
    let vodPlotName, vodPlotDetail, typeName: String
    let vodPlayURL: String
    let vodTotal: Int
    let vodContent: String
    
    enum CodingKeys: String, CodingKey {
        case vodID = "vod_id"
        case typeID = "type_id" 
        case vodContent = "vod_content"
        case vodName = "vod_name"
        case vodSub = "vod_sub"
        case vodEn = "vod_en"
        case vodBlurb = "vod_blurb"
        case vodRemarks = "vod_remarks"
        case vodPubdate = "vod_pubdate"
        case vodStatus = "vod_status"
        case vodLetter = "vod_letter"
        case vodColor = "vod_color"
        case vodTag = "vod_tag"
        case vodClass = "vod_class"
        case vodPic = "vod_pic"
        case vodDirector = "vod_director"
        case vodWriter = "vod_writer"
        case vodBehind = "vod_behind"
        case vodLang = "vod_lang"
        case vodYear = "vod_year"
        case vodVersion = "vod_version"
        case vodState = "vod_state"
        case vodPlot = "vod_plot"
        case vodPlotName = "vod_plot_name"
        case vodPlotDetail = "vod_plot_detail"
        case typeName = "type_name"
        case vodPlayURL = "vod_play_url"
        case vodTotal = "vod_total"
    }
}


class HeaderView: UICollectionReusableView {
//    HeaderView
    
    
    static let identifier = "HeaderViewCollectionViewCell"
     
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        label.textColor =  ThemeManager.shared.fontColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
     
    public let moreButton:UIButton = {
        
        let retryButton = UIButton(type: .system)
        retryButton.setTitle(NSLocalizedString("more", comment: ""), for: .normal)
        retryButton.setTitleColor(UIColor.MainColor(), for: .normal)
        retryButton.layer.cornerRadius = 20
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        return retryButton
    }()
    
    
    
    let lineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.MainColor().withAlphaComponent(0.5) //ThemeManager.shared.fontColor2
        return label
    }()
    
    private let iconTag:IconGradientView = IconGradientView()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        
//        self.backgroundColor = UIColor(fromHex: "#f2f4f6")
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        iconTag.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(moreButton)
        addSubview(lineLabel)
//        addSubview(iconTag)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 36),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            
            
            moreButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10),
            moreButton.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            moreButton.widthAnchor.constraint(equalToConstant: 80),
            moreButton.heightAnchor.constraint(equalToConstant: 20),
            
            lineLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            lineLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            lineLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10),
            lineLabel.heightAnchor.constraint(equalToConstant: 1),
            
            
            
//            iconTag.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
//            iconTag.topAnchor.constraint(equalTo: imageView.topAnchor),
//            iconTag.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
//            iconTag.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
//            
            
        ])
        
        
    }
    
    func configure(with title: String,at indexPath: IndexPath) {
        if indexPath.section == 0 {
            imageView.image = UIImage(named: "phone")
        }else{
            imageView.image = UIImage(named: "cloud")
        }
        
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
}

// Main viewconoller
class MainViewController: BaseViewController,  UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    //private var collectionView: UICollectionView!
      
      private var movies: [Video] =   [Video]()
      private var videoCategorys:[VideoCategory] = [VideoCategory]()
      
      override func viewDidLoad() {
          super.viewDidLoad()
//          view.backgroundColor = UIColor(fromHex: "#f1f4f5")
          
          let layout = UICollectionViewFlowLayout()
          layout.scrollDirection = .vertical
          
//          collectionView.backgroundColor = UIColor(fromHex: "#f2f4f6")
          
          self.view.backgroundColor = ThemeManager.shared.viewBackgroundColor
          //collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//          collectionView.backgroundColor = .white
          collectionView.dataSource = self
          collectionView.delegate = self
          collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
                    
          let layout2 = UICollectionViewFlowLayout()
          layout2.headerReferenceSize = CGSize(width: view.frame.width, height: 50)
          let width = (collectionView.frame.width - 30) / 3
          
//          print("width \(width)")
          layout2.itemSize = CGSize(width: width, height: 180)
          layout2.minimumInteritemSpacing = 0 // 设置图标之间的间距)
          layout2.minimumLineSpacing = 10 // 设置行间距
          layout2.sectionInset =  UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0) // 设置间距
          collectionView.collectionViewLayout = layout2
          

          collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
          
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
    
      
      
      func sendRequestGetconfig() {
          
          SwiftLoader.show(view: self.view,title: NSLocalizedString("Loading", comment: ""), animated: true)
          

        //  LoadingIndicator()
  //        // Fetch Request
          
          let requestComplete: (HTTPURLResponse?, Result<String, AFError>) -> Void = { response, result in
  
              SwiftLoader.hide()
              
              //if let response {
  //                for (field, value) in response.allHeaderFields {
  //                    debugPrint("\(field) \(value)" )
  //                }
                  switch  result {
                         case .success(let value):
                      // 将 JSON 字符串转换为 Data
                      
                      guard let data = value.data(using: String.Encoding.utf8) else {
                          
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
                              }else{
                                  
                              }
                              
                          } catch {
                              DispatchQueue.main.async {
                                  self.showNetworkErrorView(errormsg: "Json parse Error: \(error.localizedDescription)", clickBlock: {
                                      self.sendRequestGetconfig()
                                  })
                              }
                              
                          }
                         case .failure(let error):
//
//                             debugPrint("HTTP Request failed: ")
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
          
          
          AF.request("\(ApplicationS.baseURL)/player/home", method: .get,headers: ApplicationS.addCustomHeaders())
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
          headerView.configure(with: category.categoryName,at: indexPath)
          if indexPath.section == 0 {
              headerView.moreButton.isHidden = true
          }else{
              headerView.moreButton.isHidden = false
              
          }
          headerView.moreButton.addTarget(self, action: #selector(MoreButtonTapped(_:)), for: .touchUpInside)
          headerView.moreButton.tag = indexPath.section// category.videoListChild.first?.typeID ?? 0
          
          return headerView
      }
    
    @objc private func MoreButtonTapped(_ button:UIButton){

        let controller = MoreVideosViewController()
        let category = videoCategorys[button.tag]
        controller.requestType = category.videoListChild.first?.typeID ?? 0
        
        controller.titleString = category.categoryName
        self.show(controller, sender: self)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let category = videoCategorys[indexPath.section]
        if indexPath.section == 0{
            let searvc = CloudPlaylistController()
            let  movie =  category.videoListChild[indexPath.item]
            if indexPath.row == 0   {
                
                searvc.searchText =  ApplicationS.isCurrentLanguageEnglishOrChineseSimplified() ? movie.vodName : movie.vodEn
                searvc.viewtype = indexPath.row
                self.show(searvc, sender: self)
            }else  if  indexPath.row == 1 {
                let  movie =  category.videoListChild[indexPath.item]
                let  controller = SQBMovieDetailViewController()
                controller.movieDetail = movie
                self.show(controller, sender: self)
            }else{
                let  movie =  category.videoListChild[indexPath.item]
                let  controller = MoreListMovieDetailViewController()
                controller.movieDetail = movie
                self.show(controller, sender: self)
                
            }
           
        }else{
            
            let  movie =  category.videoListChild[indexPath.item]
            let  controller = SQBMovieDetailViewController()
            controller.movieDetail = movie
            self.show(controller, sender: self)
            
        }
        
//         self.present(controller, animated:false)
//        if let u = URL(string: "https://hn.bfvvs.com/play/6dBWo3We/index.m3u8") { //movie.link
//            let resource = KSPlayerResource(url: u)
//            let controller = DetailViewController()
//            controller.resource = resource
//            controller.modalPresentationStyle = .fullScreen
//            self.present(controller, animated:true)
//        }
    }
}
