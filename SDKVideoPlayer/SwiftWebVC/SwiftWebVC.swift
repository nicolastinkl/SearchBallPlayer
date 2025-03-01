//
//  SwiftWebVC.swift
//
//  Created by Myles Ringle on 24/06/2015.
//  Transcribed from code used in SVWebViewController.
//  Copyright (c) 2015 Myles Ringle & Sam Vermette. All rights reserved.
//

import WebKit
//import KSPlayer
import SDWebImage
import Toast
import Lottie

public protocol SwiftWebVCDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading(success: Bool)
}

private struct AssociatedKeys {
    static var videoPopupView = "videoPopupView"
    static var overlayView = "overlayView"
}


public enum YouTubePlayerState: String {
    case Unstarted = "-1"
    case Ended = "0"
    case Playing = "1"
    case Paused = "2"
    case Buffering = "3"
    case Queued = "4"
}

public enum YouTubePlayerEvents: String {
    case YouTubeIframeAPIReady = "onYouTubeIframeAPIReady"
    case Ready = "onReady"
    case StateChange = "onStateChange"
    case PlaybackQualityChange = "onPlaybackQualityChange"
}

public enum YouTubePlaybackQuality: String {
    case Small = "small"
    case Medium = "medium"
    case Large = "large"
    case HD720 = "hd720"
    case HD1080 = "hd1080"
    case HighResolution = "highres"
}



private extension URL {
    func queryStringComponents() -> [String: AnyObject] {

        var dict = [String: AnyObject]()

        // Check for query string
        if let query = self.query {

            // Loop through pairings (separated by &)
            for pair in query.components(separatedBy: "&") {

                // Pull key, val from from pair parts (separated by =) and set dict[key] = value
                let components = pair.components(separatedBy: "=")
                dict[components[0]] = components[1] as AnyObject?
            }

        }

        return dict
    }
}



public class SwiftWebVC: UIViewController{
    
    private var playVideourl:URL?
    
   
     private var videoPopupView: VideoPopupView? /* {
         get {
             return objc_getAssociatedObject(self, AssociatedKeys.videoPopupView) as? VideoPopupView
         }
         set {
             objc_setAssociatedObject(self, AssociatedKeys.videoPopupView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
         }
     }*/
     
     private var overlayView: UIView? /*{
         get {
             return objc_getAssociatedObject(self, AssociatedKeys.overlayView) as? UIView
         }
         set {
             objc_setAssociatedObject(self, AssociatedKeys.overlayView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
         }
     }*/
    
    public weak var delegate: SwiftWebVCDelegate?
    var storedStatusColor: UIBarStyle?
    var buttonColor: UIColor? = nil
    var titleColor: UIColor? = nil
    var closing: Bool! = false
    
    
    @MainActor
    var m3u8playurl: URL?
    
    lazy var backBarButtonItem: UIBarButtonItem =  {
        var tempBackBarButtonItem = UIBarButtonItem(image: SwiftWebVC.bundledImage(named: "SwiftWebVCBack"),
                                                    style: UIBarButtonItem.Style.plain,
                                                    target: self,
                                                    action: #selector(SwiftWebVC.goBackTapped(_:)))
        tempBackBarButtonItem.width = 18.0
        tempBackBarButtonItem.tintColor = self.buttonColor
        return tempBackBarButtonItem
    }()
    
    lazy var forwardBarButtonItem: UIBarButtonItem =  {
        var tempForwardBarButtonItem = UIBarButtonItem(image: SwiftWebVC.bundledImage(named: "SwiftWebVCNext"),
                                                       style: UIBarButtonItem.Style.plain,
                                                       target: self,
                                                       action: #selector(SwiftWebVC.goForwardTapped(_:)))
        tempForwardBarButtonItem.width = 18.0
        tempForwardBarButtonItem.tintColor = self.buttonColor
        return tempForwardBarButtonItem
    }()
    
    lazy var refreshBarButtonItem: UIBarButtonItem = {
        var tempRefreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh,
                                                       target: self,
                                                       action: #selector(SwiftWebVC.reloadTapped(_:)))
        tempRefreshBarButtonItem.tintColor = self.buttonColor
        return tempRefreshBarButtonItem
    }()
    
    lazy var stopBarButtonItem: UIBarButtonItem = {
        var tempStopBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop,
                                                    target: self,
                                                    action: #selector(SwiftWebVC.stopTapped(_:)))
        tempStopBarButtonItem.tintColor = self.buttonColor
        return tempStopBarButtonItem
    }()
    
    lazy var actionBarButtonItem: UIBarButtonItem = {
        var tempActionBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action,
                                                      target: self,
                                                      action: #selector(SwiftWebVC.actionButtonTapped(_:)))
        tempActionBarButtonItem.tintColor = self.buttonColor
        return tempActionBarButtonItem
    }()
    
    lazy var faviatorBarButtonItem: UIBarButtonItem = {
//        var tempActionBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add,
//                                                      target: self,
//                                                      action: #selector(SwiftWebVC.actionfaviatorButtonTapped(_:)))
//        tempActionBarButtonItem.tintColor = self.buttonColor
        
        let   animationView = LottieAnimationView.init(name: "87ef38eb")
          
//          animationView.frame = view.bounds
          
          // 3. Set animation content mode
          
          animationView.contentMode = .scaleAspectFit
          
          // 4. Set animation loop mode
          
        animationView.loopMode = .loop
          
          // 5. Adjust animation speed
          
          animationView.animationSpeed = 1
          
//          view.addSubview(animationView)
//
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        // 6. Play animation
          
        
        var tempActionBarButtonItem = UIBarButtonItem(customView: animationView)
        animationView.play()
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: 44),
            animationView.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SwiftWebVC.actionfaviatorButtonTapped(_:)))
        animationView.addGestureRecognizer(tap)
        
