//
//  TodayViewController.swift
//  MostarNet nearby
//
//  Created by Jakub Dubrovsky on 21/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
// http://blog.xebia.com/ios-today-widget-written-in-swift/
//

import UIKit
import NotificationCenter

import CoreData
import CoreLocation

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items = [BridgeItem]()
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        var currentSize: CGSize = self.preferredContentSize
        currentSize.height = 44 * 3
        self.preferredContentSize = currentSize
        
        
        self.locationManager.startUpdatingLocation()
        
        
        do {
            let fetchRequest = NSFetchRequest(entityName: BridgeItem.entityName())
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            if var items = try DataManager.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest) as? [BridgeItem] {
                
                if let location = self.locationManager.location {
                    items = items.sort({ (i1, i2) -> Bool in
                        return i1.distanceFromLocation(location) < i2.distanceFromLocation(location)
                    })
                }
                
                self.items = items
                self.tableView.reloadData()
            }
        } catch {
            
        }
        
        
        
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        completionHandler(NCUpdateResult.NewData)
    }
    //MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let item = self.items[indexPath.row]
        var t = ""
        if let location = self.locationManager.location {
            t = String(format:"%.2f km", item.distanceFromLocation(location) / 1000)
        }
        cell.textLabel?.text        = item.title
        cell.detailTextLabel?.text  = t
        cell.imageView?.image       = item.imageThumb
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.items[indexPath.row]
        let url = NSURL(string: "mostarnet://open/item/\(item.id)")!
        self.extensionContext?.openURL(url, completionHandler: { (_) in
            
        })
    }
    
    
    /*
     func updatePreferredContentSize() {
     preferredContentSize = CGSizeMake(CGFloat(0), CGFloat(tableView(tableView, numberOfRowsInSection: 0)) * CGFloat(tableView.rowHeight) + tableView.sectionFooterHeight)
     }
     
     override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
     coordinator.animateAlongsideTransition({ context in
     self.tableView.frame = CGRectMake(0, 0, size.width, size.height)
     }, completion: nil)
     }
     
     */
    //MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        print("didUpdateToLocation")
        locationManager.stopUpdatingLocation()
    }
    
}
