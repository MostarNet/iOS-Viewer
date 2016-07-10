//
//  RegionViewController.swift
//  MostarNet
//
//  Created by Jakub Dubrovsky on 06/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
//

import UIKit

class RegionViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items = [Region]()
    var region: Region?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Region.fetchItems { (items) in
            self.items = items
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.region?.title
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item = self.items[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.items[indexPath.row]
        print(self.navigationController?.viewControllers.count)
        if let
            count = self.navigationController?.viewControllers.count,
            vc = self.navigationController?.viewControllers[count - 2] as? HomeViewController {
            print("bbb")
            vc.region = item
            self.navigationController?.popViewControllerAnimated(true)
        }
        //self.performSegueWithIdentifier("toDetail", sender: item)
    }
    
}
