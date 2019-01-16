//
//  ManagedObject+Extension.swift
//  EasyCoreStackBar
//
//  Created by Yoon Lee on 1/15/19.
//  Copyright © 2019 Yoon Lee. All rights reserved.
//

import UIKit
import CoreData

extension NSManagedObject {
    class func create(moc: NSManagedObjectContext = CoreDataStack.shared.mainManagedObjectContext) -> NSManagedObject {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: String(describing: nameOfClass), into: moc)
        
        return managedObject
    }
}

extension NSManagedObject {
    class func findFirst(queryStmt: [String: Any]? = nil, moc: NSManagedObjectContext = CoreDataStack.shared.mainManagedObjectContext) -> NSManagedObject? {
        let result = fetchRequest(queryStmt: queryStmt, fetchLimit: 1, inContext: moc)
        if let result = result {
            if result.count == 1 {
                return result.first
            }
        }
        
        return nil
    }
    
    class func findAll(queryStmt: [String: Any]? = nil, moc: NSManagedObjectContext = CoreDataStack.shared.mainManagedObjectContext) -> [NSManagedObject]? {
        let result = fetchRequest(queryStmt: queryStmt, inContext: moc)
        if let result = result {
            return result
        }
        
        return nil
    }
}

extension NSManagedObject {
    class func numOfEntities(queryStmt: [String: Any]? = nil, moc: NSManagedObjectContext = CoreDataStack.shared.mainManagedObjectContext) -> Int? {
        return fetchRequestCount(queryStmt: queryStmt, inContext: moc)
    }
}

extension NSManagedObject {
    class func fetchRequest(queryStmt: [String: Any]?, fetchLimit: Int = 0, inContext: NSManagedObjectContext) -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: nameOfClass)
        fetchRequest.fetchLimit = fetchLimit
        // scanner for predicate
        if let queryStmt = queryStmt {
            let compoundPredicate = self.buildCompoundPredicate(queryStmt: queryStmt)
            fetchRequest.predicate = compoundPredicate
        }
        
        do {
            // execute the fetch requext
            let result = try inContext.fetch(fetchRequest)
            return result as? [NSManagedObject]
        } catch {
            let fatalStmt = error as Error
            print(fatalStmt)
            return nil
        }
    }
    
    class func fetchRequestCount(queryStmt: [String: Any]?, inContext: NSManagedObjectContext) -> Int? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: nameOfClass)
        // scanner for predicate
        if let queryStmt = queryStmt {
            let compoundPredicate = self.buildCompoundPredicate(queryStmt: queryStmt)
            fetchRequest.predicate = compoundPredicate
        }
        
        do {
            // execute the fetch requext
            let numOfEntities = try inContext.count(for: fetchRequest)
            return numOfEntities
        } catch {
            let fatalStmt = error as Error
            print(fatalStmt)
            return nil
        }
    }
}

extension NSManagedObject {
    class func buildCompoundPredicate(queryStmt: [String: Any]) -> NSCompoundPredicate? {
        var predicates: [NSPredicate] = [NSPredicate]()
        
        for (key, value) in queryStmt {
            // append
            if value is Array<String> {
                
            } else if value is String {
                if let value = value as? String {
                    // same attribute but `AND` search
                    //                    var filteredStmt = value
                    // TODO: below will be implement for the future
                    // before even approach possible inclusive attribute search,
                    // we need to figure out the `&` through split separate by method in Array
                    //                    if value.hasPrefix("&") {
                    //                        // filteredStmt.append(contentsOf: <#T##String#>)
                    //                    } /* same attribute but `AND` search */else if value.hasPrefix("|") {
                    //                        // filteredStmt.append(contentsOf: <#T##String#>)
                    //                    }
                    let predicate = NSPredicate(format: "%K = %@", key, value)
                    predicates.append(predicate)
                }
            } else if value is Int {
                
            }
        }
        
        let compoundPredicates = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        return compoundPredicates
    }
}
