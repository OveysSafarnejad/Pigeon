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
                
                let fetchedContacts = try context.fetch(fetchRequest)
                for fetched in fetchedContacts {
                    
                    let fullUsername = fetched.value(forKey: "username") as! String
                    if(fullUsername == bare) {
                        //FIXME:- create or update a conversation
                        
                    }
                }
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
        }
    }
}
