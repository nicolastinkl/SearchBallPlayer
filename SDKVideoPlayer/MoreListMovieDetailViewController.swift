//
//  MoreListMovieDetailViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/8/5.
//

import Foundation

import UIKit


import Alamofire
import SDWebImage
import SwiftIcons

class MoreListMovieDetailViewController: BaseViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    var movieDetail: Video?
    var iconsCollectionView: UICollectionView!
    var popularList: [PopularMovie] =  [PopularMovie]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ThemeManager.shared.viewBackgroundColor
        
        setupCollectView()
        
    }
    func setupCollectView() {
        
        let previewLayoutWidth = Constants.previewCellHeight / CGFloat(UIConstants.posterAspectRatio)
        let sssdflayout =  VerticalFlowLayout(preferredWidth: previewLayoutWidth,
                                  preferredHeight: Constants.previewCellHeight,
                                  minColumns: Constants.previewLayoutMinColumns)
        
        
        iconsCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: sssdflayout)
        
        iconsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconsCollectionView)
        NSLayoutConstraint.activate([
            iconsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 0),
            iconsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: 0),
            iconsCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            iconsCollectionView.bottomAnchor.constraint(equalTo:view.bottomAnchor),
        ])
        //icon list
        iconsCollectionView.dataSource = self
        iconsCollectionView.delegate = self
        
         
//        iconsCollectionView.registerNib(cellType: UpcomingMovieExpandedCollectionViewCell.self)
        iconsCollectionView.registerNib(cellType: UpcomingMoviePreviewCollectionViewCell.self)
        
         
        iconsCollectionView.backgroundColor = UIColor.clear
       
        
        sendRequestGetconfig()
    }
    
    
    private func setupCollectionViewLayout() {
        
        let previewLayoutWidth = Constants.previewCellHeight / CGFloat(UIConstants.posterAspectRatio)
        iconsCollectionView.collectionViewLayout =  VerticalFlowLayout(preferredWidth: previewLayoutWidth,
                                  preferredHeight: Constants.previewCellHeight,
                                  minColumns: Constants.previewLayoutMinColumns)
        
//
//        let collectionViewWidth = iconsCollectionView.frame.width
//        let detailLayoutWidth = collectionViewWidth - Constants.detailCellOffset
//        let vflow = VerticalFlowLayout(preferredWidth: detailLayoutWidth, preferredHeight: Constants.detailCellHeight)
//        
//        iconsCollectionView.collectionViewLayout = vflow
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

         
        coordinator.animate(alongsideTransition: { _ in
            self.setupCollectionViewLayout()
        }, completion: nil)
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
                    print("response: \(value)")
                    
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
                            
                             
                            self.popularList.append(contentsOf: response_config.data.popularList)
                            
                            DispatchQueue.main.async {
                                
                                self.iconsCollectionView.reloadData()
                                self.setupCollectionViewLayout()
                                
                                
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
        
        
        AF.request("\(ApplicationS.baseURL)/player/getmovepopular?type=\(self.movieDetail?.vodEn ?? "")", method: .get,headers: ApplicationS.addCustomHeaders())
            .validate(statusCode: 200..<300)
            .responseString(completionHandler: { response in
                requestComplete(response.response, response.result)
                     
            })
             
            //DataResponse<Decodable, AFError>
            
             
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let preCell = collectionView.dequeueReusableCell(with: UpcomingMoviePreviewCollectionViewCell.self, for: indexPath) as UpcomingMoviePreviewCollectionViewCell? else {
            return UICollectionViewCell()
        }
        let ppmodel = popularList[indexPath.row]
        preCell.setupBindables(viewModel: ppmodel)
        return preCell
    }
    
    private var displayedCellsIndexPaths = Set<IndexPath>()
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
 
        if !displayedCellsIndexPaths.contains(indexPath) {
            displayedCellsIndexPaths.insert(indexPath)
            CollectionViewCellAnimator.fadeAnimate(cell: cell)
        }
    }
    
    
}