        return tempActionBarButtonItem
    }()
    
    lazy var searchbarButtonItem: UIBarButtonItem = {
        //
        let   animationView = LottieAnimationView.init(name: "bb276970")
          
//          animationView.frame = view.bounds
          
          // 3. Set animation content mode
          
          animationView.contentMode = .scaleAspectFit
          
          // 4. Set animation loop mode
          
        animationView.loopMode = .loop
          
          // 5. Adjust animation speed
          
          animationView.animationSpeed = 1
          
//          view.addSubview(animationView)
//          
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        // 6. Play animation
          
        
        var tempActionBarButtonItem = UIBarButtonItem(customView: animationView)
        animationView.play()
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: 44),
            animationView.heightAnchor.constraint(equalToConstant: 44),
        ])
        
//        var tempActionBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play,
//                                                      target: self,
//                                                      action: #selector(SwiftWebVC.searchButtonTapped(_:)))
        tempActionBarButtonItem.tintColor = self.buttonColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SwiftWebVC.searchButtonTapped(_:)))
        animationView.addGestureRecognizer(tap)
        
        return tempActionBarButtonItem
    }()
    
//    
//    lazy var webView: WKWebView = {
//        
//        
//        let webConfiguration = WKWebViewConfiguration()
////        webConfiguration.setURLSchemeHandler(self, forURLScheme: "https")
//        
//        var tempWebView = WKWebView(frame: UIScreen.main.bounds,configuration: webConfiguration)
//        tempWebView.uiDelegate = self
//        tempWebView.navigationDelegate = self
//        tempWebView.backgroundColor =  ThemeManager.shared.viewBackgroundColor
//        
//        
//        return tempWebView;
//    }()
    
    var webView: WKWebView!
    var request: URLRequest!
    
    var navBarTitle: UILabel!
    
    var sharingEnabled = false
    
    var proxyHttps = false
    
    var iconFaviICO:String = ""
    ////////////////////////////////////////////////
    
    deinit {
        webView.stopLoading()
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        webView.uiDelegate = nil;
        webView.navigationDelegate = nil;
    }
    
    public convenience init(urlString: String, sharingEnabled: Bool = false) {
        var urlString = urlString
        if !urlString.hasPrefix("https://") && !urlString.hasPrefix("http://") {
            urlString = "https://"+urlString
        }
        if let url = URL(string: urlString){
            self.init(pageURL: url, sharingEnabled: sharingEnabled)
        }else{
            self.init(pageURL: URL(string: "About:blank")!, sharingEnabled: sharingEnabled)
        }
        
    }
    
    public convenience init(pageURL: URL, sharingEnabled: Bool = false) {
        self.init(aRequest: URLRequest(url: pageURL), sharingEnabled: sharingEnabled)
    }
    
    public convenience init(aRequest: URLRequest, sharingEnabled: Bool = false) {
        self.init()
        self.sharingEnabled = sharingEnabled
        self.request = aRequest
    }
    
    public typealias YouTubePlayerParameters = [String: AnyObject]
    /** The readiness of the player */
    fileprivate(set) open var ready = false

    /** The current state of the video player */
    fileprivate(set) open var playerState = YouTubePlayerState.Unstarted

    /** The current playback quality of the video player */
    fileprivate(set) open var playbackQuality = YouTubePlaybackQuality.Small

    /** Used to configure the player */
    open var playerVars = YouTubePlayerParameters()
    
    fileprivate func playerParameters() -> YouTubePlayerParameters {

        return [
            "height": "100%" as AnyObject,
            "width": "100%" as AnyObject,
            "events": playerCallbacks() as AnyObject,
            "playerVars": playerVars as AnyObject
        ]
    }
    public func videoIDFromYouTubeURL(_ videoURL: URL) -> String? {
        return videoURL.queryStringComponents()["v"] as! String?
    }
    

    fileprivate func playerCallbacks() -> YouTubePlayerParameters {
        return [
            "onReady": "onReady" as AnyObject,
            "onStateChange": "onStateChange" as AnyObject,
            "onPlaybackQualityChange": "onPlaybackQualityChange" as AnyObject,
            "onError": "onPlayerError" as AnyObject
        ]
    }
    func loadRequest(_ request: URLRequest) {
        if let url =  request.url {
            
            if let videoID = videoIDFromYouTubeURL(url) {
                loadVideoID(videoID)
            }else{
                webView.load(request)
            }
            
        } 
        
    }
    
    open func loadVideoID(_ videoID: String) {
        if let rawHTMLString = htmlStringWithFilePath(playerHTMLPath()){
            // Replace %@ in rawHTMLString with jsonParameters string
            let htmlString = rawHTMLString.replacingOccurrences(of: "%@", with: videoID, options: [], range: nil)
            
            // Load HTML in web view
            webView.loadHTMLString(htmlString, baseURL: URL(string: "about:blank"))
        }
    }
 
    
    fileprivate func loadWebViewWithParameters(_ parameters: YouTubePlayerParameters) {

        // Get HTML from player file in bundle
        let rawHTMLString = htmlStringWithFilePath(playerHTMLPath())!

        // Get JSON serialized parameters string
        let jsonParameters = serializedJSON(parameters as AnyObject)!

        // Replace %@ in rawHTMLString with jsonParameters string
        let htmlString = rawHTMLString.replacingOccurrences(of: "%@", with: jsonParameters, options: [], range: nil)

        // Load HTML in web view
        webView.loadHTMLString(htmlString, baseURL: URL(string: "about:blank"))
    }
    
    fileprivate func playerHTMLPath() -> String {
        return Bundle(for: self.classForCoder).path(forResource: "YTPlayer", ofType: "html")!
    }

    fileprivate func htmlStringWithFilePath(_ path: String) -> String? {

        // Error optional for error handling
        var error: NSError?

        // Get HTML string from path
        let htmlString: NSString?
        do {
            htmlString = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
        } catch let error1 as NSError {
            error = error1
            htmlString = nil
        }

        // Check for error
        if let _ = error {
            print("Lookup error: no HTML file found for path, \(path)")
        }

        return htmlString! as String
    }
 

    fileprivate func serializedJSON(_ object: AnyObject) -> String? {

        // Empty error
        var error: NSError?

        // Serialize json into NSData
        let jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let error1 as NSError {
            error = error1
            jsonData = nil
        }

        // Check for error and return nil
        if let _ = error {
            print("Error parsing JSON")
            return nil
        }

        // Success, return JSON string
        return NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue) as? String
    }
    
    
    fileprivate func evaluatePlayerCommand(_ command: String) {
//        let fullCommand = "player." + command + ";"
        //webView.stringByEvaluatingJavaScript(from: fullCommand)
        
        webView.evaluateJavaScript(command, completionHandler: {(response, error) in
            print("\(String(describing: response))   \(String(describing: error))")
        })
        
    }
    
    ////////////////////////////////////////////////
    // View Lifecycle
    
