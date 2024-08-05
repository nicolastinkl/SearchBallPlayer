//
//  MovieDetailViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/8/5.
//

import Foundation

import UIKit

import UIKit
import SafariServices
import Alamofire
import SDWebImage


// MARK: - Welcome
struct MovieDetailResponse: Codable {
    let code: Int
    let msg: String
    let results: [MovieDetailResult]
}

// MARK: - Result
struct MovieDetailResult: Codable {
    let iso639_1, iso3166_1, name, key: String
    let site: String
    let size: Int
    let type: String
    let official: Bool
    let publishedAt, id: String

    enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case name, key, site, size, type, official
        case publishedAt = "published_at"
        case id
    }
}



final class MovieDetailViewController: UIViewController, Storyboarded, Transitionable {
    
    @IBOutlet weak var playbutton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var posterContainerView: UIView!

    @IBOutlet private weak var titleContainerView: UIView!
    @IBOutlet private weak var titleContainerViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var optionsContainerView: UIView!

    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var overviewLabel: UILabel!

    static var storyboardName: String = "Home"
    
    var moveDetailModel:MovieDetailResponse?
     private let iconImageView: SDAnimatedImageView = {
         let imageView = SDAnimatedImageView()
         imageView.contentMode = .scaleAspectFill
         imageView.translatesAutoresizingMaskIntoConstraints = false
         return imageView
     }()
    
    

    @IBAction func playaction(_ sender: Any) {
    }
    private lazy var moreBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Ellipsis"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(moreBarButtonAction(_:)))
        return barButtonItem
    }()

    
//    private lazy var favoriteBarButtonItem: FavoriteToggleBarButtonItem = {
//        let barButtonItem = FavoriteToggleBarButtonItem()
//        barButtonItem.target = self
//        barButtonItem.action = #selector(favoriteButtonAction(_:))
//
//        return barButtonItem
//    }()

    // MARK: - Dependencies
    var viewModel: PopularMovie?
    var youtubeKey:String  = ""
    private(set) var transitionContainerView: UIView?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindables()

        configureUI()
        //viewModel?.getMovieDetail(showLoader: true)
        
        //get youtube play address
        sendRequestGetVideoDetail()
    }
    
    
    func sendRequestGetVideoDetail() {
        /**
         Request (38)
         get https://www.gooapis.com/player/getconfig
         */

        
        SwiftLoader.show(view: self.view,title: NSLocalizedString("Loading", comment: ""), animated: true)
        
//        // Fetch Request
        
        let requestCompletesendRequestGetVideoDetail: (HTTPURLResponse?, Result<String, AFError>) -> Void = { response, result in
//            let end = CACurrentMediaTime()
            SwiftLoader.hide()
            //if let response {
//                for (field, value) in response.allHeaderFields {
//                    debugPrint("\(field) \(value)" )
//                }
                switch  result {
                       case .success(let value):
                    // 将 JSON 字符串转换为 Data
//                    print("response: \(value)")
                    
                    guard let data = value.data(using: String.Encoding.utf8) else {
                        print("Error: Cannot create data from JSON string.")
                        DispatchQueue.main.async {
                            self.showNetworkErrorView(errormsg: "Error: Cannot create data from JSON string.", clickBlock: {
                                self.sendRequestGetVideoDetail()
                            })
                        }
                        return
                    }
                    

                    // 创建 JSONDecoder 实例
                    let decoder = JSONDecoder()

                    // 使用 JSONDecoder 解码数据
                    do {
                        let response_config = try decoder.decode(MovieDetailResponse.self, from: data)
                        print("Code: \(response_config.code)")
                        
                        if(Int(response_config.code) == 1){
                            self.moveDetailModel = response_config
                            
                           
                            DispatchQueue.main.async {
                                 
                                if let  mmovieDetailResult =   self.moveDetailModel?.results.first {
                                    self.youtubeKey = mmovieDetailResult.key
                                    self.playbutton.isHidden = false
                                    
                                }
                            }
                        }
                        
                    } catch {
                        print("Error: \(error)")
                        
                        DispatchQueue.main.async {
                            // UI 更新代码
                            self.showNetworkErrorView (errormsg: "\(error.localizedDescription)", clickBlock: {
                                self.sendRequestGetVideoDetail()
                            })
                        }
                    }
                    
                          
                       case .failure(let error):
                           debugPrint("HTTP Request failed: \(error)")
                            // 在主线程更新 UI 或处理数据
                            DispatchQueue.main.async {
                                // UI 更新代码
                                self.showNetworkErrorView (errormsg: "\(error.localizedDescription)", clickBlock: {
                                    self.sendRequestGetVideoDetail()
                                })
                            }
                           // 错误处理
                       }
                
//            }

 
        }
        
        
        AF.request("\(ApplicationS.baseURL)/player/videodetail?vid=\(self.viewModel?.id ?? 0)", method: .get,headers: ApplicationS.addCustomHeaders())
            .validate(statusCode: 200..<300)
            .responseString(completionHandler: { response in
                requestCompletesendRequestGetVideoDetail(response.response, response.result)
                     
            })
             
            //DataResponse<Decodable, AFError>
            
             
        
    }

    
    @objc func moreBarButtonAction (_ sender: UIButton) {
        
    }
 

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
//        if let viewController = container as? MovieDetailTitleViewController {
//            titleContainerViewHeightConstraint?.constant = viewController.preferredContentSize.height
//        }
    }

    // MARK: - Private

    private func setupUI() {
        
        title = viewModel?.originalTitle

//        coordinator?.embedMovieDetailPoster(on: self, in: posterContainerView)
//        coordinator?.embedMovieDetailTitle(on: self, in: titleContainerView)
//        coordinator?.embedMovieDetailOptions(on: self, in: optionsContainerView)

        
        setupNavigationBar()
        setupLabels()
        
        
    }

    private func setupNavigationBar() {
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        navigationItem.rightBarButtonItems = [moreBarButtonItem]
    }

    private func setupLabels() {
        genreLabel.font = FontHelper.body
        genreLabel.adjustsFontForContentSizeCategory = true

        releaseDateLabel.font = FontHelper.body
        releaseDateLabel.adjustsFontForContentSizeCategory = true

        overviewLabel.font = FontHelper.body
        overviewLabel.adjustsFontForContentSizeCategory = true
        
        
        posterContainerView.insertSubview(iconImageView, at: 0)
        
        NSLayoutConstraint.activate([
            iconImageView.trailingAnchor.constraint(equalTo: posterContainerView.trailingAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: posterContainerView.leadingAnchor),
            iconImageView.topAnchor.constraint(equalTo: posterContainerView.topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: posterContainerView.bottomAnchor),
             
        ])
    }

    private func configureUI() {
        guard let viewModel = viewModel else { return }
        releaseDateLabel.text = viewModel.releaseDate
        overviewLabel.text = viewModel.overview
        
        iconImageView.sd_setImage(with:  URL(string: ApplicationS.defaultBackdropImageBaseURLString.appending(viewModel.backdropPath) ), placeholderImage: UIImage(named: "placeholder-image"), context: [:])
        
        CollectionViewCellAnimator.fadeAnimateImageView(imageview:  iconImageView)
    }

    // MARK: - Reactive Behavior

    private func setupBindables() {
//        setupViewBindables()
//        setupLoaderBindable()
//        setupErrorBindables()
//        setupAlertBindables()
    }

}


