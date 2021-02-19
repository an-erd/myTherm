//
//  Persistence.swift
//  myTherm
//
//  Created by Andreas Erdmann on 17.02.21.
//

import CoreData

let appTransactionAuthorName = "app"

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let newBeacon1 = Beacon(context: viewContext)
        newBeacon1.uuid = UUID()
        newBeacon1.name = "Beac1"
        newBeacon1.descr = "Description Beac1"
        newBeacon1.beacon_version = 3
        newBeacon1.company_id = 0x52
        newBeacon1.id_maj = "07"
        newBeacon1.id_min = "01"
        
        let newBeaconAdv1 = BeaconAdv(context: viewContext)
        newBeaconAdv1.temperature = 20.8
        newBeaconAdv1.humidity = 88
        
        newBeacon1.adv = newBeaconAdv1
                
        let newBeacon2 = Beacon(context: viewContext)
        newBeacon2.uuid = UUID()
        newBeacon2.name = "Beac2"
        newBeacon2.descr = "Description Beac2"
        newBeacon2.beacon_version = 3
        newBeacon2.company_id = 0x52
        newBeacon2.id_maj = "07"
        newBeacon2.id_min = "02"
        
        let newBeaconAdv2 = BeaconAdv(context: viewContext)
        newBeaconAdv2.temperature = 23.8
        newBeaconAdv2.humidity = 22
        
        newBeacon2.adv = newBeaconAdv2

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer
    let persistentContainerQueue = OperationQueue()

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "myTherm")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Enable history tracking and remote notifications
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("###\(#function): Failed to load persistent stores:\(error)")
        })
        
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//
//                /*
//                Typical reasons for an error here include:
//                * The parent directory does not exist, cannot be created, or disallows writing.
//                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                * The device is out of space.
//                * The store could not be migrated to the current model version.
//                Check the error message to determine what the actual problem was.
//                */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        persistentContainerQueue.maxConcurrentOperationCount = 1
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.transactionAuthor = appTransactionAuthorName

        // Pin the viewContext to the current generation token and set it to keep itself up to date with local changes.
        container.viewContext.automaticallyMergesChangesFromParent = true
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            fatalError("###\(#function): Failed to pin viewContext to the current generation:\(error)")
        }
            }
    
    

    func saveBackgroundContext(backgroundContext: NSManagedObjectContext) {
        persistentContainerQueue.addOperation(){
            backgroundContext.performAndWait{
                do {
                    //update core data
                try backgroundContext.save()
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
        }
    }

}