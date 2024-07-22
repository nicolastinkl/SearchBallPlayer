//
//  SearcViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/15.
//

import Foundation
import UIKit

import UIKit
import SafariServices
import Alamofire
import SDWebImage
import SwiftIcons


class SearcViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
   
 
    
   private let tableView = UITableView()
     
   private let loadMoreOffset = 20 // 定义触发加载更多的偏移量

    
    var searchText : String = ""
    
    var searchList:[Video]?
    
    var isLoading = false
    var hasMoreData = true
    
    var total = 0
    var page = 0
    var limit = 0
    var pagecount = 0
    
    
    private let  footView =  LoadingFooterView(reuseIdentifier: LoadingFooterView.reuseIdentifier)
    
   override func viewDidLoad() {
       
       super.viewDidLoad()
       view.backgroundColor =  ThemeManager.shared.viewBackgroundColor
       self.title =  "'\(searchText)' 搜索结果"
       
       setupTableView()
       
       //loadData()
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
        
        searchRequest(searchText: searchText)
         
    }
    
    
    
    func searchRequest(searchText: String) {
        print("searchRequest \( page)")
         
        
        let requestComplete1: (HTTPURLResponse?, Result<String, AFError>) -> Void = { response, result in
 
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
        
        var searchTextEncoding = ""
        if let encodedQuery = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            searchTextEncoding = encodedQuery
        }
         
//        print("\(ApplicationS.baseURL)/player/search?keyword=\(searchTextEncoding)&page=\(self.page)") 
        AF.request("\(ApplicationS.baseURL)/player/search?keyword=\(searchTextEncoding)&page=\(self.page)", method: .get,headers: ApplicationS.addCustomHeaders())
            .validate(statusCode: 200..<300)
            .responseString(completionHandler: { response in
                requestComplete1(response.response, response.result)
                     
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


class CustomCell: UITableViewCell {
    let titleLabel = UILabel()
//    let itemImageView = UIImageView()
    
    
    private var tagsStackView = UIView()
    
    
    private let desLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = ThemeManager.shared.fontColor2
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let itemImageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(itemImageView)
        contentView.addSubview(desLabel)
        
//        itemImageView.frame = CGRect(x: 15, y: 15, width: 70, height: 120)
//        titleLabel.frame = CGRect(x: 95, y: 15, width: contentView.frame.width - 50, height: 40)
//        desLabel.frame = CGRect(x: 95, y: 15 + 20, width: contentView.frame.width - 50, height: 80)
        
        
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            itemImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            itemImageView.widthAnchor.constraint(equalToConstant: 70),
            itemImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        desLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            desLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 20),
            desLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            desLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            desLabel.heightAnchor.constraint(equalToConstant: 60) // 如果高度是固定的，可以设置为一个常数
        ])
         
        setupTagsStackView()
        
    }
    
    private func setupTagsStackView() {
         
        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagsStackView)
        // tagsStackView.frame =  CGRect(x: 95, y: 15 + 40 + 50, width: contentView.frame.width , height: 30)
        
        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagsStackView.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 20),
            tagsStackView.topAnchor.constraint(equalTo: desLabel.bottomAnchor, constant: 5),
            tagsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            tagsStackView.heightAnchor.constraint(equalToConstant: 30) // 如果高度是固定的，可以设置为一个常数
        ])
         
        
        
        
        
        for index in 10...13 {
            let tagLabel = UILabel()
            
            tagLabel.backgroundColor = UIColor.MainColor()  // 设置标签背景颜色
            tagLabel.textColor = .white // 设置标签文字颜色
            tagLabel.font = UIFont.systemFont(ofSize: 12)
//            tagLabel.text = tagName
            tagLabel.tag = index
            tagLabel.textAlignment = .center
            tagLabel.layer.cornerRadius = 6 // 设置标签圆角
            tagLabel.clipsToBounds = true
            
            tagsStackView.addSubview(tagLabel)
        }
//        tagsStackView.backgroundColor = UIColor.MainColor()
//         tagsStackView.translatesAutoresizingMaskIntoConstraints = false
//         NSLayoutConstraint.activate([
//             tagsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8),
//             tagsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 95),
//             tagsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
//         ])
     }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: Video?) {
        titleLabel.text = data?.vodName
        // Here you can load the image from a URL
        desLabel.text = data?.vodContent
        itemImageView.sd_setImage(with: URL.init(string: data?.vodPic ?? ""), placeholderImage: UIImage(named: "placeholder-image"), context: nil)
        
        var leftC  :CGFloat = 0
        tagsStackView.subviews.forEach { label in
            if let la = label as? UILabel {
                
                
                if (data?.vodLang.count ?? 0) > 1 &&  la.tag == 10 {
                    la.text = data?.vodLang
                    la.frame = CGRect(x: 0, y: 0, width: (data?.vodLang.count ?? 0) * 15, height: 30)
                    leftC  += la.frame.width  + 5
                }
                
                if (data?.typeName.count ?? 0) > 1 &&  la.tag == 11 {
                    la.text = data?.typeName
                    la.frame = CGRect(x:  Int(leftC), y: 0, width: (data?.typeName.count ?? 0) * 15, height: 30)
                    leftC  += la.frame.width  + 5
                }
                if (data?.vodRemarks.count ?? 0) > 1 &&  la.tag == 12 {
                    la.text = data?.vodRemarks
                    
                    la.frame = CGRect(x: Int(leftC), y: 0, width: (data?.vodRemarks.count ?? 0) * 15, height: 30)
                    leftC  += la.frame.width  + 5
                }
                if (data?.vodYear.count ?? 0) > 1 &&  la.tag == 13 {
                    la.text = data?.vodYear
                    la.frame = CGRect(x: Int(leftC), y: 0, width: (data?.vodYear.count ?? 0) * 15, height: 30)
                    
                }
                
                
            }
            
            
        }
        
//        let label1 = addTags(tagName: data?.vodLang,preView: nil)
//        let label2 = addTags(tagName: data?.vodTag,preView: label1)
//        let label3 = addTags(tagName: data?.vodRemarks,preView: label2)
//        let label4 = addTags(tagName: data?.vodYear,preView: label3)

    }
    
//    func addTags(tagName : String?, preView:UILabel?) -> UILabel?{
//        if let tagName = tagName {
//           
//            
//            
//            return tagLabel
//        }
//        return nil
//    }
}

class LoadingFooterView: UITableViewHeaderFooterView {
    
    let label = UILabel()
    static let reuseIdentifier = "LoadingFooterView"
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(activityIndicator)
        
        activityIndicator.isHidden = true
        label.isHidden = true
        
        activityIndicator.hidesWhenStopped = true
        label.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
            activityIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            activityIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            activityIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            activityIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            
         ])
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(hasMoreData: Bool) {

        
        label.textAlignment = .center
        //activityIndicator.frame = contentView.bounds
        if hasMoreData {
            label.text = "正在加载更多..."
            //label.frame = CGRect(x: 0, y: 40, width: contentView.frame.width, height: 30)
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            label.isHidden = false
        } else {
           // label.frame = contentView.bounds
            label.text = "没有更多数据了"
            label.isHidden = false
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
}


