//
//  NaviSearchViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/23.
//

import Foundation

//NaviSearchViewController.swift
import UIKit

class NaviSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate {
    
    private let searchTextField = UITextField()
    private let recommendedKeywords = [
        "我和我的朋友们", "时光正好", "无法抗拒的谎言", "特别行动", "我的阿勒泰",
        "城中之城", "沙丘2", "扫黑决不放弃", "功夫熊猫4普通话版", "九龙城寨之围城粤语版",
        "朝云暮雨", "前途海量", "我们一起摇太阳", "反贪风暴5最终章粤语", "三叉戟",
        "维和防暴队", "未路狂花钱", "热辣滚烫", "周处除三害", "爸爸当家第3季",
        "城市捉迷藏", "熊猫一家人", "萌探2024", "新说唱2024", "乘风2024",
        "歌手2024", "哈哈哈哈哈第4季", "大侦探第8季", "王牌对王牌第8季", "花儿与少年丝路季",
        "再见爱人第3季", "你好种地少年", "100万个约定之宁安如梦", "家务优等生",
        "奔跑吧生态篇", "青年π计划", "女子推理社", "声生不息宝岛季", "名侦探学院第6季",
        "快乐再出发第2季", "乐队的海边", "再见爱人第2季", "大湾仔的夜第2季"
    ]
    private let searchHistory = [
        "爸爸当家第3季", "qq下载安装", "去有风的地方"
    ]
    
    private let tableView = UITableView()
    private let recommendedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ThemeManager.shared.viewBackgroundColor
        setupSearchTextField()
        setupRecommendedCollectionView()
        setupTableView()
    }
    
    private func setupSearchTextField() {
        searchTextField.placeholder = "请输入关键字"
        searchTextField.borderStyle = .roundedRect
        searchTextField.delegate = self
        view.addSubview(searchTextField)
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupRecommendedCollectionView() {
        recommendedCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        recommendedCollectionView.dataSource = self
        recommendedCollectionView.delegate = self
        
        view.addSubview(recommendedCollectionView)
        
        recommendedCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recommendedCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            recommendedCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recommendedCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recommendedCollectionView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: recommendedCollectionView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedKeywords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .lightGray
        let label = UILabel()
        label.text = recommendedKeywords[indexPath.item]
        label.numberOfLines = 0
        label.textAlignment = .center
        label.frame = cell.contentView.bounds.insetBy(dx: 8, dy: 8)
        cell.contentView.addSubview(label)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = recommendedKeywords[indexPath.item]
        let width = text.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]).width + 32
        return CGSize(width: width, height: 40)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = searchHistory[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected search history item: \(searchHistory[indexPath.row])")
    }
}

//extension NaviSearchViewController: UICollectionViewDelegateFlowLayout {
//   
//}
//
//extension NaviSearchViewController: UITableViewDataSource {
//    
//}
//
//extension NaviSearchViewController: UITableViewDelegate {
//    
//}
