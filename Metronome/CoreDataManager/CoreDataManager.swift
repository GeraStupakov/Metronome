//
//  CoreDataManager.swift
//  Metronome
//
//  Created by Георгий Ступаков on 12/29/21.
//

import UIKit
import CoreData

struct CoreDataManager {
    
    var firstItems = [TempoItem]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static let shared = CoreDataManager()
    
    private init() { }
    
    func saveTempoItems() {

        do {
            try context.save()
        } catch {
            print("Error save context: \(error)")
        }
    }
    
    func loadTempoItems(array: inout [TempoItem]) {
        
        let request: NSFetchRequest<TempoItem> = TempoItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        
        do {
            array = try context.fetch(request)
        } catch {
            print("Error load context: \(error)")
        }
    }
}
