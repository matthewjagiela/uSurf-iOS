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

enum CoreDataErrors: Error {
    case nilError
}

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
    // MARK: - Generic Fetch
    fileprivate func fetch<T>(entityName: String, sortDescriptor: NSSortDescriptor? = nil) -> NSFetchedResultsController<T>? where T: NSManagedObject {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        } else {
            let defaultSortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
            fetchRequest.sortDescriptors = [defaultSortDescriptor]
        }
        guard let managedContext = managedContext else { return nil }
        let fetchedResultsController = NSFetchedResultsController<T>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // MARK: - Tab Info
    // MARK: Get Tab Data
    func getTabData() -> [TabData] {
        let sortDescriptor = NSSortDescriptor(key: "webName", ascending: true)
        guard let controller: NSFetchedResultsController<Tab> = fetch(entityName: "Tab", sortDescriptor: sortDescriptor)
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
    
    // MARK: Create Tab Data
    func createTab(tabData: TabData) {
        // TODO: Change to throw error
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
    
    // MARK: Delete Tab Data
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
    
    // MARK: - Bookmark Operations
    // MARK: Creation
    func createBookmark(from bookmarkData: BookmarkData) throws {
        guard let managedContext else { throw CoreDataErrors.nilError }
        let bookmarkInsert = NSEntityDescription.insertNewObject(forEntityName: "Bookmark", into: managedContext) as? Bookmark
        bookmarkInsert?.identifier = bookmarkData.identifier
        bookmarkInsert?.webURL = bookmarkData.url
        bookmarkInsert?.nickname = bookmarkData.name
        try managedContext.save()
        
    }
    // MARK: Getting
    /// Get all bookmark data from CoreData + CloudKit
    func getBookmarkData() throws -> [BookmarkData] {
        let sortDescriptor = NSSortDescriptor(key: "nickname", ascending: true)
        guard let controller: NSFetchedResultsController<Bookmark> = fetch(entityName: "Bookmark", sortDescriptor: sortDescriptor) else { return []}
        try controller.performFetch()
        return controller.fetchedObjects?.compactMap({ bookmark in
            guard let name = bookmark.nickname,
                    let url = bookmark.webURL,
                    let identifier = bookmark.identifier
            else { return nil }
            return BookmarkData(name: name, url: url, identifier: identifier)
        }) ?? []
    }
    
    func getBookmark(withID identifier: UUID) throws -> Bookmark? {
        let fetchRequest: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier.uuidString)
        let result = try managedContext?.fetch(fetchRequest)
        return result?.first
    }
    
    
    // MARK: Deletion
    func deleteBookmark(from data: BookmarkData) throws {
        guard let bookmark = try getBookmark(withID: data.identifier),
        let managedContext = managedContext
        else { throw CoreDataErrors.nilError }
        managedContext.delete(bookmark)
        try managedContext.save()
        
    }
    
    func deleteBookmarks(bookmarks: [BookmarkData]) throws {
        guard let managedContext = managedContext else { throw CoreDataErrors.nilError }
        let identifiers = bookmarks.map { $0.identifier }
        let fetchReqeust: NSFetchRequest<NSFetchRequestResult> = Bookmark.fetchRequest()
        fetchReqeust.predicate = NSPredicate(format: "identifier IN %@", identifiers)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchReqeust)
        try managedContext.execute(batchDeleteRequest)
        try managedContext.save()
    }
    
    func deleteAllBookmarks(completion: @escaping() -> Void) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmark")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try managedContext?.execute(deleteRequest)
    }
}

// MARK: - Extensions
extension CoreDataHandler: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // take the table view and refresh it (tabs)
        TableDelegate?.updateTable()
    }
}
