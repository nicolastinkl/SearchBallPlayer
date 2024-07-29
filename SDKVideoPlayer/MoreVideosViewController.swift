//
//  MoreVideosViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/12.
//

import Foundation


//MoreVideosViewController

import UIKit
import Alamofire
import SDWebImage
import SwiftIcons
import SwiftfulLoadingIndicators
//import SwiftLoader
//import KSPlayer

class MoreVideosViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
   
    public var requestType : Int = 0
    
   private let tableView = UITableView()
     
   private let loadMoreOffset = 20 // 定义触发加载更多的偏移量
    
    var searchList:[Video]? = [Video]()
    
    var isLoading = false
    var hasMoreData = true
    
    var total = 0
    var page = 0
    var limit = 0
    var pagecount = 0
    
    var titleString: String  = ""
    
    
    
    private let  footView =  LoadingFooterView(reuseIdentifier: LoadingFooterView.reuseIdentifier)
    
   override func viewDidLoad() {
       
       super.viewDidLoad()
       view.backgroundColor = ThemeManager.shared.viewBackgroundColor
       
//       if requestType == 64 {
//           self.title =  "热门短剧"
//       }else if requestType == 65 {
//           self.title =  "热门解说"
//       }
       self.title = titleString
       
       setupTableView()
       
       self.page = self.page + 1
       loadData()
   }
   
   private func setupTableView() {
       tableView.dataSource = self
       tableView.delegate = self
       view.addSubview(tableView)
       tableView.translatesAutoresizingMaskIntoConstraints = false
       NSLayoutConstraint.activate([
           tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
           tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
           tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
           tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
       ])
       
     tableView.register(CustomCell.self, forCellReuseIdentifier: "cell")
     //tableView.register(LoadingFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
//     tableView.tableFooterView = UIView()
       tableView.tableFooterView = footView
       footView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70)
       footView.configure(hasMoreData: true)
       
       
   }
     
    func loadData() {
        guard !isLoading else { return }
        self.isLoading = true
        
        requestMoreduanjuorJiesuo()
         
    }
    
    
    
    func requestMoreduanjuorJiesuo( ) {
        print("searchRequest \( page)")
         
        
        let requestComplete2: (HTTPURLResponse?, Result<String, AFError>) -> Void = { response, result in
 
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
                            print("Load more Code: \(response_config.code)  \(response_config.page) - \(response_config.pagecount) -  \(response_config.total)")
                            
                            if(Int(response_config.code) == 1){
                                self.page = self.page + 1
                                self.pagecount = response_config.pagecount
                                self.total = response_config.total
                                self.limit = response_config.limit
                                 
                                
                                //self.movies = response_config.data.videolist
                                
//                                response_config.data.videolist.forEach { VideoCategoryItem in
//  //                                  self.movies?.append(VideoCategoryItem.categoryName)
//                                   // self.videoCategorys.append(VideoCategoryItem)
//                                    VideoCategoryItem.videoListChild.forEach { Videoitem in
//                                        self.movies.append(Videoitem)
//                                    }
//                                }
                                 
                                
                                response_config.data.forEach { video in
                                    self.searchList?.append(video)
                                }
                                
                                DispatchQueue.main.async {
                                    self.hasMoreData = self.total > self.page * self.limit
                                    self.isLoading = false
                                    self.footView.configure(hasMoreData: self.hasMoreData)
                                    self.tableView.reloadData()
                                    
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
                
        AF.request("\(ApplicationS.baseURL)/player/jieshuo?type=\(self.requestType)&page=\(self.page)", method: .get,headers: ApplicationS.addCustomHeaders())
            .validate(statusCode: 200..<300)
            .responseString(completionHandler: { response in
                requestComplete2(response.response, response.result)
                     
            })
    }
    
   
   // 加载书籍数据
   private func loadBooks() {
       // 模拟网络请求加载数据
       self.tableView.reloadData()
   }
   
   // MARK: - UITableViewDataSource
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return searchList?.count ?? 0
   }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
       if let s = searchList{
           cell.configure(with: s[indexPath.row])
       }
        
       
       return cell
   }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return   isLoading ?  70 : 0
//      }
   
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//          let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer") as! LoadingFooterView
//          footer.configure(hasMoreData: hasMoreData)
//          return footer
//      }
      
      func scrollViewDidScroll(_ scrollView: UIScrollView) {
          let offsetY = scrollView.contentOffset.y
          let contentHeight = scrollView.contentSize.height
          let height = scrollView.frame.size.height
          
          if offsetY > contentHeight - height {
              if hasMoreData {
                  loadData()
              }
              
          }
      }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = searchList?[indexPath.item]
        let  controller = MovieDetailViewController()
        controller.movieDetail = movie
//        controller.modalPresentationStyle = .fullScreen
        self.show(controller, sender: self)
        
    }
     
}

 
