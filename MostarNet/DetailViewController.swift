//
//  DetailViewController.swift
//  MostarNet
//
//  Created by Jakub Dubrovsky on 06/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var detail : BridgeItemGeoJSON?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let detail = self.detail {
            self.webView.loadRequest(NSURLRequest(URL: NSURL(string: detail.url)!))
        }
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
        if sender.selectedSegmentIndex == 1 {
            if let
                latitude = self.detail?.coordinate.latitude,
                longitude = self.detail?.coordinate.longitude
            {
                UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?q=\(latitude),\(longitude)")!)
                sender.selectedSegmentIndex = 0
            }
        }
    }
    
    @IBAction func action(sender: AnyObject) {
        
        let activityViewController = UIActivityViewController(activityItems: [(self.detail?.title)!, (self.detail?.url)!], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
    }
}
