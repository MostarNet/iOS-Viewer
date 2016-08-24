//
//  HomeViewController.swift
//  MostarNet
//
//  Created by Jakub Dubrovsky on 06/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView      : MKMapView!
    @IBOutlet weak var tableView    : UITableView!
    
    @IBOutlet weak var segmentedControlDisplay: UISegmentedControl!
    
    lazy var fetchedResultsController   :NSFetchedResultsController! = {
        
        let fetchRequest = NSFetchRequest(entityName: BridgeItem.entityName())
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "region.title", ascending: true), NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchResultsController:NSFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataManager.sharedInstance.managedObjectContext, sectionNameKeyPath: "region.title", cacheName: nil)
        fetchResultsController.delegate = self
        return fetchResultsController
    }()
    
    
    
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
        }
    }
    
    func reloadData() {
        self.tableView.reloadData()
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        if let items = self.fetchedResultsController.fetchedObjects as? [BridgeItem] {
            self.mapView.addAnnotations(items)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do {
            try self.fetchedResultsController.performFetch()
            if self.fetchedResultsController.fetchedObjects?.count == 0 {
                self.performSegueWithIdentifier("toRegion", sender: nil)
            }
            self.reloadData()
        } catch { }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showMap = false
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if (authorizationStatus == CLAuthorizationStatus.NotDetermined) {
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.startUpdatingLocation()
        
        
        
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
        
        if let vc = segue.destinationViewController as? DetailViewController, detail = sender as? BridgeItem{
            vc.detail = detail
        }
    }
    
    
    @IBAction func displayTypeChanged(sender: UISegmentedControl) {
        // map/tableview
        self.showMap = sender.selectedSegmentIndex == 0
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
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let sectionInfo = self.fetchedResultsController.sections?[section]
            where sectionInfo.numberOfObjects > 0,
            let item = sectionInfo.objects?.first as? BridgeItem{
            
            return item.region.title
        } else {
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        guard let
            item = self.fetchedResultsController.objectAtIndexPath(indexPath) as? BridgeItem
            else {
                return cell
        }
        
        var distanceString: String?
        
        if item.latitude > 0 && item.longitude > 0 {
            let location = CLLocation(latitude: item.latitude, longitude: item.longitude)
            if let distance = self.locationManager.location?.distanceFromLocation(location) {
                distanceString = "\(distance) m"
                if distance > 1000 {
                    distanceString = "\(String(format: "%.2f",distance / 1000)) km"
                }
            }
        }
        cell.textLabel?.text        = item.title
        cell.detailTextLabel?.text  = "\( distanceString != nil ? "[\(distanceString!)]" : "") \(item.subtitle)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let
            item = self.fetchedResultsController.objectAtIndexPath(indexPath) as? BridgeItem
            else {
                return
        }
        self.performSegueWithIdentifier("toDetail", sender: item)
    }
    
    //MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? BridgeItem {
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
        if let annotation = view.annotation as? BridgeItem {
            self.performSegueWithIdentifier("toDetail", sender: annotation)
        }
    }
    
    //MARK: actions
    @IBAction func action(sender: AnyObject) {
        
    }
    //MARK: NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.reloadData()
        
        /*
         var items = [BridgeItem]() {
         willSet {
         self.mapView.resignFirstResponder()
         self.mapView.removeAnnotations(self.mapView.annotations)
         }
         didSet {
         self.tableView.reloadData()
         
         self.mapView.addAnnotations(items)
         self.mapView.reloadInputViews()
         
         if let coor = items.first?.coordinate {
         self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(coor, 10000, 10000), animated: true)
         }
         }
         }
         */
        
    }
//MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        self.tableView.reloadData()
    }
}
