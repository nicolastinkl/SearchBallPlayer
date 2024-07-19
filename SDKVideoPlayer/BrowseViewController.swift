//
//  BrowseViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/17.
//

import Foundation
import UIKit

//BrowseViewController
class BrowseViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    public var requestType : Int = 0
    
   private let tableView = UITableView()
     
   private let loadMoreOffset = 20 // 定义触发加载更多的偏移量
    
    var searchList:[Video]? = [Video]()
     
    
    private let  footView =  LoadingFooterView(reuseIdentifier: LoadingFooterView.reuseIdentifier)
    
   override func viewDidLoad() {
       
       super.viewDidLoad()
       view.backgroundColor = ThemeManager.shared.viewBackgroundColor
       self.title = "我的浏览记录"
       //searchList
       
       setupTableView()
        
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
        if let ls =  LocalStore.getFromWatchedHistory() {
            self.searchList = ls
            
            DispatchQueue.main.async {
                self.footView.configure(hasMoreData:false)
                self.tableView.reloadData()
                
            }
            
        }else{
            DispatchQueue.main.async {
                self.footView.configure(hasMoreData:false)
                self.tableView.reloadData()
                
            }
        }
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = searchList?[indexPath.item]
        let  controller = MovieDetailViewController()
        controller.movieDetail = movie
//        controller.modalPresentationStyle = .fullScreen
        self.show(controller, sender: self)
        
    }
     
}