//    override public func loadView() {
//        view = webView
//        loadRequest(request)
//    }
    
  
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor =  ThemeManager.shared.viewBackgroundColor
                
        let webConfiguration = WKWebViewConfiguration()
        
        // Create a CustomURLSchemeHandler and set it
        let schemeHandler = CustomURLSchemeHandler()
        schemeHandler.ViewController = self
        if proxyHttps{
            
        }else{
            webConfiguration.setURLSchemeHandler(schemeHandler, forURLScheme: "https")
        }
        
        
//        webConfiguration.setURLSchemeHandler(schemeHandler, forURLScheme:  "customscheme")
        // Create a WKUserContentController
        webView = WKWebView(frame: UIScreen.main.bounds,configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        webView.backgroundColor =  ThemeManager.shared.viewBackgroundColor
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
       
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
        ])
        loadRequest(request)
        configureNavigationBar()
        //SwiftLoader.show(view: self.view,title: NSLocalizedString("Loading", comment: ""), animated: true)
        
         
        
    }
    
    
  private func configureNavigationBar() {
      if #available(iOS 13.0, *) {
          // iOS 13 及以上版本使用 UINavigationBarAppearance
          let appearance = UINavigationBarAppearance()
          appearance.configureWithTransparentBackground()
          appearance.backgroundColor = ThemeManager.shared.viewBackgroundColor
          appearance.shadowColor = ThemeManager.shared.viewBackgroundColor

          navigationController?.navigationBar.standardAppearance = appearance
          navigationController?.navigationBar.scrollEdgeAppearance = appearance
      }
  }
    
    
   
    
    override public func viewWillAppear(_ animated: Bool) {
        assert(self.navigationController != nil, "SVWebViewController needs to be contained in a UINavigationController. If you are presenting SVWebViewController modally, use SVModalWebViewController instead.")
        
        updateToolbarItems()
        navBarTitle = UILabel()
        navBarTitle.backgroundColor = UIColor.clear
        if presentingViewController == nil {
            if let titleAttributes = navigationController!.navigationBar.titleTextAttributes {
                navBarTitle.textColor = titleAttributes[.foregroundColor] as? UIColor
            }
        }
        else {
            navBarTitle.textColor = self.titleColor
        }
        navBarTitle.shadowOffset = CGSize(width: 0, height: 1);
        navBarTitle.font = UIFont(name: "HelveticaNeue-Medium", size: 17.0)
        navBarTitle.textAlignment = .center
        navigationItem.titleView = navBarTitle;
        
        super.viewWillAppear(true)
        
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
            self.navigationController?.setToolbarHidden(false, animated: false)
        }
        else if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    ////////////////////////////////////////////////
    // Toolbar
    
    func updateToolbarItems() {
//        return
        backBarButtonItem.isEnabled = webView.canGoBack
        forwardBarButtonItem.isEnabled = webView.canGoForward
        
        let refreshStopBarButtonItem: UIBarButtonItem = webView.isLoading ? stopBarButtonItem : refreshBarButtonItem
        
        self.navigationItem.rightBarButtonItem = refreshStopBarButtonItem
        
        let fixedSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            
            let toolbarWidth: CGFloat = 250.0
            fixedSpace.width = 35.0
            
            // let items: NSArray = sharingEnabled ? [fixedSpace, refreshStopBarButtonItem, fixedSpace, backBarButtonItem, fixedSpace, forwardBarButtonItem, fixedSpace, actionBarButtonItem] : [fixedSpace, refreshStopBarButtonItem, fixedSpace, backBarButtonItem, fixedSpace, forwardBarButtonItem]
            
            let items: NSArray =   [  fixedSpace, backBarButtonItem, fixedSpace, forwardBarButtonItem]
            let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: toolbarWidth, height: 44.0))
            if !closing {
                toolbar.items = items as? [UIBarButtonItem]
                if presentingViewController == nil {
                    toolbar.barTintColor = navigationController!.navigationBar.barTintColor
                }
                else {
                    toolbar.barStyle = navigationController!.navigationBar.barStyle
                }
                toolbar.tintColor = navigationController!.navigationBar.tintColor
            }
            navigationItem.rightBarButtonItems = items.reverseObjectEnumerator().allObjects as? [UIBarButtonItem]
            toolbar.backgroundColor = ThemeManager.shared.viewBackgroundColor
        }
        else {
            // let items: NSArray = sharingEnabled ? [fixedSpace, backBarButtonItem, flexibleSpace, forwardBarButtonItem, flexibleSpace, refreshStopBarButtonItem, flexibleSpace, actionBarButtonItem, fixedSpace] : [fixedSpace, backBarButtonItem, flexibleSpace, forwardBarButtonItem, flexibleSpace, refreshStopBarButtonItem, fixedSpace]
            
            
            let items: NSArray =   [fixedSpace, backBarButtonItem, flexibleSpace, forwardBarButtonItem, flexibleSpace,faviatorBarButtonItem,flexibleSpace,searchbarButtonItem]
           
            
            if let navigationController = navigationController, !closing {
                if presentingViewController == nil {
                    navigationController.toolbar.barTintColor = navigationController.navigationBar.barTintColor
                }
                else {
                    navigationController.toolbar.barStyle = navigationController.navigationBar.barStyle
                }
                navigationController.toolbar.tintColor = navigationController.navigationBar.tintColor
                toolbarItems = items as? [UIBarButtonItem]
                navigationController.toolbar.backgroundColor = ThemeManager.shared.viewBackgroundColor
            }
        }
    }
    
    
    ////////////////////////////////////////////////
    // Target Actions
    
    @objc func goBackTapped(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @objc func goForwardTapped(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @objc func reloadTapped(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    
    @objc func stopTapped(_ sender: UIBarButtonItem) {
        webView.stopLoading()
        updateToolbarItems()
    }
    
    
    // 获取网页图标URL
    func getFaviconURL(webView: WKWebView, completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("var icons = document.querySelectorAll('link[rel=\"icon\"], link[rel=\"shortcut icon\"]'); icons.length > 0 ? icons[0].href : null", completionHandler: { (result, error) in
            if let error = error {
                print("获取图标URL出错: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let iconURL = result as? String {
                print("图标URL: \(iconURL)")
                completion(iconURL)
            } else {
                print("未找到图标URL")
                completion(nil)
            }
        })
    }
    
    @objc func actionfaviatorButtonTapped(_ sender: AnyObject) {
        if let url: URL = ((webView.url != nil) ? webView.url : request.url) {
            webView.evaluateJavaScript("document.title", completionHandler: {(response, error) in
                if let s = response as? String {
                    
                    self.getFaviconURL(webView: self.webView) { (iconURL) in
                       if let iconURL = iconURL {
                           print("图标URL: \(iconURL)")
                           self.presentTextInputAlert(title: s, url: url.absoluteString,iconurl: iconURL)
                           // 下载图标
                          // self.downloadFavicon(faviconURL: iconURL)
                       } else {
                           print("未找到图标URL")
                           self.presentTextInputAlert(title: "未知", url: url.absoluteString,iconurl: "")
                       }
                   }
            
                    
                }else{
                    self.presentTextInputAlert(title: "未知", url: url.absoluteString,iconurl: "")
                }
            })
        }
    }
    
    
    func presentTextInputAlert(title: String, url:String,iconurl:String?) {
           // 创建 UIAlertController 实例
           let alertController = UIAlertController(title: NSLocalizedString("favitorurl", comment: ""), message: "", preferredStyle: .alert)
           
           // 创建第一个文本输入框
           let textField1 = UITextField()
           
           textField1.borderStyle = .roundedRect
           
            alertController.addTextField { (textF) in
                textF.placeholder = NSLocalizedString("PleaseInputTitle", comment: "")
                textF.text = title
           }
            
           
           // 创建第二个文本输入框
           let textField2 = UITextField()
           
           textField2.borderStyle = .roundedRect
           alertController.addTextField { (textF) in
               textF.placeholder = NSLocalizedString("PleaseInputURL", comment: "")
               textF.text = url
           }
            
        if let u = iconurl, u.count > 10 {
            iconFaviICO = u
        }
        /*
         if let u = iconurl, u.count > 10 {
             let iconImageView = SDAnimatedImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                   iconImageView.contentMode = .scaleAspectFit
                     iconImageView.sd_setImage(with: URL(string: u), placeholderImage: UIImage(named: "imageholder1"), context: [:])
                   
                   // 将图标视图添加到 UIAlertController 的视图中
                   alertController.view.addSubview(iconImageView)
                   
                   // 设置图标视图的位置
                   iconImageView.center = alertController.view.center
         }
         */
       
           
           // 创建取消按钮
           let cancelAction = UIAlertAction(title:NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
               // 取消操作
           }
           alertController.addAction(cancelAction)
           
           // 创建保存按钮
           let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { (action) in
               if let text1 = alertController.textFields?.first?.text,
                  let text2 = alertController.textFields?.last?.text {
                   // 这里处理保存逻辑
                   //print("文本1: \(text1), 文本2: \(text2)")
                   if text1.count > 0 && text2.count > 0 {
                       //提示成功
                       LocalStore.saveToWebsiteFaviator(weburl: Website(name: text1, url: text2, iconurl: self.iconFaviICO))
                       self.view.makeToast( NSLocalizedString("SaveSuccess", comment: ""), duration: 3.0, position: .bottom)
                   }else{
                       self.view.makeToast( NSLocalizedString("SaveFailed", comment: ""), duration: 3.0, position: .bottom)

                   }
               }
           }
           alertController.addAction(saveAction)
           
           // 显示弹出窗口
           present(alertController, animated: true, completion: nil)
    }
    
    @objc func searchButtonTapped(_ sender: AnyObject) {
        
        SwiftLoader.show(view: self.view,title: NSLocalizedString("Getingsvideo", comment: "") , animated: true)
       
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let u = self.m3u8playurl {
                self.hideVideoPopupView()
                self.showVideoPopupView(with: u)
            }else{
                self.view.makeToast(NSLocalizedString("Get_successful_online_video_faild", comment: ""), duration: 3.0, position: .center )

            }
            SwiftLoader.hide(view: self.view)
        }
        
        
//        let search = NaviSearchViewController()
//        self.show(search, sender: self)
    }
    
    @objc func actionButtonTapped(_ sender: AnyObject) {
        
        if let url: URL = ((webView.url != nil) ? webView.url : request.url) {
            let activities: NSArray = [SwiftWebVCActivitySafari(), SwiftWebVCActivityChrome()]
            
            if url.absoluteString.hasPrefix("file:///") {
                let dc: UIDocumentInteractionController = UIDocumentInteractionController(url: url)
                dc.presentOptionsMenu(from: view.bounds, in: view, animated: true)
            }
            else {
                let activityController: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: activities as? [UIActivity])
                
                if floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                    let ctrl: UIPopoverPresentationController = activityController.popoverPresentationController!
                    ctrl.sourceView = view
                    ctrl.barButtonItem = sender as? UIBarButtonItem
                }
                
                present(activityController, animated: true, completion: nil)
            }
        }
    }
    
    ////////////////////////////////////////////////
    
    @objc func doneButtonTapped() {
        closing = true
        UINavigationBar.appearance().barStyle = storedStatusColor!
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Class Methods

    /// Helper function to get image within SwiftWebVCResources bundle
    ///
    /// - parameter named: The name of the image in the SwiftWebVCResources bundle
    class func bundledImage(named: String) -> UIImage? {
        let image = UIImage(named: named)
        if image == nil {
            return UIImage(named: named, in: Bundle(for: SwiftWebVC.classForCoder()), compatibleWith: nil)
        } // Replace MyBasePodClass with yours
        return image
    }
    
}
 

extension SwiftWebVC: WKNavigationDelegate, WKUIDelegate   {
     
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        guard navigationAction.targetFrame == nil else {
              return nil
        }
        
        print("\(webView.url?.absoluteString ?? "")")
        
        // Create a new web view with the same configuration
        let newWebView = WKWebView(frame: self.view.bounds, configuration: configuration)
        self.view.addSubview(newWebView)
        newWebView.uiDelegate = self
        newWebView.navigationDelegate = self
        newWebView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newWebView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                    newWebView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                    newWebView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                    newWebView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                ])
        self.view.layoutIfNeeded()
          
        
         return newWebView
         
    }
    
    func showVideoPopupView(with url: URL?) {
        // 创建半透明遮罩视图
        
        self.m3u8playurl = url
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addSubview(overlayView)
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideVideoPopupView))
        overlayView.addGestureRecognizer(tapGesture)
        playVideourl = url
        
        // 创建并配置弹出视图
        let popupView = VideoPopupView()
        
        
        
