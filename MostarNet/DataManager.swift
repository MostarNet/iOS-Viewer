

import CoreData

//TODO: main/bg thread http://code.tutsplus.com/tutorials/core-data-from-scratch-concurrency--cms-22131

private let _SharedInstanceDataManager = DataManager()

extension NSManagedObject {
    class func entityName() -> String {
        let fullClassName = NSStringFromClass(object_getClass(self))
        let nameComponents = fullClassName.componentsSeparatedByString(".").last
        return nameComponents!
    }
}

class DataManager {
    
    class var sharedInstance : DataManager {
        return _SharedInstanceDataManager
    }
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        //    return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.yourdomain.YourAwesomeGroup") ?? nil
        
        guard let container = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.cz.csas.inno.test")  else {
            print("err")
            abort()
        }
        
        let modelURL = NSBundle.mainBundle().URLForResource("MostarNet", withExtension: "momd")
        let mom = NSManagedObjectModel(contentsOfURL: modelURL!)
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom!)
        
        let storeURL = container.URLByAppendingPathComponent("MostarNet.sqlite")
        
        var error: NSError? = nil
        do {
            
            defer {
                //zavru
                
            }
            var store = try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            //  var store1 = try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            
        } catch {
            
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        return managedObjectContext
    }()
    
    
    
    func createEntityWithName(entityName:String, idParam:String, idValue: AnyObject) -> AnyObject {
        
        var temp:AnyObject!
        
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: entityName)
        
        if let idValueString = idValue as? String  {
            fetchRequest.predicate = NSPredicate(format: "%K == %@", idParam, idValueString)
            
            
            do {
                let items = try self.managedObjectContext.executeFetchRequest(fetchRequest)
                
                if items.count>0 {
                    let retval:AnyObject = items[0] as AnyObject
                    return retval
                    
                }
            } catch {
            }
            
            temp = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self.managedObjectContext)
            
            
            temp.setValue(idValueString, forKey: idParam)
            
            
            
        } else if let idValueInt = idValue as? Int {
            fetchRequest.predicate = NSPredicate(format: "%K == %d", idParam, idValueInt)
            
            do {
                let items = try self.managedObjectContext.executeFetchRequest(fetchRequest)
                
                if items.count>0 {
                    let retval:AnyObject = items[0] as AnyObject
                    return retval
                    
                }
            } catch {
                
            }
            
            temp = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self.managedObjectContext)
            temp.setValue(idValueInt, forKey: idParam)
        }
        
        return temp
    }
    
    
    
    func saveContext () {
        
        if !managedObjectContext.hasChanges {
            return
        }
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError  {
            print("Error saving context: \(error.localizedDescription)\n\(error.userInfo)")
        }
    }
    
    
}