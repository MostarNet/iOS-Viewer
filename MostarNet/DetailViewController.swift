//
//  DetailViewController.swift
//  MostarNet
//
//  Created by Jakub Dubrovsky on 06/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
//

import UIKit

enum ItemDetailDisplayType {
    case content
    case map
}

class DetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imageViewTop: UIImageView!
    
    @IBOutlet weak var webViewMap: UIWebView!
    
    var itemDetailDisplayType : ItemDetailDisplayType = .content {
        didSet {
            self.viewContent.hidden = true
            self.viewMap.hidden = true
            
            switch self.itemDetailDisplayType {
            case .content:
                self.viewContent.hidden = false
            case .map:
                self.viewMap.hidden = false
            }
        }
    }
    
    var detail : BridgeItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.opaque = false
        self.webView.backgroundColor = UIColor.clearColor()
        self.webView.scrollView.contentInset = UIEdgeInsets(top: self.imageViewTop.frame.size.height, left: 0, bottom: 0, right: 0)
        self.webView.scrollView.delegate = self
        
        self.itemDetailDisplayType = .content
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let imageThumb = self.detail.imageThumb {
            self.imageViewTop.image = imageThumb
        }
        
        if let urlImage = self.detail.photoURL {
            let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            var dataTask: NSURLSessionTask?
            
            
            dataTask = defaultSession.dataTaskWithURL(urlImage, completionHandler: { (data, response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil,
                        let data = data,
                        image = UIImage(data: data) {
                        self.imageViewTop.image = image
                    }
                    
                })
            })
            dataTask?.resume()
            
        }
        
        if let detail = self.detail {
            self.webView.loadRequest(NSURLRequest(URL: NSURL(string: detail.url)!))
            
            self.webViewMap.loadRequest(NSURLRequest(URL: NSURL(string: "http://mosty.mostar.cz/mapito/#pinX=\(self.detail.longitude)&pinY=\(self.detail.latitude)&z=8")!))
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        self.userActivity = NSUserActivity(activityType: "cz.mostar.object")
        if let userActivity = userActivity {
            userActivity.title = self.detail.title
            userActivity.contentAttributeSet = self.detail.searchableItem().attributeSet
            userActivity.webpageURL = NSURL(string: self.detail.url)
            userActivity.eligibleForHandoff = true
            userActivity.eligibleForSearch = false
            userActivity.eligibleForPublicIndexing = false
            userActivity.becomeCurrent()
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.userActivity?.resignCurrent()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func displayStyleChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.itemDetailDisplayType = .content
        case 1:
            self.itemDetailDisplayType = .map
        default:
            self.itemDetailDisplayType = .content
        }
        
    }
    //MARK: actions
    @IBAction func action(sender: AnyObject) {
        
        let vc = UIAlertController(title: self.detail.title, message: self.detail.subtitle, preferredStyle: .ActionSheet)
        vc.addAction(UIAlertAction(title: "Zrušit", style: .Cancel, handler: { (_) in
            
        }))
        vc.addAction(UIAlertAction(title: "Sdílet", style: .Default, handler: { (_) in
            self.share()
        }))
        if self.detail.latitude > 0 && self.detail.longitude > 0 {
            vc.addAction(UIAlertAction(title: "Navigovat", style: .Default, handler: { (_) in
                self.navigate()
            }))
        }
        self.presentViewController(vc, animated: true) {
            
        }
    }
    
    
    func share() {
        let activityViewController = UIActivityViewController(activityItems: [detail], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
    }
    
    func navigate() {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?q=\(self.detail.latitude),\(self.detail.longitude)")!)
    }
    
    
    //MARK: uiscrollviewdelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView == self.webView.scrollView {
            let heightImage = self.imageViewTop.frame.size.height
            let offsetY = scrollView.contentOffset.y
            
            if offsetY < 0 {
                self.imageViewTop.alpha = 1 - ((heightImage / 100) * (heightImage + offsetY)) / 100
            }
            
            
            
        }
        
    }
    
    
}
