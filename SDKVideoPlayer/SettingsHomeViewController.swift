//
//  SettingsHomeViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/15.
//

import Foundation

import UIKit
 

class HistoryTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let collectionView: UICollectionView

    var vc:UIViewController?
    let historyLabel = UILabel()
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .clear
        setupCollectionView()
        setupHistoryLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupHistoryLabel() {
        if let ls =  LocalStore.getFromWatchedHistory(), ls.count > 0 {
            historyLabel.text = NSLocalizedString("ReceentBroswerRecode", comment: "")
        }else{
            historyLabel.text = ""
        }
         historyLabel.font = UIFont.boldSystemFont(ofSize: 16)
         historyLabel.translatesAutoresizingMaskIntoConstraints = false
         contentView.addSubview(historyLabel)

         NSLayoutConstraint.activate([
             historyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
             historyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
         ])
     }

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
//        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCell")
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 40),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        collectionView.reloadData()
    }
    
    
    func reloadData() {
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (LocalStore.getFromWatchedHistory()?.count ?? 0) > 10{
            return 10
        }
        return LocalStore.getFromWatchedHistory()?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as! MovieCollectionViewCell

        if let ls =  LocalStore.getFromWatchedHistory() {
            cell.configure(with: ls[indexPath.item])
        }
        
        // 配置集合视图单元格，添加图像和标签等
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 180) // 设置单元格尺寸
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let ls =  LocalStore.getFromWatchedHistory() {
            let data =  ls[indexPath.item]
            let  controller = SQBMovieDetailViewController()
            controller.movieDetail = data
    //        controller.modalPresentationStyle = .fullScreen
            self.vc?.show(controller, sender: self)
//            cell.configure(with: ls[indexPath.item])
            
        }
        
    }
}


import UIKit

class CustomTableViewCell: UITableViewCell {
    
    let customTextLabel = UILabel()
    let customDetailTextLabel = UILabel()
    let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // 配置 customTextLabel
        customTextLabel.translatesAutoresizingMaskIntoConstraints = false
        customTextLabel.font = UIFont.systemFont(ofSize: 16)
//        customTextLabel.textColor = .black
        customTextLabel.textColor = ThemeManager.shared.fontColor
        contentView.addSubview(customTextLabel)
        
        // 配置 customDetailTextLabel
        customDetailTextLabel.translatesAutoresizingMaskIntoConstraints = false
        customDetailTextLabel.font = UIFont.systemFont(ofSize: 14)
//        customDetailTextLabel.textColor = .gray
        customDetailTextLabel.textColor = ThemeManager.shared.fontColor
        contentView.addSubview(customDetailTextLabel)
        
        // 配置 arrowImageView
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.tintColor = .gray
        contentView.addSubview(arrowImageView)
         
        // 设置约束
        NSLayoutConstraint.activate([
            customTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customTextLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            customDetailTextLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            customDetailTextLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        
       // 设置圆角
       contentView.layer.cornerRadius = 10
       contentView.layer.masksToBounds = true
    }
    
    func configure(text: String, detailText: String?) {
        customTextLabel.text = text
        customDetailTextLabel.text = detailText
    }
    
    enum CornerType {
          case none, top, bottom, all
      }
    
       func setCornerType(_ type: CornerType) {
           switch type {
           case .none:
               contentView.layer.maskedCorners = []
           case .top:
               contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
           case .bottom:
               contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
           case .all:
               contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
           }
       }
    
}

class SettingsHomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()

    private let themeSwitch: UISwitch = {
           let themeSwitch = UISwitch()
           themeSwitch.translatesAutoresizingMaskIntoConstraints = false
           themeSwitch.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
           return themeSwitch
       }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(fromHex: "#f6f6f6")
        
        setupTableView()
        
        
        // 注册通知观察者
        NotificationCenter.default.addObserver(self, selector: #selector(historyItemsUpdated), name: .historyItemsUpdated, object: nil)
        
        
        configureNavigationBar()
        
//        self.title = NSLocalizedString("Settings", comment: "")
        
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
  

    deinit {
          // 移除通知观察者
          NotificationCenter.default.removeObserver(self, name: .historyItemsUpdated, object: nil)
      }
    
    @objc func historyItemsUpdated() {
           // 刷新表格视图 
        tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? HistoryTableViewCell {
                cell.reloadData()
            }
        }
       

    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryTableViewCell")
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomTableViewCell")
             
//        tableView.separatorStyle = .none // 隐藏每行cell的横线
        tableView.frame = view.bounds
        view.addSubview(tableView)
        
//        tableView.backgroundColor = UIColor(fromHex: "#f6f6f6")
        view.backgroundColor = ThemeManager.shared.viewBackgroundColor
        
        let headView = UIView()
        headView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 110)
        
        let customTextLabel = UILabel()
        headView.addSubview(customTextLabel)
        customTextLabel.text = NSLocalizedString("welcometo", comment: "") +  NSLocalizedString("appName", comment: "") 
        