//        popupView.playAction = { [weak self] in
//            if let url = url {
//                self?.playVideo(with: url)
//            }
//            
//        }
        //startButton.addTarget(self, action: #selector(ButtonhdplayurlTapped(_:)), for: .touchUpInside)
        
        popupView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(popupView)
        popupView.playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        
        
//        popupView.alpha = 0
//        
//        UIView.animate(withDuration: 0.3) {
//            popupView.alpha = 1
//        }
     
        NSLayoutConstraint.activate([
            popupView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 20),
            popupView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -20),
//            popupView.bottomAnchor.constraint(equalTo: overlayView.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            popupView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            popupView.heightAnchor.constraint(equalToConstant: 200)
//            popupView.topAnchor.constraint(equalTo: overlayView.topAnchor),
        ])
        
        webView.evaluateJavaScript("document.title", completionHandler: {(response, error) in
            if let s = response as? String {
                self.title = s
                popupView.configData(title: s, durationLabel:  "" )
            }
        })
        
        // // 使用示例
//        if let u = url{
//            VideoUnities().fetchVideoInfo(from: u.absoluteString) { duration, resolution in
//                if let duration = duration {
//                    print("视频时长: \(duration)秒")
//                } else {
//                    print("无法获取视频时长")
//                }
//                
//                if let resolution = resolution {
//                    print("视频分辨率: \(resolution)")
//                } else {
//                    print("无法获取视频分辨率")
//                }
//            }
//        }
//        
        
        // 保存视图到属性中
        self.videoPopupView = popupView
        self.overlayView = overlayView
    }
    
    @objc private func playButtonTapped() {
//        hideVideoPopupView()
        if let url = playVideourl {
            playVideo(with: url)
        }
        
    }
    
    @objc public func hideVideoPopupView() {
        UIView.animate(withDuration: 0.3) {
            self.overlayView?.alpha = 0
            self.videoPopupView?.alpha = 0
        }
        
        overlayView?.removeFromSuperview()
        videoPopupView?.removeFromSuperview()
        overlayView = nil
        videoPopupView = nil
    }
    
    private func playVideo(with url: URL) {
        // Implement video playback logic here
        print("Playing video from URL: \(url.absoluteString)")
//        hideVideoPopupView()
         
            
        let resource = KSPlayerResource(url: url,name: self.title ?? "")
       let controller = DetailViewController()
       controller.resource = resource
         

       controller.modalPresentationStyle = .fullScreen
       self.present(controller, animated:false)
  
    }
     
    

    // 2) 开始加载
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("\(#function)")
        self.delegate?.didStartLoading()
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        updateToolbarItems()
    }

    // 3) 接受到网页 response 后, 可以根据 statusCode 决定是否 继续加载。allow or cancel, 必须执行肥调 decisionHandler 。逃逸闭包的属性
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("\(#function)")
       guard let httpResponse = navigationResponse.response as? HTTPURLResponse else {
            decisionHandler(.allow)
            return
        }
        print("httpResponse.statusCode: \(httpResponse.statusCode)")

        let policy : WKNavigationResponsePolicy = httpResponse.statusCode == 200 ? .allow : .cancel
        decisionHandler(policy)
    }

    // 1）接受网页信息，决定是否加载还是取消。必须执行肥调 decisionHandler 。逃逸闭包的属性
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
          if let url = navigationAction.request.url {
              print("\(#function) \( url.absoluteString)")
              if url.absoluteString.localizedCaseInsensitiveContains("http") || url.absoluteString == "about:blank" {
                  decisionHandler(.allow)
              }else{
                  decisionHandler(.cancel)
                  if   url.absoluteString.localizedCaseInsensitiveContains("ytplayer://onReady") {
                       evaluatePlayerCommand("javascript:onVideoPlay()")
                  }
                  
                    //ytplayer://onYouTubeIframeAPIReady
              }
              
              if url.absoluteString.localizedCaseInsensitiveContains(".mobileprovision") {
                  UIApplication.shared.open(url,options: [:]) { complated in  }
//                  print("decidePolicyFor video URL: \(url.absoluteString)")
//                  self.showVideoPopupView(with: url)
                  // 处理视频 URL（如弹出播放界面或其他操作）
              }
              
          }
          
      }
   
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.delegate?.didFinishLoading(success: true)
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Inject JavaScript for dark mode
//        injectDarkModeJavaScript()
        webView.evaluateJavaScript("document.title", completionHandler: {(response, error) in
            if let s = response as? String {
                self.navBarTitle.text = s
                self.navBarTitle.sizeToFit()
            }
            self.updateToolbarItems()
        })
        
         SwiftLoader.hide()
        
       // self.showVideoPopupView(with: URL(string: "https://super.ffzy-online6.com/20240626/33711_6bf52cc1/2000k/hls/mixed.m3u8"))
        
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("\(#function) \( error.localizedDescription)")
        updateToolbarItems()
        SwiftLoader.hide()
    }
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.delegate?.didFinishLoading(success: false)
        print("didFail \( error.localizedDescription)")
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        updateToolbarItems()
        SwiftLoader.hide()
        
