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

private class HybridControlNotificationManager {
    static let shareInstance:HybridControlNotificationManager = HybridControlNotificationManager()
    
    class Notification : NSObject {
        unowned let control:HybridControl
        
        let name:String
        
        init(_name:String, _control:HybridControl) {
            name = _name;
            
            control = _control
        }
    }
    
    var notifications = Array<Notification>()
    
    func registerHandler(name:String, control:HybridControl) {
        notifications.append(Notification(_name: name, _control: control))
    }
    
    func removeObjectFromNotifications (item:Notification) {
        if let index = notifications.indexOf(item) {
            notifications.removeAtIndex(index)
        }
    }
    
    func removeHandler(handlerName name:String) {
        for notification in notifications {
            if notification.name == name {
                removeObjectFromNotifications (notification)
            }
        }
    }
    
    func removeHandler(hybridControl control:HybridControl) {
        for notification in notifications {
            if notification.control == control {
                removeObjectFromNotifications (notification)
            }
        }
    }
    
    func removeHandler(handlerName name:String, hybridControl control:HybridControl) {
        for notification in notifications {
            if notification.name == name  && notification.control == control  {
                removeObjectFromNotifications (notification)
            }
        }
    }
    
    func callHandler(name:String, data:AnyObject) {
        print(notifications)
        for notification in notifications {
            if notification.name == name {
                notification.control.callHandler(name, data: data)
            }
        }
    }
}

class HybridControl : NSObject {
    
    // MARK:- Basic URL
    static var BasicUrl:String = ""
    
    // MARK:- Init
    unowned let webViewController:HybridWebViewController
    
    let bridge:WebViewJavascriptBridge
    
    deinit {
        HybridControlNotificationManager.shareInstance.removeHandler(hybridControl: self)
    }
    
    init(_webViewController:HybridWebViewController) {
        
        webViewController = _webViewController
        
        bridge = WebViewJavascriptBridge(forWebView: webViewController.webView)
        
        super.init()
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
        
        // Register Handler
        bridge.registerHandler("LHS-RegisterHandler") { [unowned self](data, callBack) in
            
            guard let name = data as? String else {
                return
            }
            
            HybridControlNotificationManager.shareInstance.registerHandler(name, control: self)
        }
        
        // Call Handler
        bridge.registerHandler("LHS-CallHandler") { (data, callBack) in
            
            guard let dict = data as? [String:AnyObject] else {
                return
            }
            
            guard let name = dict["name"] as? String else {
                return
            }
            
            let postData = dict["data"] as? NSObject
            
            HybridControlNotificationManager.shareInstance.callHandler(name, data: postData ?? "")
        }
        
        // Remove Handler
        bridge.registerHandler("LHS-RemoveHandler") { [unowned self](data, callBack) in
            guard let name = data as? String else {
                return
            }
            
            HybridControlNotificationManager.shareInstance.removeHandler(handlerName: name, hybridControl: self)
        }
        
        // Set Navigation Left Handler
        bridge.registerHandler("LHS-SetNavigationLeftItem") { [unowned self](data, callBack) in
            guard let title = data as? String else {
                return
            }
            
            self.webViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: title,
                style: .Plain,
                target: self,
                action: #selector(HybridControl.leftNavigationItemPressed)
            )
        }
        
        bridge.registerHandler("LHS-RemoveNavigationLeftItem") { [unowned self](data, callBack) in
            self.webViewController.navigationItem.leftBarButtonItem = nil
        }
        
        // Set Navigation Right Handler
        bridge.registerHandler("LHS-SetNavigationRightItem") { [unowned self](data, callBack) in
            guard let title = data as? String else {
                return
            }
            
            self.webViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: title,
                style: .Plain,
                target: self,
                action: #selector(HybridControl.rightNavigationItemPressed)
            )
        }
        
        bridge.registerHandler("LHS-RemoveNavigationRightItem") { [unowned self](data, callBack) in
            self.webViewController.navigationItem.rightBarButtonItem = nil
        }
        
        bridge.setWebViewDelegate(self.webViewController)
    }
    
    func leftNavigationItemPressed() {
        bridge.callHandler("LHS-NavigationLeftItemPressed", data: nil)
    }
    
    func rightNavigationItemPressed() {
        bridge.callHandler("LHS-NavigationRightItemPressed", data: nil)
    }
    
    func callHandler(name:String, data:AnyObject) {
        bridge.callHandler("LHS-CallHandlerToJS", data: ["name":name, "data":data])
    }
    
    // MARK:- ViewController
    func rootViewController() -> UIViewController {
        
        let viewController = UIViewController()
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        return navigationController
    }
}
