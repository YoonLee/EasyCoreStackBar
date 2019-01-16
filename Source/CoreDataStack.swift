//
//  CoreDataStack.swift
//  EasyCoreStackBar
//
//  Created by Yoon Lee on 1/15/19.
//  Copyright © 2019 Yoon Lee. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStack {
    static let shared = {
        return CoreDataStack()
    }()
    func initialize() {
        _ = self.savingManagedObjectContext
    }
    
    // managed object model
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "LATrainCommuter", withExtension: "momd") else {
            fatalError("Unable to find a datamodel")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failure to create a Managed Object Model")
        }
        
        return managedObjectModel
    }()
    
    // persistent store coordinator
    private lazy var persistentCoordinator: NSPersistentStoreCoordinator = {
        let persistentCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        // persistent store coordinator settings
        let fileManager = FileManager.default
        let storeName = "LATrainCommuter.sqlite"
        
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            let options = [NSInferMappingModelAutomaticallyOption : true, NSMigratePersistentStoresAutomaticallyOption : true]
            
            try persistentCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                         configurationName: nil,
                                                         at: persistentStoreURL,
                                                         options: options)
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        
        return persistentCoordinator
    }()
    
    // managed object context
    private lazy var savingManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentCoordinator
        print("saving context: \(managedObjectContext)")
        return managedObjectContext
    }()
    
    private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.savingManagedObjectContext
        print("main context: \(managedObjectContext)")
        return managedObjectContext
    }()
    
    func addSubManagedObjectContext() -> NSManagedObjectContext {
        let typeOfManagedObjectContextConcurrencyType: NSManagedObjectContextConcurrencyType = .privateQueueConcurrencyType
        let managedObjectContext = NSManagedObjectContext(concurrencyType: typeOfManagedObjectContextConcurrencyType)
        managedObjectContext.parent = self.mainManagedObjectContext
        
        return managedObjectContext
    }
    
    func saveContext() {
        self.mainManagedObjectContext.performAndWait {
            do {
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save()
                } else { print("Nothing to commit since there is no modification on context (\(self.mainManagedObjectContext))") }
            } catch {
                let invalidSaveError = error as Error
                print("\(invalidSaveError), unable to save the data correctly")
            }
        }
        
        self.savingManagedObjectContext.perform {
            do {
                if self.savingManagedObjectContext.hasChanges {
                    try self.savingManagedObjectContext.save()
                } else { print("Nothing to commit since there is no modification on context (\(self.savingManagedObjectContext.hasChanges))") }
            } catch {
                let invalidSaveError = error as Error
                print("\(invalidSaveError), unable to save the data correctly")
            }
        }
    }
    
    func documentURLPath()-> URL {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Unable to access document folder")
        }
        
        return documentURL
    }
}