//        self.showNetworkErrorView(errormsg: "\(error.localizedDescription)") {
//            webView.reload()
//        }
    }
     
}



    
    /*
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        if let url = urlSchemeTask.request.url{
            // 打印请求的 URL
            print(">>>>>> \(url)")
            
            urlSchemeTask.request
            // 模拟响应，或者通过实际网络请求获取数据
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    let mimeType = response?.mimeType ?? "application/octet-stream"
                    let response = HTTPURLResponse(url: url, mimeType: mimeType, expectedContentLength: data.count, textEncodingName: nil)
                    urlSchemeTask.didReceive(response)
                    urlSchemeTask.didReceive(data)
                    urlSchemeTask.didFinish()
                    print(response.statusCode )
                    if (response.statusCode == 302) {
                        // 假设 resp 是 HTTPURLResponse 类型，urlSchemeTask 是 WKURLSchemeTask 类型
                        if let location = response.allHeaderFields["Location"] as? String {
                            let rspDataString = "<script>location = '\(location)';</script>"
                            print(rspDataString)
//                            if let rspData = rspDataString.data(using: .utf8) {
//                                var headers = response.allHeaderFields as? [String: String] ?? [:]
//                                headers["Content-Type"] = "text/html; charset=utf-8"
//                                headers["Content-Length"] = "\(rspData.count)"
//                                
//                                if let url = response.url {
//                                    if let newResp = HTTPURLResponse(url: url,
//                                                                  statusCode: response.statusCode,
//                                                                  httpVersion: "HTTP/1.1",
//                                                                     headerFields: headers) {
//                                        
//                                        urlSchemeTask.didReceive(newResp)
//                                    }
//                                    
//                                    urlSchemeTask.didReceive(rspData)
//                                    urlSchemeTask.didFinish()
//                                }
//                            }
                        }
 

                    }
                    
                } else if let error = error {
                    urlSchemeTask.didFailWithError(error)
                }
            }
            task.resume()
        }
       
        
       
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // Handle stopping of the task if needed
        
    }*/
    