        customTextLabel.translatesAutoresizingMaskIntoConstraints = false
        customTextLabel.font = UIFont.boldSystemFont(ofSize: 22)
        customTextLabel.textColor =  ThemeManager.shared.fontColor
        
        
        let startButton = UIButton(type: .system)
        startButton.setTitle(NSLocalizedString("StarUS", comment: "") , for: UIControl.State.normal)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        headView.addSubview(startButton)
        
        startButton.clipsToBounds = true
        startButton.layer.cornerRadius = 22
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = UIColor.MainColor().cgColor
        
        startButton.addTarget(self, action: #selector(ButtonhdplayurlTapped(_:)), for: .touchUpInside)
        
        
        // Add the switch to the view
//        headView.addSubview(themeSwitch)
//              
//          // Setup Auto Layout constraints for the switch
//          NSLayoutConstraint.activate([
//              themeSwitch.trailingAnchor.constraint(equalTo: headView.trailingAnchor,constant: -10),
//              themeSwitch.centerYAnchor.constraint(equalTo: headView.centerYAnchor)
//          ])
//        // Add target action for the switch
//           themeSwitch.addTarget(self, action: #selector(themeSwitchChanged(_:)), for: .valueChanged)
      
        
        // 设置约束
        NSLayoutConstraint.activate([
            customTextLabel.leadingAnchor.constraint(equalTo: headView.leadingAnchor, constant: 16),
            customTextLabel.topAnchor.constraint(equalTo: headView.topAnchor,constant: 16),
            customTextLabel.trailingAnchor.constraint(equalTo: headView.trailingAnchor),
            customTextLabel.heightAnchor.constraint(equalToConstant: 44),
            
            
            startButton.leadingAnchor.constraint(equalTo: headView.leadingAnchor, constant: 16),
            startButton.topAnchor.constraint(equalTo: customTextLabel.bottomAnchor,constant: 5),
            startButton.widthAnchor.constraint(equalToConstant:88),
            startButton.heightAnchor.constraint(equalToConstant: 44),
            
            
        ])
         
        
        tableView.tableHeaderView = headView
    }
    @objc private func themeSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkMode")
        NotificationCenter.default.post(name: .themeChanged, object: nil)
    }
     
    @objc private func ButtonhdplayurlTapped(_ button:UIButton){
        UIApplication.shared.open( URL(string: "https://apps.apple.com/app/%E6%90%9C%E7%90%83%E5%90%A7/id6566178187")!,options: [:]) { complate in
            
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 // 假设有7行
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
            // 配置历史记录单元格
            cell.vc = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
             
             switch indexPath.row {
                 case 1:
                 
                 
                     cell.configure(text: NSLocalizedString("mybrowserecord", comment: ""), detailText: nil)
                 case 2:
                     cell.configure(text:  NSLocalizedString("Service_agreement", comment: ""), detailText: nil)
                 case 3:
                     cell.configure(text:  NSLocalizedString("Copyright_statement", comment: ""), detailText: nil)
                 case 4:
                     cell.configure(text:  NSLocalizedString("Privacy_policy", comment: ""), detailText: nil)
                 case 5:
                     cell.configure(text:  NSLocalizedString("App_Version", comment: ""), detailText: "1.0.0")
                 default:
                     cell.configure(text: "", detailText: nil)
             }
             
//            if indexPath.row != 0 && indexPath.row != 5 {
//                cell.setCornerType(.all)
//            } else if indexPath.row == 1 {
//                cell.setCornerType(.top)
//            } else if indexPath.row == 5 {
//                cell.setCornerType(.bottom)
//            } else {
//                cell.setCornerType(.none)
//            }
            
             return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if indexPath.row == 0 {
            if let ls =  LocalStore.getFromWatchedHistory(), ls.count > 0 {
                return  240
            }else{
                return 0
            }
        }
                
                return 44
    }
     
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
            case 1:
                print("")
             let brVc = BrowseViewController()
                self.show(brVc, sender: self)
//                cell.configure(text: "我的浏览记录", detailText: nil)
            
            case 2:
                print("")
                let controller = SwiftWebVC(urlString: "\(ApplicationS.baseURL)/player/serverdeail")
                self.show(controller, sender: self)
//                cell.configure(text: "服务协议", detailText: nil)
            case 3:
                print("")
                let controller = SwiftWebVC(urlString: "\(ApplicationS.baseURL)/player/versiondeail")
                self.show(controller, sender: self)
//                cell.configure(text: "版权说明", detailText: nil)
            case 4:
                print("")
                let controller = SwiftWebVC(urlString: "\(ApplicationS.baseURL)/player/prvacrydeail")
                self.show(controller, sender: self)
//                cell.configure(text: "隐私政策", detailText: nil)
            case 5:
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
                showSearchErrorAlert(on: self, error: appVersion,title: NSLocalizedString("App_Version", comment: ""))

            default:
                print("")
//                cell.configure(text: "", detailText: nil)
        }
    }
     
    
    
}
