//
//  HybridControl.swift
//  HybridStstem
//
//  Created by Latte on 16/8/26.
//  Copyright © 2016年 舟弛 范. All rights reserved.
//

import UIKit

func getValueFromData<T>(data:AnyObject!, key:String, defVal:T) -> T {
    if let val = data as? T {
        return val
    }
    
    if let dict = data as? [NSObject:AnyObject] {
        if let val = dict[key] as? T {
            return val
        }
    }
    
    return defVal
}

class HybridControl {
    
    // MARK:- Basic URL
    static var BasicUrl:String = ""
    
    // MARK:- Init
    unowned let webViewController:HybridWebViewController
    
    let bridge:WebViewJavascriptBridge
    
    init(_webViewController:HybridWebViewController) {
        
        webViewController = _webViewController
        
        bridge = WebViewJavascriptBridge(forWebView: webViewController.webView)
        
        // Register Handler
        
        // Register Push & Pop
        bridge.registerHandler("LHS-Pop") {[unowned self] (data, callBack) in
            
            let animated:Bool = getValueFromData(data, key: "animated", defVal: true)
            
            self.webViewController.navigationController?.popViewControllerAnimated(animated)
        }
        
        bridge.registerHandler("LHS-Push") {[unowned self] (data, callBack) in
            
            let urlString = getValueFromData(data, key: "url", defVal: "")
            
            if urlString.characters.count <= 0 {
                self.webViewController.showAlert("JS need post a url")
                
                return
            }
            
            let newWebViewController = HybridWebViewController()
            
            newWebViewController.loadUrl(urlString, callBack: { (success) in
                if !success {
                    self.webViewController.showAlert("Load URL fail")
                    
                    return
                }
                
                let animated:Bool = getValueFromData(data, key: "animated", defVal: true)
                
                self.webViewController.navigationController?.pushViewController(newWebViewController, animated: animated)
            })
        }
        
        // Register Navigation Style
        bridge.registerHandler("LHS-NavigationStyle", handler: { (data, callBack) in
            self.webViewController.setNavigationStyle(getValueFromData(data, key: "barColor", defVal: "#ffffff"), fontColorString: getValueFromData(data, key: "fontColor", defVal: "#ffffff"), tintColorString: getValueFromData(data, key: "tintColor", defVal: "#ffffff"))
        })
        
        // Register Dismiss Controller
        bridge.registerHandler("LHS-Dismiss") { (data, callBack) in
            let animated:Bool = getValueFromData(data, key: "animated", defVal: true)
            
            self.webViewController.dismissViewControllerAnimated(animated, completion: nil)
        }
        
        // Register Present Controller
        bridge.registerHandler("LHS-Present") {[unowned self] (data, callBack) in
            
            let urlString = getValueFromData(data, key: "url", defVal: "")
            
            if urlString.characters.count <= 0 {
                self.webViewController.showAlert("JS need post a url")
                
                return
            }
            
            let newWebViewController = HybridWebViewController()
            
            newWebViewController.loadUrl(urlString, callBack: { [unowned self](success) in
                if !success {
                    self.webViewController.showAlert("Load URL fail")
                    
                    return
                }
                
                let animated:Bool = getValueFromData(data, key: "animated", defVal: true)
                
                let navigationController = UINavigationController(rootViewController: newWebViewController)
                
                navigationController.navigationBar.barTintColor = self.webViewController.navigationController?.navigationBar.barTintColor
                
                navigationController.navigationBar.tintColor = self.webViewController.navigationController?.navigationBar.tintColor
                
                navigationController.navigationBar.titleTextAttributes = self.webViewController.navigationController?.navigationBar.titleTextAttributes
                
                self.webViewController.presentViewController(navigationController, animated: animated, completion: nil)//(navigationController, animated: animated)
            })
        }
        
        bridge.setWebViewDelegate(self.webViewController)
        
    }
    
    // MARK:- ViewController
    func rootViewController() -> UIViewController {
        
        let viewController = UIViewController()
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        return navigationController
    }
}
