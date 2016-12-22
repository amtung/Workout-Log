//
//  DataController.swift
//  CoreDataDemo
//
//  Created by Annie Tung on 12/20/16.
//  Copyright © 2016 Annie Tung. All rights reserved.
//

import Foundation
import CoreData /// Use coredata framework

class DataController: NSObject {
    var managedObjectContext: NSManagedObjectContext
    
    override init() {
        
        guard let modelURL = Bundle.main.url(forResource: "Workout", withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        
        //location of the file where we save stuff
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from :\(modelURL)")
        }
        
        //Manager that takes care of storing data, updating
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        //Setting the NSManagedObjectedContext where it is the actual object
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        //Need to know which is the language
        //File contains the rules of the language
        //Use this language to query the data
        
        //DispatchQueue.main.async {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls.last!
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.appendingPathComponent("Workout.sql")
        do {
            //Set the rule of sql of the fetch request
            //It needs certain laguange to process, this is all the address of all the rules
            //If you don't don't find the rules, throw an error
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        // }
    }
    
    // should be called from the thread using the private context
    var privateContext: NSManagedObjectContext {
        get {
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.parent = managedObjectContext
            privateContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return privateContext
        }
    }
}
