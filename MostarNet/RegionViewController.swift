//
//  RegionViewController.swift
//  MostarNet
//
//  Created by Jakub Dubrovsky on 06/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
//

import UIKit

import CoreData

class RegionViewController: UIViewController, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var fetchedResultsController   :NSFetchedResultsController! = {
        
        let fetchRequest = NSFetchRequest(entityName: Region.entityName())
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchResultsController:NSFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataManager.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Region.fetchItems {
            do {
                try self.fetchedResultsController.performFetch()
                self.tableView.reloadData()
            } catch { }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let
            count = self.fetchedResultsController.sections?[section].numberOfObjects
            else {
                return 0
        }
        
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        guard let
            item = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Region
            else {
                return cell
        }
        
        cell.textLabel?.text = item.title
        
        if item.isDownloaded {
            cell.accessoryType = UITableViewCellAccessoryType.DetailButton
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let
            item = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Region
            else {
                return
        }
        if item.isDownloaded {
            self.performSegueWithIdentifier("toDetail", sender: item)
        } else {
            item.fetchBridgeItems({ (items) in
                self.tableView.reloadData()
            })
        }
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        guard let
            item = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Region
            else {
                return
        }
        if item.isDownloaded {
            self.performSegueWithIdentifier("toDetail", sender: item)
        } else {
            item.fetchBridgeItems({ (items) in
                self.tableView.reloadData()
            })
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? RegionDetailViewController, detail = sender as? Region {
            vc.detail = detail
        }
    }
}
