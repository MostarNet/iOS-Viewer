//
//  Bridge.swift
//  MostarNet
//
//  Created by Jakub Dubrovsky on 06/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
//

import UIKit

import CoreData

import CoreLocation
import MapKit

import CoreSpotlight
import MobileCoreServices

class BridgeItem: NSManagedObject, MKAnnotation, UIActivityItemSource {
    
    @NSManaged var id           : UInt16
    @NSManaged var title        : String!
    @NSManaged var subtitle     : String!
    @NSManaged private var photo        : String?
    @NSManaged var imageThumb   : UIImage?
    @NSManaged var latitude     : Double
    @NSManaged var longitude    : Double
    @NSManaged var region       : Region
    
    var photoURL : NSURL? {
        if let photo = self.photo {
            let url = NSURL(string: "http://mosty.mostar.cz/data/foto/vse/\(photo)")!
            return url
        }
        return nil
    }
    
    func distanceFromLocation(location: CLLocation) -> CLLocationDistance {
        let locationItem = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return locationItem.distanceFromLocation(location)
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        }
    }
    
    static var domainIdentifier = "cz.mostar.object"
    
    var url     : String {
        return "http://mosty.mostar.cz/out/obj/\(id).html"
    }
    
    
    static func item(id: Int) -> BridgeItem{
        let item = DataManager.sharedInstance.createEntityWithName(self.entityName(), idParam: "id", idValue: id) as? BridgeItem
        return item!
    }
    
    func populate(geojson data: [String : AnyObject]) throws {
        
        guard let
            properties      = data["properties"] as? [String : AnyObject],
            geometry        = data["geometry"] as? [String : AnyObject],
            coordinates     = geometry["coordinates"] as? [Double] where coordinates.count > 1,
            let
            id          = properties["id"] as? Int,
            title       = properties["title"] as? String,
            subtitle    = properties["subtitle"] as? String,
            photo       = properties["photo"] as? String
            else {
                throw NSError(domain: "", code: 404, userInfo: nil)
        }
        
        self.latitude    = coordinates[1]
        self.longitude   = coordinates[0]
        
        if let
            thumbBase64 = properties["thumb"] as? String,
            data        = NSData(base64EncodedString: thumbBase64, options: NSDataBase64DecodingOptions(rawValue: 0)),
            image       = UIImage(data: data) {
            self.imageThumb = image
        }
        
        self.id         = UInt16(id)
        self.title      = title
        self.subtitle   = subtitle
        self.photo = photo
    }
    
    func searchableItem() -> CSSearchableItem {
        let attributeSet            = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        attributeSet.title          = self.title
        attributeSet.displayName    = self.title
        attributeSet.keywords       = ["most"]
        attributeSet.downloadedDate = NSDate()
        
        if let image = self.imageThumb {
            let dataImage = UIImageJPEGRepresentation(image, 2.0)
            attributeSet.thumbnailData = dataImage
        }
        
        attributeSet.contentDescription = self.subtitle
        attributeSet.supportsNavigation = true
        attributeSet.latitude           = self.coordinate.latitude
        attributeSet.longitude          = self.coordinate.longitude
        attributeSet.contentURL         = NSURL(string: self.url)
        attributeSet.namedLocation      = self.title
        attributeSet.city               = self.subtitle
        
        let searchableItem = CSSearchableItem(
            uniqueIdentifier:   String(self.id),
            domainIdentifier:   BridgeItem.domainIdentifier,
            attributeSet:       attributeSet)
        
        
        return searchableItem
    }
    
    
    //MARK: UIActivityItemProvider
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        return NSURL(string: self.url)
    }
    
    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        return self.title ?? ""
    }
    
    func activityViewController(activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: String?, suggestedSize size: CGSize) -> UIImage? {
        return self.imageThumb
    }
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return ""
    }
    
}
