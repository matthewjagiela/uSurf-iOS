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
    var fetchedResultsController: NSFetchedResultsController<Tab>?
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
    
    
    fileprivate func fetch() {
        let tabFetch = NSFetchRequest<Tab>(entityName: "Tab")
        let sortDescription = NSSortDescriptor(key: "webName",
                                               ascending: true)
        tabFetch.sortDescriptors = [sortDescription]
        if let managedContext {
            self.fetchedResultsController = NSFetchedResultsController<Tab>(fetchRequest: tabFetch, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
            self.fetchedResultsController?.delegate = self
        }
    }
    
    func getTabData() -> [TabData] {
        do {
            fetch()
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        if let tabs = fetchedResultsController?.fetchedObjects {
            return tabs.map({ tab in
                guard let name = tab.webName,
                        let url = tab.webURL,
                        let image = tab.image,
                        let identifier = tab.identifier
                else { return TabData(name: "uApps",
                                      url: "http://uAppsios.com",
                                      image: Data())
                    
                }
                return TabData(name: name,
                               url: url,
                               image: image,
                               identifier: identifier)
            })
        }
        
        return [TabData]()
    }
    
    func getTab(from data: TabData) -> Tab? {
        do {
            fetch()
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        if let tabs = fetchedResultsController?.fetchedObjects {
            return tabs.first { tab in
                tab.identifier == data.identifier
            }
        }
        return nil
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
        guard let tab = getTab(from: data) else { return }
        if let context = managedContext{
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
}


extension CoreDataHandler: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //take the table view and refresh it (tabs)
        TableDelegate?.updateTable()
    }
}
