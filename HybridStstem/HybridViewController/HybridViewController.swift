//
//  HybridViewController.swift
//  Team
//
//  Created by 舟弛 范 on 15/8/21.
//  Copyright (c) 2015年 舟弛 范. All rights reserved.
//

import UIKit

public let HybridViewControllerLoseSessionResponse: String = "HybridViewControllerLoseSessionResponse";
public let HybridViewControllerLoseReloadResponse: String = "HybridViewControllerLoseReloadResponse";

@objc
protocol HybridViewControllerDelegate : NSObjectProtocol
{
    optional func hybridViewControllerReceviedBridgeData(controller: HybridViewController, receiveData data:[String: AnyObject]);
    
    optional func currentNavigationController(controller: HybridViewController) -> UINavigationController?;
    
    // 注册被JS能调用的函数
    optional func hybirdViewControllerRegisterHandler(bridge: WebViewJavascriptBridge?) -> Void;
    
    optional func getHybridViewController(controller:HybridViewController) -> HybridViewController?;
}

class HybridNotificationServer
{
    private var callBack:WVJBResponseCallback;
    
    weak var observer:HybridViewController?;
    
    init (observer:HybridViewController, callBack:WVJBResponseCallback)
    {
        self.observer = observer;
        
        self.callBack = callBack;
    }
}

class HybridNotificationCenter : NSObject
{
    //MARK : Get Default Center
    static var _defaultCenter = HybridNotificationCenter();
    
    class func defaultCenter () -> HybridNotificationCenter
    {
        return _defaultCenter;
    }
    
    //MARK : Notification Manager
    var notificationManager:Dictionary<String, HybridNotificationServer> = Dictionary<String, HybridNotificationServer>();
    
    func addObserver(serverName:String, observer:HybridViewController, callBack:WVJBResponseCallback)
    {
        removeObserver(serverName);
        notificationManager[serverName] = HybridNotificationServer(observer: observer, callBack: callBack);
    }
    
    func removeObserver(serverName:String)
    {
        notificationManager.removeValueForKey(serverName);
    }
    
    func resignObserver(observer:HybridViewController)
    {
        var array:[String] = [];
        for (key, value) in notificationManager
        {
            
            print("value is \(value.observer) observer is \(observer)");
            if value.observer == observer
            {
                array.append(key);
            }
        }
        
        for one in array
        {
            notificationManager.removeValueForKey(one);
        }
    }
    
    func postNotification(serverName:String, postData:AnyObject?)
    {
        let server = notificationManager[serverName];
        
        if (server?.observer == nil)
        {
            removeObserver(serverName);
            return;
        }
        
        server?.callBack(postData);
    }
}

class HybridViewController : UIViewController, UIWebViewDelegate
{
    //MARK : Base Property
    var statusLight:Bool = false;
    
    //MARK : UI Connect
    @IBOutlet weak var delegate: HybridViewControllerDelegate? = nil;
    
    var bridge: WebViewJavascriptBridge? = nil;
    
    var parameterString: String? = nil;
    
    var _loadUrlString: String? = nil;
    
    var postData: [String:String]? = nil;
    
