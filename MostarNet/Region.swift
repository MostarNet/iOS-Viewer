//
//  Region.swift
//  MostarNet
//
//  Created by Jakub Dubrovsky on 06/07/16.
//  Copyright © 2016 MostarNet. All rights reserved.
//

import UIKit

class Region: NSObject {
    
    var title: String
    var id: String
    
    init(title: String, id: String) {
        self.title = title
        self.id = id
    }
    
    static func fetchItems(completionHandler: (items: [Region]) -> ()) {
        
        
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var dataTask: NSURLSessionTask?
        
        let url = NSURL(string: "http://mosty.mostar.cz/out/geojson/list.json")!
        //let request = NSURLRequest(URL: url)
        
        dataTask = defaultSession.dataTaskWithURL(url, completionHandler: { (data, response, error) in
            if let error = error {
                completionHandler(items: [])
            }
            guard let
                data            = data,
                json            = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String : String]
                else {
                    completionHandler(items: [])
                    return
            }
            
            var items = [Region]()
            for (code, title) in json {
                let item = Region(title: title, id: code)
                items.append(item)
            }
            
            items = items.sort({ (r1, r2) -> Bool in
               return r1.title < r2.title
            })
            
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(items: items)
            })
        })
        dataTask?.resume()
    }
}
