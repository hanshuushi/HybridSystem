//
//  HybridWebViewController.swift
//  HybridStstem
//
//  Created by Latte on 16/8/26.
//  Copyright © 2016年 舟弛 范. All rights reserved.
//

import UIKit

private extension UIColor {
    convenience init(__hexString: String){
        var cString: String = __hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if cString.characters.count < 6 {
            self.init(red: 1, green: 1, blue: 1, alpha: 1)
            return
        }
        
        if cString.hasPrefix("0X") {cString = cString.substringFromIndex(cString.startIndex.advancedBy(2))}
        if cString.hasPrefix("#") {cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))}
        if cString.characters.count != 6 {
            self.init(red: 1, green: 1, blue: 1, alpha: 1)
            return
        }
        
        var range: NSRange = NSMakeRange(0, 2)
        
        let rString = (cString as NSString).substringWithRange(range)
        range.location = 2
        let gString = (cString as NSString).substringWithRange(range)
        range.location = 4
        let bString = (cString as NSString).substringWithRange(range)
        
        var r: UInt32 = 0x0
        var g: UInt32 = 0x0
        var b: UInt32 = 0x0
        NSScanner.init(string: rString).scanHexInt(&r)
        NSScanner.init(string: gString).scanHexInt(&g)
        NSScanner.init(string: bString).scanHexInt(&b)
        
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(1))
        
    }
}

class HybridWebViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: - UI
    let webView:UIWebView
    
    var hybridControl:HybridControl!
    
    init (){
        webView = UIWebView()
        
        super.init(nibName: nil, bundle: nil)
        
        webView.delegate = self
        
        hybridControl = HybridControl(_webViewController: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(webView)
        
        // add layout
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints:[NSLayoutConstraint] = []
        
        constraints.append(NSLayoutConstraint(item: webView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1.0,
            constant: 0.0))
        
        constraints.append(NSLayoutConstraint(item: webView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1.0,
            constant: 0.0))
        
        constraints.append(NSLayoutConstraint(item: webView,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1.0,
            constant: 0.0))
        
        constraints.append(NSLayoutConstraint(item: webView,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1.0,
            constant: 0.0))
        
        self.view.addConstraints(constraints)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(navigationHidden, animated: animated)
        
        self.title = navigationTitle
        
        self.view.backgroundColor = backgroundColor
        self.webView.backgroundColor = backgroundColor
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarStyle == StatusBarStyle.Hidden
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return statusBarStyle == StatusBarStyle.Dark ? UIStatusBarStyle.Default : UIStatusBarStyle.LightContent
    }
    
    // MARK - Alert
    func showAlert(content:String, title:String?=nil) {
        let alertView = UIAlertView(title: title ?? "",
                                    message: content,
                                    delegate: nil,
                                    cancelButtonTitle: nil,
                                    otherButtonTitles: "OK")
        
        alertView.show()
    }
    
    // MARK:- Load URL
    typealias LoadUrlCallBack = (success:Bool) -> Void
    
    var requestCallBack:LoadUrlCallBack? = nil
    
    func loadUrl(urlString:String, callBack:LoadUrlCallBack?=nil) {
        guard let encodingURLString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) else {
            callBack?(success: false)
            
            return
        }
        
        guard let url = NSURL(string: HybridControl.BasicUrl + encodingURLString) else {
            callBack?(success: false)
            
            return
        }
        
        let request = NSURLRequest(URL: url)
        
        requestCallBack = callBack
        
        webView.loadRequest(request)
    }
    
    // MAKR - WEBVIEW DELEGATE
    func webViewDidFinishLoad(webView: UIWebView) {
        loadHTMLHead()
        
        requestCallBack?(success: true)
        
        requestCallBack = nil
    }
    
    deinit {
        print("delloc")
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        requestCallBack?(success: false)
        
        requestCallBack = nil
    }
    
    // MARK:- View Controller Refer
    func setNavigationStyle(barColorString:String, fontColorString:String, tintColorString:String) {
        self.navigationController?.navigationBar.barTintColor = UIColor(__hexString: barColorString)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(__hexString: fontColorString)]
        
        self.navigationController?.navigationBar.tintColor = UIColor(__hexString: tintColorString)
    }
    
    private var navigationHidden = false
    
    private var statusBarStyle = StatusBarStyle.Dark
    
    private enum StatusBarStyle : String {
        case Hidden, Light, Dark
    }
    
    private var navigationTitle = ""
    
    private var backgroundColor:UIColor = UIColor.whiteColor()
    
    private func loadHTMLHead() {
        // get title
        var javascript = "document.title"
        
        navigationTitle = webView.stringByEvaluatingJavaScriptFromString(javascript) ?? ""
        
        let selectorString = "document.querySelector('meta[name=\"LHS-Bridge\"]')"
        
        // get background color
        javascript = selectorString + ".getAttribute('background-color')"
        
        backgroundColor = UIColor(__hexString: webView.stringByEvaluatingJavaScriptFromString(javascript) ?? "#ffffff")
        
        // get navigation hidden
        javascript = selectorString + ".getAttribute('navigation-hidden')"
        
        navigationHidden = webView.stringByEvaluatingJavaScriptFromString(javascript) == "true" || webView.stringByEvaluatingJavaScriptFromString(javascript) == "1"
        
        print("value is \(webView.stringByEvaluatingJavaScriptFromString(javascript))")
        
        print(navigationHidden)
        
        javascript = selectorString + ".getAttribute('statusbar-style')"
        
        statusBarStyle = StatusBarStyle(rawValue:webView.stringByEvaluatingJavaScriptFromString(javascript) ?? "Dark") ?? StatusBarStyle.Dark
        
    }
}