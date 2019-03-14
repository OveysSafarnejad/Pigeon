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
    
    func createOrUpdateConversationList(bare : String){
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let contactFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        do {
            
            let fetchedContacts = try context.fetch(contactFetchRequest)
            for contact in fetchedContacts {
                
                let fullUsername = contact.value(forKey: "username") as! String
                if(fullUsername == bare) {
                    //FIXME:- create or update a conversation
                    
                    let conversationFetchReuest = NSFetchRequest<NSManagedObject>(entityName: "Conversation")
                    let predicate = NSPredicate(format: "contact == %@", fullUsername)
                    conversationFetchReuest.predicate = predicate
                    let fetchedConversations = try context.fetch(conversationFetchReuest)
                    
//                    if fetchedConversations.count != 0 {
//
//                        for conversation in fetchedConversations {
//                            //var contact = conversation.value(forKey: "contact")
//                            if(findMatchedConversation()) {
//                                print("some conversation with this contact exist.")
//                            } else {
//                                print("create new conversation.")
//                            }
//                        }
//                    }
                    
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func findMatchedConversation() -> Bool {
        return false
    }
}
