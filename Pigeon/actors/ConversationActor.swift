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
            var sContact = ContactMapping()
            let fetchedContacts = try context.fetch(contactFetchRequest)
            for contact in fetchedContacts {
                
                sContact = createContact(sContact: sContact , contact: contact)
                
                if(sContact.username == bare) {
                    //FIXME:- create or update a conversation
                    
                    let conversationFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Conversation")
                    let predicate = NSPredicate(format: "conversationId == %@", sContact.username)
                    conversationFetchRequest.predicate = predicate
                    let fetchedConversations = try context.fetch(conversationFetchRequest)
                    
                    if fetchedConversations.count != 0 {
                        
                        // Update Existing Conversation
                        print("should update")
                    } else {
                        
                        // Create New Conversation
                        print("should create")
                        var nConversation : ConversationMapping = ConversationMapping()
                        nConversation = createConversation(nConversation: nConversation , contact: sContact)
                        saveConversation(conversation: nConversation)
                        
                    }
                    
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func findMatchedConversation(conversation : NSFetchRequestResult) -> Bool {
        
        
        return false
    }
    
    func createContact(sContact : ContactMapping , contact : NSManagedObject) -> ContactMapping {
        
        sContact.appName = contact.value(forKey: "app_name") as! String
        sContact.mobile = contact.value(forKey: "mobile") as! String
        sContact.contactName = contact.value(forKey: "name") as! String
        sContact.status = contact.value(forKey: "status") as! String
        sContact.username = contact.value(forKey: "username") as! String
        
        return sContact
    }
    
    func createConversation(nConversation : ConversationMapping , contact : ContactMapping) -> ConversationMapping {
        
        nConversation.contact = contact
        nConversation.conversationId = contact.username
//        nConversation.conversationPicture = contact.picture
        nConversation.draftMessage = ""
        nConversation.hiddenConversation = false
        nConversation.isMuted = false
        nConversation.isPinned = false
        nConversation.noMoreMessage = true
        
        
        
        return nConversation
    }
    
    func saveConversation(conversation : ConversationMapping) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let saving = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: context)
        saving.setValue(conversation.conversationId, forKey: "conversationId")
        saving.setValue("", forKey: "conversationPicture")
        saving.setValue(0, forKey: "conversationType")
        saving.setValue("", forKey: "draftMessage")
        saving.setValue(false, forKey: "hiddenConversation")
        saving.setValue(false, forKey: "isMuted")
        saving.setValue(false, forKey: "isPinned")
        saving.setValue("", forKey: "lastMessageId")
        saving.setValue(1, forKey: "lastMessageState")
        saving.setValue("1397/12/28" , forKey: "lastSeenDate")
        saving.setValue("1397/12/28" , forKey: "lastUpdate")
        saving.setValue(true , forKey: "noMoreMessages")
        saving.setValue(1, forKey: "unreadCount")
        
        
        do {
            try context.save()
        } catch {
            print("Error saving: \(error)")
        }
    }
}
