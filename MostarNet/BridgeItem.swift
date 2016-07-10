//
//  Bridge.swift
//  MostarNet
//
//  Created by Jakub Dubrovsky on 06/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreSpotlight
import MobileCoreServices

class BridgeItemGeoJSON: NSObject, MKAnnotation {
    
    let id      : Int
    var title   : String?
    var subtitle   : String?
    var imageThumb   : UIImage?
    var coordinate: CLLocationCoordinate2D
    
    var url     : String {
        return "http://mosty.mostar.cz/out/obj/\(id).html"
    }
    
    init(id: Int, title: String, latitude: Float, longitude: Float, subtitle: String, thumbBase64: String?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        
        self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        super.init()
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        attributeSet.title = title
        attributeSet.displayName = title
        //attributeSet.contentDescription = "iOS-9-Sampler is a code example collection for new features of iOS 9."
        attributeSet.keywords = ["most"]
        
        if let thumbBase64 = thumbBase64,
            data = NSData(base64EncodedString: thumbBase64, options: NSDataBase64DecodingOptions(rawValue: 0)),
            image = UIImage(data: data)
        {
            self.imageThumb = image
            let dataImage = UIImageJPEGRepresentation(image, 2.0)
            attributeSet.thumbnailData = dataImage
        }
        
        //let image = UIImage(named: "m7")!
        //let data = UIImagePNGRepresentation(image)
        //attributeSet.thumbnailData = data
        attributeSet.contentDescription = subtitle
        attributeSet.supportsNavigation = true
        attributeSet.latitude = latitude
        attributeSet.longitude = longitude
        attributeSet.contentURL = NSURL(string: self.url)
        attributeSet.namedLocation = title
        attributeSet.city = subtitle
        
        
        var searchableItem = CSSearchableItem(
            uniqueIdentifier: "cz.mostar.obj.\(id)",
            domainIdentifier: "cz.mostar",
            attributeSet: attributeSet)
        
        //searchableItem.
        
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([searchableItem]) { (error) -> Void in
            if error != nil {
                print("failed with error:\(error)\n")
            }
            else {
                print("Indexed!\n")
            }
        }
        
        
    }
    
    static func bridge(data: [String : AnyObject]) throws -> BridgeItemGeoJSON {
        guard let
            properties = data["properties"] as? [String : AnyObject],
            geometry = data["geometry"] as? [String : AnyObject],
            coordinates = geometry["coordinates"] as? [Float],
            id = properties["id"] as? Int,
            title = properties["title"] as? String,
            subtitle = properties["subtitle"] as? String,
            latitude = coordinates[1] as? Float,
            longitude = coordinates[0] as? Float
            else {
                throw NSError(domain: "", code: 404, userInfo: nil)
        }
        
        let thumbBase64 = properties["thumb"] as? String
        
        return BridgeItemGeoJSON(id: id, title: title, latitude: latitude, longitude: longitude, subtitle: subtitle, thumbBase64:thumbBase64)
        
    }
    
    static func fetchItems(byRegion: String, completionHandler: (items: [BridgeItemGeoJSON]) -> ()) {
        
        
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var dataTask: NSURLSessionTask?
        
        let url = NSURL(string: "http://mosty.mostar.cz/out/geojson/\(byRegion).json")!
        //let request = NSURLRequest(URL: url)
        
        dataTask = defaultSession.dataTaskWithURL(url, completionHandler: { (data, response, error) in
            if let error = error {
                completionHandler(items: [])
            }
            guard let
                data            = data,
                json            = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String : AnyObject],
                features  = json["features"] as? [[String : AnyObject]]
                else {
                    completionHandler(items: [])
                    return
            }
            var items = [BridgeItemGeoJSON]()
            for  feature in features {
                do {
                    let item = try BridgeItemGeoJSON.bridge(feature)
                    items.append(item)
                } catch {
                    
                }
                
                
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(items: items)
            })
            
        })
        dataTask?.resume()
    }
    
}
