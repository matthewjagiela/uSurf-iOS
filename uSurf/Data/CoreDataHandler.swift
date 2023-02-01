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
}
