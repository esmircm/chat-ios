//
//  CloudKitHelper.swift
//  TsaChat1819
//
//  Created by Marro Gros Gabriel on 25/01/2019.
//  Copyright © 2019 Marro Gros Gabriel. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

struct CloudKitHelper {
    
    static var downloading = false
    
    static let LastDateKey = "LAST_MESSAGE_DATE"
    
    static func myName(_ completion:@escaping (String?)->Void) {
        
        let container = CKContainer.default()
        container.fetchUserRecordID { (recordID, error) in
            guard error == nil , recordID != nil else {
                completion(nil)
                return
            }
            
            completion(recordID?.recordName)
        }
    }
    
    
    static func downloadMessages(from: Date?, in context: NSManagedObjectContext, _ completion: @escaping (Date?)->Void) {
        
        guard !downloading else {
            
            completion(nil)
            return
            
        }
        
        var lastDate: Date? = nil
        
        let container = CKContainer.default()
        let db = container.publicCloudDatabase
        
        let predicate: NSPredicate
        if let date = from {
            predicate = NSPredicate(format: "creationDate > %@", date as NSDate)
        } else {
            predicate = NSPredicate(value: true)
        }
        
        let tempContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        tempContext.parent = context
        
        let query = CKQuery(recordType: "Messages", predicate: predicate)
        query.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true)]
        
        func perRecord(_ record: CKRecord) {
            
            lastDate = record.creationDate
            
            tempContext.perform {
                
                let recordCode = record.recordID.recordName
                
                let req = NSFetchRequest(entityName: "Message") as NSFetchRequest<Message>
                req.predicate = NSPredicate(format: "recordName == %@", recordCode)
                
                guard let results = try? tempContext.fetch(req), results.isEmpty else {
                    return
                }
                
                let newMessage = NSEntityDescription.insertNewObject(forEntityName: "Message",
                                                                     into: tempContext) as! Message
                
                if let text = record["text"] as? NSString {
                    newMessage.text = text as String
                }
                
                newMessage.userCode = record.creatorUserRecordID?.recordName
                newMessage.date = record.creationDate
            }
        }
        
        func completionBlock(cursor: CKQueryOperation.Cursor?, error: Error?) {
            
            tempContext.perform {
                try? tempContext.save()
                if let parent = tempContext.parent {
                    parent.perform {
                        try? parent.save()
                    }
                }
            }
            
            if cursor != nil {
                let newOp = CKQueryOperation(cursor: cursor!)
                newOp.recordFetchedBlock = perRecord
                newOp.queryCompletionBlock = completionBlock
                db.add(newOp)
            } else {
                downloading = false
                completion(lastDate)
            }
        }
        
        let queryOp = CKQueryOperation(query: query)
        queryOp.recordFetchedBlock = perRecord
        queryOp.queryCompletionBlock = completionBlock
        downloading = true
        db.add(queryOp)
    }
    
    
    static func sendMessage(_ text: String, in context: NSManagedObjectContext, completion: (Bool)->Void) {
        
        let message = CKRecord(recordType: "Messages")
        message["text"] = text as NSString
        
        let db = CKContainer.default().publicCloudDatabase
        
        db.save(message) { (record, error) in
            guard error == nil, record != nil else {
                return
            }
            
            context.perform {
                let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
                message.text = text
                message.userCode = record!.creatorUserRecordID?.recordName
                message.date = record!.creationDate
                message.recordName = record?.recordID.recordName
                try? context.save()
            }
        }
    }
    
    static func checkForSubscription(){
        
        let db = CKContainer.default().publicCloudDatabase
        
        db.fetchAllSubscriptions { (subscription, error) in
            guard error == nil, subscription != nil else { return }
            
            if subscription!.isEmpty{
                
                let options:CKQuerySubscription.Options
                options = [.firesOnRecordCreation]
                 // TODO: saber el with del usuario para que cuando escribas un msg no te llegue una propia notificacion
                
                let predicate = NSPredicate(value: true)
                
                let subscription = CKQuerySubscription(recordType: "Messages",
                                                       predicate: predicate,
                                                       subscriptionID: "NEW_MESSAGE",
                                                       options: options)
                
                let info = CKQuerySubscription.NotificationInfo()
                info.soundName = "chan.aiff"
                info.alertBody = "Nuevo mensaje"
                
                
                subscription.notificationInfo = info
                db.save(subscription, completionHandler: { (subscription, error) in
                    debugPrint("EROR GUARDANDO SUBSCRIPCION")
                })
                
            }
        }
        
    }
    
}
