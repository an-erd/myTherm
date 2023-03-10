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
        newBeacon1.device_name = "Bx0701"
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
        newBeacon1.device_name = "Bx0701"
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
    let viewContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext

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

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            print("\(storeDescription)")
            
            guard let error = error as NSError? else { return }
            fatalError("###\(#function): Failed to load persistent stores:\(error)")
        })
        
//        container.loadPersistentStores(completionHandler: { (_, error) in
//            guard let error = error as NSError? else { return }
//            fatalError("###\(#function): Failed to load persistent stores:\(error)")
//        })
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.transactionAuthor = appTransactionAuthorName
        container.viewContext.automaticallyMergesChangesFromParent = true
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            fatalError("###\(#function): Failed to pin viewContext to the current generation:\(error)")
        }
        
        viewContext = container.viewContext
        
        writeContext = container.newBackgroundContext()
        writeContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        writeContext.undoManager = nil
    }

    /**
     Creates and configures a private queue context.
    */
    func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // Set unused undoManager to nil for macOS (it is nil by default on iOS)
        // to reduce resource requirements.
        taskContext.undoManager = nil
        return taskContext
    }
    
    func saveContext(context: NSManagedObjectContext) {
        print("saveContext")
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
}

//struct PersistentHistoryCleaner {
//
//    let context: NSManagedObjectContext
//    let targets: [AppTarget]
//    let userDefaults: UserDefaults
//
//    /// Cleans up the persistent history by deleting the transactions that have been merged into each target.
//    func clean() throws {
//        guard let timestamp = userDefaults.lastCommonTransactionTimestamp(in: targets) else {
//            print("Cancelling deletions as there is no common transaction timestamp")
//            return
//        }
//
//        let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: timestamp)
//        print("Deleting persistent history using common timestamp \(timestamp)")
//        try context.execute(deleteHistoryRequest)
//
//        targets.forEach { target in
//            /// Reset the dates as we would otherwise end up in an infinite loop.
//            userDefaults.updateLastHistoryTransactionTimestamp(for: target, to: nil)
//        }
//    }
//}
//
