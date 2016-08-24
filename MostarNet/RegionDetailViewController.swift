//
//  RegionDetailViewController.swift
//  MostarNet
//
//  Created by Jakub Dubrovsky on 23/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
//

import UIKit

class RegionDetailViewController: UIViewController {
    
    var detail: Region!
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadData()
    }
    func reloadData() {
        self.labelTitle.text = self.detail.title
        if let date = self.detail.downloadedAt {
            self.labelSubtitle.text = "Aktualizováno: \(NSDateFormatter.localizedStringFromDate(date, dateStyle: .ShortStyle, timeStyle: .ShortStyle))"            
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    
    @IBAction func clear(sender: AnyObject) {
        self.detail.clearBridgeItems()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func update(sender: AnyObject) {
        self.detail.fetchBridgeItems { (items) in
            self.reloadData()
        }
    }
    
    @IBAction func share(sender: AnyObject) {
        let activityViewController = UIActivityViewController(activityItems: [self.detail], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
    }
}
