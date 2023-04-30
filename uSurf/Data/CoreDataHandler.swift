//
//  CoreDataHandler.swift
//  uSurf
//
//  Created by Matthew Jagiela on 1/31/23.
//  Copyright © 2023 Matthew Jagiela. All rights reserved.
//
import UIKit
import Foundation
import CoreData

public class CoreDataHandler: NSObject {
    var managedContext: NSManagedObjectContext?
    weak var appDelegate: AppDelegate?
    weak var TableDelegate: uAppsTableDelegate?
    
    override public init() {
        super.init()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.appDelegate = appDelegate
            self.managedContext = appDelegate.persistentContainer.viewContext
            managedContext?.automaticallyMergesChangesFromParent = true
        } else {
            print("App Delegate is nil")
        }
    }
    
    fileprivate func fetch<T>(entityName: String, sortDescriptor: NSSortDescriptor? = nil) -> NSFetchedResultsController<T>? where T: NSManagedObject {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        } else {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: true)]
        }
        let fetchedResultsController = NSFetchedResultsController<T>(fetchRequest: fetchRequest, managedObjectContext: managedContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getTabData() -> [TabData] {
        let sortDescriptor = NSSortDescriptor(key: "webName", ascending: true)
        guard let controller: NSFetchedResultsController<Tab> = fetch(entityName: "Tab")
        else {
            return []
        }
        
        do {
            try controller.performFetch()
            return controller.fetchedObjects?.compactMap({ tab in
                guard let name = tab.webName,
                      let url = tab.webURL,
                      let image = tab.image,
                      let identifier = tab.identifier
                else {
                    return nil
                }
                
                return TabData(name: name, url: url, image: image, identifier: identifier)
            }) ?? []
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func getTab(withId identifier: UUID) -> Tab? {
        let fetchRequest: NSFetchRequest<Tab> = Tab.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier.uuidString)
        do {
            let result = try managedContext?.fetch(fetchRequest)
            return result?.first
        } catch {
            print("Error fetching tab: \(error.localizedDescription)")
            return nil
        }
    }
    
    func createTab(tabData: TabData) {
        guard let managedContext else { return }
        let tabInsert = NSEntityDescription.insertNewObject(forEntityName: "Tab", into: managedContext) as? Tab
        tabInsert?.identifier = tabData.identifier
        tabInsert?.webName = tabData.name
        tabInsert?.webURL = tabData.url
        tabInsert?.image = tabData.image
        do {
            try managedContext.save()
        } catch {
            print("MANAGED CONTEXT CANNOT SAVE \(error)")
        }
    }
    
    func deleteTab(data: TabData) {
        guard let tab = getTab(withId: data.identifier) else { return }
        if let context = managedContext {
            context.delete(tab)
            do {
                try context.save()
            } catch {
                print("Error deleting Tab \(error)")
            }
        }
    }
    
    func deleteTabs(tabs: [TabData], completion: @escaping (Error?) -> Void) {
        guard let context = managedContext else { return }
        let identifiers = tabs.map { $0.identifier }
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Tab.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiers)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func deleteAllTabs(completion: @escaping (Error?) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tab")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext?.execute(deleteRequest)
            completion(nil)
        } catch let error as NSError {
            print("Error deleting all data: \(error)")
            completion(error)
        }
    }
}

extension CoreDataHandler: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // take the table view and refresh it (tabs)
        TableDelegate?.updateTable()
    }
}
