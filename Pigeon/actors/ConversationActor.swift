//
//  ContactManagerActor.swift
//  Pigeon
//
//  Created by Oveys Safarnejad on 3/12/19.
//  Copyright © 2019 Safarnejad. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ConversationActor {
    
    
    var conversations : ConversationMapping?
    
    func createOrUpdateConversationList(chatListBares : [String]){
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        for bare in chatListBares {
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
            
            do {
                var fetchedContacts = try context.fetch(fetchRequest)
                
                for fetched in fetchedContacts {
                    
                    print(fetched.value(forKey: "username"))
                    
                }
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
        }
    }
}
