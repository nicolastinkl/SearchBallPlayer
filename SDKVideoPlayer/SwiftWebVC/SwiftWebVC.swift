//
//  SwiftWebVC.swift
//
//  Created by Myles Ringle on 24/06/2015.
//  Transcribed from code used in SVWebViewController.
//  Copyright (c) 2015 Myles Ringle & Sam Vermette. All rights reserved.
//

import WebKit

public protocol SwiftWebVCDelegate: class {
    func didStartLoading()
    func didFinishLoading(success: Bool)
}

public class SwiftWebVC: UIViewController{
    
    
     private struct AssociatedKeys {
         static var videoPopupView = "videoPopupView"
         static var overlayView = "overlayView"
     }
     
     private var videoPopupView: VideoPopupView? {
         get {
             return objc_getAssociatedObject(self, &AssociatedKeys.videoPopupView) as? VideoPopupView
         }
         set {
             objc_setAssociatedObject(self, &AssociatedKeys.videoPopupView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
         }
     }
     
     private var overlayView: UIView? {
         get {
             return objc_getAssociatedObject(self, &AssociatedKeys.overlayView) as? UIView
         }
         set {
             objc_setAssociatedObject(self, &AssociatedKeys.overlayView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
         }
     }
    
    public weak var delegate: SwiftWebVCDelegate?
    var storedStatusColor: UIBarStyle?
    var buttonColor: UIColor? = nil
    var titleColor: UIColor? = nil
    var closing: Bool! = false
    
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
    
    var sharingEnabled = true
    
    ////////////////////////////////////////////////
    
    deinit {
        webView.stopLoading()
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        webView.uiDelegate = nil;
        webView.navigationDelegate = nil;
    }
    
    public convenience init(urlString: String, sharingEnabled: Bool = true) {
        var urlString = urlString
        if !urlString.hasPrefix("https://") && !urlString.hasPrefix("http://") {
            urlString = "https://"+urlString
        }
        self.init(pageURL: URL(string: urlString)!, sharingEnabled: sharingEnabled)
    }
    
    public convenience init(pageURL: URL, sharingEnabled: Bool = true) {
        self.init(aRequest: URLRequest(url: pageURL), sharingEnabled: sharingEnabled)
    }
    
    public convenience init(aRequest: URLRequest, sharingEnabled: Bool = true) {
        self.init()
        self.sharingEnabled = sharingEnabled
        self.request = aRequest
    }
    
    
    func loadRequest(_ request: URLRequest) {
        webView.load(request)
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
        webConfiguration.setURLSchemeHandler(schemeHandler, forURLScheme: "https")
        
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
        SwiftLoader.show(view: self.view,title: "正在加载中...", animated: true)
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
        
//        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
//            self.navigationController?.setToolbarHidden(false, animated: false)
//        }
//        else if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
//            self.navigationController?.setToolbarHidden(true, animated: true)
//        }
    }
    
//    override public func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        
//        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
//            self.navigationController?.setToolbarHidden(true, animated: true)
//        }
//    }
//    
//    override public func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(true)
////        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//    
    ////////////////////////////////////////////////
    // Toolbar
    
    func updateToolbarItems() {
        return
        backBarButtonItem.isEnabled = webView.canGoBack
        forwardBarButtonItem.isEnabled = webView.canGoForward
        
        let refreshStopBarButtonItem: UIBarButtonItem = webView.isLoading ? stopBarButtonItem : refreshBarButtonItem
        
        let fixedSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            
            let toolbarWidth: CGFloat = 250.0
            fixedSpace.width = 35.0
            
            let items: NSArray = sharingEnabled ? [fixedSpace, refreshStopBarButtonItem, fixedSpace, backBarButtonItem, fixedSpace, forwardBarButtonItem, fixedSpace, actionBarButtonItem] : [fixedSpace, refreshStopBarButtonItem, fixedSpace, backBarButtonItem, fixedSpace, forwardBarButtonItem]
            
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
            
        }
        else {
            let items: NSArray = sharingEnabled ? [fixedSpace, backBarButtonItem, flexibleSpace, forwardBarButtonItem, flexibleSpace, refreshStopBarButtonItem, flexibleSpace, actionBarButtonItem, fixedSpace] : [fixedSpace, backBarButtonItem, flexibleSpace, forwardBarButtonItem, flexibleSpace, refreshStopBarButtonItem, fixedSpace]
            
            if let navigationController = navigationController, !closing {
                if presentingViewController == nil {
                    navigationController.toolbar.barTintColor = navigationController.navigationBar.barTintColor
                }
                else {
                    navigationController.toolbar.barStyle = navigationController.navigationBar.barStyle
                }
                navigationController.toolbar.tintColor = navigationController.navigationBar.tintColor
                toolbarItems = items as? [UIBarButtonItem]
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

extension SwiftWebVC: WKUIDelegate {
    
    // Add any desired WKUIDelegate methods here: https://developer.apple.com/reference/webkit/wkuidelegate
    
}

extension SwiftWebVC: WKNavigationDelegate  {
     
    
    func showVideoPopupView(with url: URL?) {
        // 创建半透明遮罩视图
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
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
        
        // 创建并配置弹出视图
        let popupView = VideoPopupView()
        popupView.titleLabel.text = "Video Title" // Customize the title
        popupView.durationLabel.text = "Duration: 00:00" // Fetch and set the actual duration
        popupView.playAction = { [weak self] in
            if let url = url {
                self?.playVideo(with: url)
            }
            
        }
        
        overlayView.addSubview(popupView)
        
        popupView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            popupView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -16),
            popupView.bottomAnchor.constraint(equalTo: overlayView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        // 保存视图到属性中
        self.videoPopupView = popupView
        self.overlayView = overlayView
    }
    
    @objc private func hideVideoPopupView() {
        overlayView?.removeFromSuperview()
        videoPopupView?.removeFromSuperview()
        overlayView = nil
        videoPopupView = nil
    }
    
    private func playVideo(with url: URL) {
        // Implement video playback logic here
        print("Playing video from URL: \(url.absoluteString)")
        hideVideoPopupView()
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.delegate?.didStartLoading()
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        updateToolbarItems()
        
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
          if let url = navigationAction.request.url {
              print("decidePolicyFor \( url.absoluteString)")
//              if url.absoluteString.contains(".m3u8") {
//                  print("decidePolicyFor video URL: \(url.absoluteString)")
//                  self.showVideoPopupView(with: url)
//                  // 处理视频 URL（如弹出播放界面或其他操作）
//              }
          }
          decisionHandler(.allow)
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
        
        self.showVideoPopupView(with: URL(string: "https://super.ffzy-online6.com/20240626/33711_6bf52cc1/2000k/hls/mixed.m3u8"))
        
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.delegate?.didFinishLoading(success: false)
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//        updateToolbarItems()
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
    
    public var ViewController:SwiftWebVC?
    
    private var pendingTasks = [ObjectIdentifier: TaskItem]()
    
        
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        guard let task = pendingTasks.removeValue(forKey: urlSchemeTask.id) else { return }
        print("Stopping task \(urlSchemeTask)")
        task.stop()
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let task = Task { [weak self] in
            let request = urlSchemeTask.request
            print(">>>>>> \(request.urlRequest?.url?.absoluteString ?? ""  )")
            
            if  let urlstring = request.urlRequest?.url?.absoluteString {
                  if urlstring.contains(".m3u8") {
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
                urlSchemeTask.didReceive(response) // !!
                urlSchemeTask.didReceive(data) // !!
                urlSchemeTask.didFinish() // !!
                
            } catch is CancellationError {
                // Do not call didFailWithError, didFinish, or didReceive in this case
                print("Task for WKURLSchemeTask \(urlSchemeTask) has been cancelled")
            } catch {
                if !Task.isCancelled {
                    // !! This can crash, too
                    urlSchemeTask.didFailWithError(error)
                }
            }
            print("\(self?.pendingTasks.count)")
            do {
                
                //self?.pendingTasks.removeValue(forKey: urlSchemeTask.id)
            }
            catch {
                print("pendingTasks.removeValue\(urlSchemeTask.id)  crash")
            }
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
