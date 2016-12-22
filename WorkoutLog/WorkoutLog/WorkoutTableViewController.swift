//
//  WorkoutTableViewController.swift
//  WorkoutLog
//
//  Created by Annie Tung on 12/22/16.
//  Copyright © 2016 Annie Tung. All rights reserved.
//

import UIKit
import CoreData

class WorkoutTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var fetchResultsController: NSFetchedResultsController<Entry>!
//    lazy var exerciseView: Exercise = {
//        let exercise = Exercise(exercise: "squat")
//        exercise.translatesAutoresizingMaskIntoConstraints = false
//        return exercise
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 75
        self.title = "Work Out Log 🏋🏻"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.leftBarButtonItem = editButtonItem
        saveToCoreData()
        initializeFetchRequestController()
    }
    
    // MARK: - Core Date
    
    func saveToCoreData() {
        let savingMOC = (UIApplication.shared.delegate as! AppDelegate).dataController.privateContext
        savingMOC.performAndWait {
            do {
                let object = Entry(context: savingMOC)
                object.date = NSDate()
                try savingMOC.save()
                
                savingMOC.parent?.performAndWait {
                    do {
                        try savingMOC.parent?.save()
                    } catch {
                        print("Error saving to parent: \(error)")
                    }
                }
            }
            catch {
                print("Error saving to child: \(error)")
            }
        }
    }
    
    func initializeFetchRequestController() {
        
        let fetchingMOC = (UIApplication.shared.delegate as! AppDelegate).dataController.managedObjectContext
        
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: fetchingMOC, sectionNameKeyPath: #keyPath(Entry.sectionName), cacheName: nil)
        fetchResultsController.delegate = self
        do {
            try fetchResultsController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }
    }
    
    // MARK: - TableView data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchResultsController.sections else {
            print("No sections in fetch results controller in num of section")
            return 0
        }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchResultsController.sections,
            section < sections.count,
            let workout = sections[section].objects else {
                print("No sections in fetch results controller in num of rows in section")
                return 0
        }
        return workout.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
        
        cell.textLabel?.text = fetchResultsController.object(at: indexPath).dateString.map { "💪🏼 \($0)" }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchResultsController.sections else {
            print("No title for header in section")
            return nil
        }
        return Entry.sectionTitle(for: sections[section].name)
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let workout = fetchResultsController.object(at: indexPath)
            let managedObjContext = (UIApplication.shared.delegate as! AppDelegate).dataController.managedObjectContext
            managedObjContext.delete(workout)
            do {
                try managedObjContext.save()
            } catch {
                print("Error deleting context")
            }
        default:
            break
        }
    }
    
    // MARK: - Methods
    
    func addButtonTapped() {
        let managedObjContext = (UIApplication.shared.delegate as! AppDelegate).dataController.managedObjectContext
        let workout = Entry(context: managedObjContext)
        workout.date = NSDate()
        do {
            try managedObjContext.save()
        } catch {
            print("Error saving to managed Object Context")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .update:
            tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