    var loadUrlString: String?
    {
        get
        {
            return _loadUrlString;
        }
        set
        {
            _loadUrlString = newValue;
            
            if (_loadUrlString != nil && webView != nil)
            {
                let newUrlString: String? = _loadUrlString!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet());
                
                if (newUrlString == nil)
                {
                    return;
                }
                
                let url = NSURL(string: newUrlString!);
                
                if (url == nil)
                {
                    return;
                }
                
                let request = NSMutableURLRequest(URL: url!);
                
                // Static Web
                if (_loadUrlString!.containsString(".html") || _loadUrlString!.containsString(".htm"))
                {
                    request.HTTPMethod = "GET";
                }
                else
                {
                    request.HTTPMethod = "POST";
                }
                
                var parameterString: String = "clienttype=ios";
                
                if (postData != nil)
                {
                    for (key, value) in postData!
                    {
                        let string = "&" + key + "=" + value + "";
                        
                        parameterString += string;
                    }
                }
                
                request.HTTPBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding);
                
                webView!.loadRequest(request);
            }
        }
    }
    
    @IBOutlet weak var webView: UIWebView?
    
    deinit
    {
        print("deinit");
//        HybridNotificationCenter.defaultCenter().resignObserver(self);
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return statusLight ? UIStatusBarStyle.LightContent : UIStatusBarStyle.Default;
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return false;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil);
        
        if (webView != nil)
        {
            for subview in webView!.subviews
            {
                if let scrollView = subview as? UIScrollView
                {
                    scrollView.bounces = false;
                    scrollView.showsHorizontalScrollIndicator = false;
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HybridViewController.reloadWebView(_:)), name: HybridViewControllerLoseReloadResponse, object: nil);
        
        loadUrlString = _loadUrlString;
        
        bridge = WebViewJavascriptBridge(forWebView: webView!)
        
        bridge?.registerHandler("LHS", handler: {[unowned self]
            (data: AnyObject!, callBack: WVJBResponseCallback!) ->  Void in
            
            let nc = self.delegate?.currentNavigationController?(self) != nil ? self.delegate?.currentNavigationController?(self) : self.navigationController;
            
            if let responseData = data as? [String: AnyObject]
            {
                self.delegate?.hybridViewControllerReceviedBridgeData?(self, receiveData: responseData);
                
                let action: String? = responseData["Action"] as? String;
                let url: String? = responseData["Url"] as? String;
                
                if (action == "Push" && url != nil)
                {
                    let controller = self.HyrbridViewControllerWithUrl(url!);
                    
                    controller.delegate = self.delegate;
                    
                    nc?.pushViewController(controller, animated: true);
                    
                    if (responseData["Title"] != nil && responseData["Title"]!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0)
                    {
                        controller.title = responseData["Title"] as? String;
                    }
                }
                else if (action == "Present" && url != nil)
                {
                    let controller = self.HyrbridViewControllerWithUrl(url!);
                    
                    controller.delegate = self.delegate;
                    
                    nc?.presentViewController(controller, animated: true, completion: nil);
                    
                    if responseData["Title"] != nil && responseData["Title"]!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
                    {
                        controller.title = responseData["Title"] as? String;
                    }
                }
                else if (action == "Pop")
                {
                    self.navigationController?.popViewControllerAnimated(true);
                }
                else if (action == "PopRoot")
                {
                    self.navigationController?.popToRootViewControllerAnimated(true);
                }
                else if (action == "Dismiss")
                {
                    self.dismissViewControllerAnimated(true, completion: nil);
                }
                else if (action == "SetTitle")
                {
                    if responseData["Title"] != nil && responseData["Title"]!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
                    {
                        self.title = responseData["Title"] as? String;
                    }
                }
                else if (action == "SetRightItem")
                {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: responseData["Title"] as? String, style: UIBarButtonItemStyle.Done, target: self, action: #selector(HybridViewController.rightItemPress(_:)));
                }
                else if (action == "OpenUrl")
                {
                    UIApplication.sharedApplication().openURL(NSURL(string: responseData["Url"] as! String)!);
                }
                else if (action == "GetIOSVersion")
                {
                    let version: String = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String;
                    callBack(version);
                }
                else if (action == "AddObserver")
                {
                    let serverName = responseData["ServerName"] as? String;
                    
                    if (serverName != nil)
                    {
                        HybridNotificationCenter.defaultCenter().addObserver(serverName!, observer: self, callBack: callBack);
                    }
                }
                else if (action == "RemoveObserver")
                {
                    let serverName = responseData["ServerName"] as? String;
                    
                    if (serverName != nil)
                    {
                        HybridNotificationCenter.defaultCenter().removeObserver(serverName!);
                    }
                }
                else if (action == "PostNotification")
                {
                    let serverName = responseData["ServerName"] as? String;
                    
                    let postData = responseData["PostData"];
                    
                    if (serverName != nil)
                    {
                        HybridNotificationCenter.defaultCenter().postNotification(serverName!, postData: postData);
                    }
                }
            }
            })
        
        // Do any additional setup after loading the view.
        
        // register handler
        self.delegate?.hybirdViewControllerRegisterHandler?(self.bridge);
    }
    
    // notification
    func reloadWebView (notification: NSNotification)
    {
        self.webView?.reload();
    }
    
    // Right Btn
    func rightItemPress (sender: UIBarButtonItem?)
    {
        self.bridge?.callHandler("LHS",data: "RightItemHandler")
    }
    
    // MARK - STATIC FUNCTION
    func HyrbridViewControllerWithUrl(urlString: String!) -> HybridViewController
    {
        var hybridController:HybridViewController? = self.delegate?.getHybridViewController?(self);
        
        if (hybridController == nil)
        {
            hybridController = HybridViewController(nibName: "HybridViewController", bundle: NSBundle.mainBundle());
        }
        
        hybridController!.loadUrlString = urlString;
        
        return hybridController!;
    }
    
}