class CustomURLSchemeHandler: NSObject, WKURLSchemeHandler {
    
    private let queue = DispatchQueue(label: "com.example.CustomURLSchemeHandlerQueue")

    
    public var ViewController:SwiftWebVC?
    
    private var pendingTasks = [ObjectIdentifier: TaskItem]()
    
        
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        
        self.queue.async {
                    if let taskItem = self.pendingTasks[urlSchemeTask.id] {
                        print("Stopping task \(urlSchemeTask)")
                        taskItem.stop()
                        self.pendingTasks.removeValue(forKey: urlSchemeTask.id)
                    }
                }
//        guard let task = pendingTasks.removeValue(forKey: urlSchemeTask.id) else { return }
//        print("Stopping task \(urlSchemeTask)")
//        task.stop()
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let task = Task { [weak self] in
            let request = urlSchemeTask.request
           //debugPrint(">>>>>> \(request.urlRequest?.url?.absoluteString ?? ""  )")
            
            if  let urlstring = request.urlRequest?.url?.absoluteString {
                
                if urlstring.contains(".m3u8") || urlstring.contains(".mp4") {
                      
                      await self?.ViewController?.hideVideoPopupView()
                    
                      await self?.ViewController?.showVideoPopupView(with: request.urlRequest?.url)
                      // 处理视频 URL（如弹出播放界面或其他操作）
                  }
            }
            // Do some mutation on the request
            
            do {
                try Task.checkCancellation()
                
                 // Conditionally get a URLSession
                let session: URLSession =  URLSession.shared
                
                // Fire off the request
                let (data, response) = try await session.data(for: request)
                
                await Task.yield()
                try Task.checkCancellation()

                // Report back to the scheme task
                // Either of these !! may crash in this implementation
//                urlSchemeTask.didReceive(response) // !!
//                urlSchemeTask.didReceive(data) // !!         
//                urlSchemeTask.didFinish() // !!
                
                self?.queue.async { [weak self] in
                    // !taskItem.isStopped
                   guard let taskItem = self?.pendingTasks[urlSchemeTask.id], !taskItem.task.isCancelled else {
                       return
                   }
                    
                    

                   urlSchemeTask.didReceive(response)
                   urlSchemeTask.didReceive(data)
                   urlSchemeTask.didFinish()

                   self?.pendingTasks.removeValue(forKey: urlSchemeTask.id)
               }
                
            } catch is CancellationError {
                // Do not call didFailWithError, didFinish, or didReceive in this case
                print("Task for WKURLSchemeTask \(urlSchemeTask) has been cancelled")
            } catch {
                if !Task.isCancelled {
                    // !! This can crash, too
                    //urlSchemeTask.didFailWithError(error)
                    
                    self?.queue.async {[weak self] in
                       guard let taskItem = self?.pendingTasks[urlSchemeTask.id], !taskItem.task.isCancelled  else {
                           return
                       }
                       urlSchemeTask.didFailWithError(error)
                       self?.pendingTasks.removeValue(forKey: urlSchemeTask.id)
                   }
        
                }
            }
//            print("\(self?.pendingTasks.count)")
//            do {
//                
//                //self?.pendingTasks.removeValue(forKey: urlSchemeTask.id)
//            }
//            catch {
//                print("pendingTasks.removeValue\(urlSchemeTask.id)  crash")
//            }
        }
        
        pendingTasks[urlSchemeTask.id] = .init(urlSchemeTask: urlSchemeTask, task: task)
    }

}


private extension WKURLSchemeTask {
    var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}

private struct TaskItem {
    enum Error: Swift.Error {
        case manualCancellation
    }
    
    let urlSchemeTask: WKURLSchemeTask
    let task: Task<Void, Never>
    
    /// Should be called when urlSchemeTask has been stopped by the system
    /// Calling anything on the urlSchemeTask afterwards would result in an exception
    func stop() {
        task.cancel()
    }
    
    /// Should be called when the urlSchemeTask should be stopped manually
    func cancel() {
        task.cancel()
        urlSchemeTask.didFailWithError(Error.manualCancellation)
    }
}
