//
//  Region.swift
//  MostarNet
//
//  Created by Jakub Dubrovsky on 06/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
//

import UIKit

import CoreData

import CoreSpotlight
import MobileCoreServices

class Region: NSManagedObject, UIActivityItemSource {
    
    @NSManaged var title    : String!
    @NSManaged var id       : String!
    
    @NSManaged var downloadedAt : NSDate?
    var isDownloaded: Bool {
        return self.downloadedAt != nil
    }
    
    @NSManaged private var items    : NSSet?
    
    func bridgeItems() -> [BridgeItem] {
        guard let
            items = items?.allObjects as? [BridgeItem]
            else{
                return [BridgeItem]()
        }
        return items
        
    }
    
    static var currentRegion: Region?
    
    static func region(id: String) -> Region {
        let item = DataManager.sharedInstance.createEntityWithName(self.entityName(), idParam: "id", idValue: id) as? Region
        return item!
    }
    
    static func fetchItems(completionHandler: () -> ()) {
        //TODO: clear previous items
        
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var dataTask: NSURLSessionTask?
        
        let url = NSURL(string: "http://mosty.mostar.cz/out/geojson/list.json")!
        
        dataTask = defaultSession.dataTaskWithURL(url, completionHandler: { (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                guard
                    error == nil,
                    let
                    data    = data,
                    json    = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String : String]
                    else {
                        completionHandler()
                        return
                }
                
                for (code, title) in json {
                    let item = Region.region(code)
                    item.title = title
                }
                DataManager.sharedInstance.saveContext()
                
                
                
                completionHandler()
            })
        })
        dataTask?.resume()
    }
    
    func fetchBridgeItems(completionHandler: (items: [BridgeItem]) -> ()) {
        
        
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var dataTask: NSURLSessionTask?
        
        let url = NSURL(string: "http://mosty.mostar.cz/out/geojson/\(self.id).json")!
        
        dataTask = defaultSession.dataTaskWithURL(url, completionHandler: { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                guard
                    error == nil,
                    let
                    data        = data,
                    json        = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String : AnyObject],
                    features    = json["features"] as? [[String : AnyObject]]
                    else {
                        completionHandler(items: [])
                        return
                }
                
                var searchableItems = [CSSearchableItem]()
                for  feature in features {
                    do {
                        guard let
                            properties  = feature["properties"] as? [String : AnyObject],
                            id          = properties["id"] as? Int
                            else { return }
                        
                        let item =  BridgeItem.item(id)
                        try item.populate(geojson: feature)
                        item.region = self
                        searchableItems.append(item.searchableItem())
                    } catch {}
                }
                self.downloadedAt = NSDate()
                DataManager.sharedInstance.saveContext()
                
                CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems) { (error) -> Void in
                    if error != nil {
                        print("failed with error:\(error)\n")
                    }
                    else {
                        print("Indexed!\n")
                    }
                }
                
                
                
                completionHandler(items: [BridgeItem]())
            })
            
        })
        dataTask?.resume()
    }
    
    func clearBridgeItems() {
        var searchableIdentifiers = [String]()
        
        for item in self.bridgeItems() {
            searchableIdentifiers.append(String(item.id))
            DataManager.sharedInstance.managedObjectContext.deleteObject(item)
        }
        CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers(searchableIdentifiers) { (error) in
            print(searchableIdentifiers)
            print(error)
        }
        self.downloadedAt = nil
        DataManager.sharedInstance.saveContext()
        //TODO: projit vsechny polozky a odstranit je i z spotlight
    }
    
    //MARK: UIActivityItemProvider
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        /*
         var blockJSON: ([BridgeItemGeoJSON] -> NSData?) = {
         (items:[BridgeItemGeoJSON]) in
         
         
         var jsonItems = [[String : AnyObject]]()
         for item in items {
         
         let jsonItem = [
         "type": "Feature",
         "properties": [
         "title": item.title,
         "subtitle": item.subtitle
         ],
         "geometry": [
         "type": "Point",
         "coordinates": [
         item.coordinate.longitude,
         item.coordinate.latitude
         ]
         ]
         ]
         jsonItems.append(jsonItem)
         }
         do {
         let json = [
         "type": "FeatureCollection",
         "features": jsonItems
         ]
         return try? NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted)
         } catch {
         return nil
         }
         }
         */
        let block: ([BridgeItem] -> NSData?) = {
            (items:[BridgeItem]) in
            
            
            var xmlItems = ""
            for item in items {
                let xmlItem = "<wpt lon=\"\(item.coordinate.longitude)\" lat=\"\(item.coordinate.latitude)\"><name>\(item.title)</name><desc>\(item.subtitle)</desc></wpt>"
                xmlItems = "\(xmlItems)\(xmlItem)"
            }
            let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><gpx xmlns=\"http://www.topografix.com/GPX/1/1\" version=\"1.1\" creator=\"MostarNet\"><metadata><name>\(self.title)</name></metadata>\(xmlItems)</gpx>"
            return xml.dataUsingEncoding(NSUTF8StringEncoding)
            
        }
        
        
        
        return block(self.bridgeItems())
        
        
    }
    
    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        return self.title ?? ""
    }
    
    func activityViewController(activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: String?) -> String {
        
        return "com.topografix.gpx";
        //return "com.apple.dt.document.geojson";
    }
    
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return ""
    }
}
