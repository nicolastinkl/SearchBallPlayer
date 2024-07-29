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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
//        contentView.backgroundColor = UIColor.lightGray
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor ,constant: 10),
//            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//               imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            imageView.widthAnchor.constraint(equalToConstant: 110),
            imageView.heightAnchor.constraint(equalToConstant: 140),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: Video) {
        
        imageView.sd_setImage(with: URL.init(string: data.vodPic), placeholderImage: UIImage(named: "placeholder-image"), context: nil)
        titleLabel.text = data.vodName
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
//    let title: String
//    let link: String
//    let coverImageUrl: String
//    
//    enum CodingKeys: String, CodingKey {
//        case title
//        case link
//        case coverImageUrl = "corverimageurl"
//    }
    
    let vodID, typeID, typeID1, groupID: Int
       let vodName, vodSub, vodEn: String
       let vodStatus: Int
       let vodLetter, vodColor, vodTag, vodClass: String
       let vodPic: String
       let vodPicThumb, vodPicSlide, vodPicScreenshot, vodActor: String
       let vodDirector, vodWriter, vodBehind, vodBlurb: String
       let vodRemarks, vodPubdate: String
       let vodTotal: Int
       let vodSerial, vodTv, vodWeekday, vodArea: String
       let vodLang, vodYear, vodVersion, vodState: String
       let vodAuthor, vodJumpurl, vodTpl, vodTplPlay: String
       let vodTplDown: String
       let vodIsend, vodLock, vodLevel, vodCopyright: Int
       let vodPoints, vodPointsPlay, vodPointsDown, vodHits: Int
       let vodHitsDay, vodHitsWeek, vodHitsMonth: Int
       let vodDuration: String
       let vodUp, vodDown: Int
       let vodScore: String
       let vodScoreAll, vodScoreNum: Int
       let vodTime: String
       let vodTimeAdd, vodTimeHits, vodTimeMake, vodTrysee: Int
       let vodDoubanID: Int
       let vodDoubanScore, vodReurl, vodRelVOD, vodRelArt: String
       let vodPwd, vodPwdURL, vodPwdPlay, vodPwdPlayURL: String
       let vodPwdDown, vodPwdDownURL, vodContent, vodPlayFrom: String
       let vodPlayServer, vodPlayNote, vodPlayURL, vodDownFrom: String
       let vodDownServer, vodDownNote, vodDownURL: String
       let vodPlot: Int
       let vodPlotName, vodPlotDetail, typeName: String

    enum CodingKeys: String, CodingKey {
           case vodID = "vod_id"
           case typeID = "type_id"
           case typeID1 = "type_id_1"
           case groupID = "group_id"
           case vodName = "vod_name"
           case vodSub = "vod_sub"
           case vodEn = "vod_en"
           case vodStatus = "vod_status"
           case vodLetter = "vod_letter"
           case vodColor = "vod_color"
           case vodTag = "vod_tag"
           case vodClass = "vod_class"
           case vodPic = "vod_pic"
           case vodPicThumb = "vod_pic_thumb"
           case vodPicSlide = "vod_pic_slide"
           case vodPicScreenshot = "vod_pic_screenshot"
           case vodActor = "vod_actor"
           case vodDirector = "vod_director"
           case vodWriter = "vod_writer"
           case vodBehind = "vod_behind"
           case vodBlurb = "vod_blurb"
           case vodRemarks = "vod_remarks"
           case vodPubdate = "vod_pubdate"
           case vodTotal = "vod_total"
           case vodSerial = "vod_serial"
           case vodTv = "vod_tv"
           case vodWeekday = "vod_weekday"
           case vodArea = "vod_area"
           case vodLang = "vod_lang"
           case vodYear = "vod_year"
           case vodVersion = "vod_version"
           case vodState = "vod_state"
           case vodAuthor = "vod_author"
           case vodJumpurl = "vod_jumpurl"
           case vodTpl = "vod_tpl"
           case vodTplPlay = "vod_tpl_play"
           case vodTplDown = "vod_tpl_down"
           case vodIsend = "vod_isend"
           case vodLock = "vod_lock"
           case vodLevel = "vod_level"
           case vodCopyright = "vod_copyright"
           case vodPoints = "vod_points"
           case vodPointsPlay = "vod_points_play"
           case vodPointsDown = "vod_points_down"
           case vodHits = "vod_hits"
           case vodHitsDay = "vod_hits_day"
           case vodHitsWeek = "vod_hits_week"
           case vodHitsMonth = "vod_hits_month"
           case vodDuration = "vod_duration"
           case vodUp = "vod_up"
           case vodDown = "vod_down"
           case vodScore = "vod_score"
           case vodScoreAll = "vod_score_all"
           case vodScoreNum = "vod_score_num"
           case vodTime = "vod_time"
           case vodTimeAdd = "vod_time_add"
           case vodTimeHits = "vod_time_hits"
           case vodTimeMake = "vod_time_make"
           case vodTrysee = "vod_trysee"
           case vodDoubanID = "vod_douban_id"
           case vodDoubanScore = "vod_douban_score"
           case vodReurl = "vod_reurl"
           case vodRelVOD = "vod_rel_vod"
           case vodRelArt = "vod_rel_art"
           case vodPwd = "vod_pwd"
           case vodPwdURL = "vod_pwd_url"
           case vodPwdPlay = "vod_pwd_play"
           case vodPwdPlayURL = "vod_pwd_play_url"
           case vodPwdDown = "vod_pwd_down"
           case vodPwdDownURL = "vod_pwd_down_url"
           case vodContent = "vod_content"
           case vodPlayFrom = "vod_play_from"
           case vodPlayServer = "vod_play_server"
           case vodPlayNote = "vod_play_note"
           case vodPlayURL = "vod_play_url"
           case vodDownFrom = "vod_down_from"
           case vodDownServer = "vod_down_server"
           case vodDownNote = "vod_down_note"
           case vodDownURL = "vod_down_url"
           case vodPlot = "vod_plot"
           case vodPlotName = "vod_plot_name"
           case vodPlotDetail = "vod_plot_detail"
           case typeName = "type_name"
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
    
    func configure(with title: String) {
        imageView.image = UIImage(named: "cateicon")
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
          
//          self.title = NSLocalizedString("Viewing", comment: "")
          
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
          headerView.configure(with: category.categoryName)
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
        let  movie =  category.videoListChild[indexPath.item]
        let  controller = MovieDetailViewController()
        controller.movieDetail = movie
//        controller.modalPresentationStyle = .fullScreen
        self.show(controller, sender: self)
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
