//
//  HomeViewController.swift
//  MostarNet
//
//  Created by Jakub Dubrovsky on 06/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
//

import UIKit
import MapKit


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentedControlDisplay: UISegmentedControl!
    
    var locationManager : CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        return locationManager
    }()
    
    var showMap = false {
        didSet {
            self.mapView.hidden     = !self.showMap
            self.tableView.hidden   = self.showMap
            
            self.segmentedControlDisplay.selectedSegmentIndex =  (self.showMap ? 0 : 1)
            
            if self.showMap {
                let authorizationStatus = CLLocationManager.authorizationStatus()
                if (authorizationStatus == CLAuthorizationStatus.NotDetermined) {
                    self.locationManager.requestWhenInUseAuthorization()
                }
            }
        }
    }
    
    var region: Region? {
        didSet {
            self.labelTitle.text = self.region?.title
            if let regionId = self.region?.id {
                BridgeItemGeoJSON.fetchItems(regionId) { (items) in
                    self.items = items
                }
            }
        }
    }
    
    var items = [BridgeItemGeoJSON]() {
        willSet {
            self.mapView.resignFirstResponder()
            self.mapView.removeAnnotations(self.items)
        }
        didSet {
            self.tableView.reloadData()
            
            self.mapView.addAnnotations(self.items)
            self.mapView.reloadInputViews()
            
            if let coor = self.items.first?.coordinate {
                self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(coor, 10000, 10000), animated: true)
            }
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.region = Region(title: "Libchavy", id: "07150")
        
        self.showMap = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc = segue.destinationViewController as? DetailViewController, detail = sender as? BridgeItemGeoJSON{
            vc.detail = detail
        }
    }
    
    
    @IBAction func displayTypeChanged(sender: UISegmentedControl) {
        // map/tableview
        self.showMap = sender.selectedSegmentIndex == 0
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
        cell.detailTextLabel?.text = item.subtitle
        cell.imageView?.image = item.imageThumb
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.items[indexPath.row]
        self.performSegueWithIdentifier("toDetail", sender: item)
    }
    
    //MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? BridgeItemGeoJSON {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "bridge")
            annotationView.canShowCallout = true
            annotationView.enabled = true
            
            let btn = UIButton(type: .DetailDisclosure)
            annotationView.rightCalloutAccessoryView = btn
            
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? BridgeItemGeoJSON {
            self.performSegueWithIdentifier("toDetail", sender: annotation)
        }
    }
    
    
}
