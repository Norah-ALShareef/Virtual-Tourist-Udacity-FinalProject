
import Foundation
import CoreData

class DataController {
    
    static let sharedDataController = DataController()
    
    let persistentContainer = NSPersistentContainer(name: "VirtualTourist")
    
    var viewContext: NSManagedObjectContext{
        
        return persistentContainer.viewContext
    }
    
    // helps us to load data when running the app after trmniting it
    func load() {
        persistentContainer.loadPersistentStores { (storeDiscription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
    }
}

