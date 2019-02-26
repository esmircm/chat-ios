//
//  MeMessagesHelper.swift
//  TsaChat1819
//
//  Created by Milan Kokic on 18/02/2019.
//  Copyright © 2019 Marro Gros Gabriel. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class MeMessageHelper : CloudKitHelperProtocol {
    
    static var downloading = false
    
    static let LastDateKey = "LAST_MESSAGE_DATE"
    
    let meMessageLocaldatabaseHelper : MeMessageLocalDatabaseHelper?
    
    init() {
        meMessageLocaldatabaseHelper = MeMessageLocalDatabaseHelper()
    }
    
    func sendMessage(_ text: String, in context: NSManagedObjectContext, completion: (Bool) -> Void) {
        let message = CKRecord(recordType: "MeMessages")
        message["text"] = text as NSString
        message["messageType"] = "text_message" as NSString
        
        let db = CKContainer.default().publicCloudDatabase
        
        db.save(message) { [weak self] (record, error) in
            
            guard error == nil, record != nil else {
                return
            }
            
            if let record = record {
                self?.meMessageLocaldatabaseHelper?.insertNewMessage(context: context, record: record, text: text)
            }
        }
    }
    
    func myName(_ completion: @escaping (String?) -> Void) {
        
        let container = CKContainer.default()
        container.fetchUserRecordID { (recordID, error) in
            guard error == nil , recordID != nil else {
                completion(nil)
                return
            }
            
            completion(recordID?.recordName)
        }
    }
    
    func downloadMessages(from: Date?, in context: NSManagedObjectContext, _ completion: @escaping (Date?) -> Void) {
        
        guard !MeMessageHelper.downloading else {
            
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
        
        let query = CKQuery(recordType: "MEMessages", predicate: predicate)
        query.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true)]
        
        func perRecord(_ record: CKRecord) {
            
            lastDate = record.creationDate
            
            meMessageLocaldatabaseHelper?.insertMessagePerRecord(tempContext: tempContext, record: record)
        }
        
        func completionBlock(cursor: CKQueryOperation.Cursor?, error: Error?) {
            
            meMessageLocaldatabaseHelper?.saveContext(tempContext: tempContext)
            
            if cursor != nil {
                let newOp = CKQueryOperation(cursor: cursor!)
                newOp.recordFetchedBlock = perRecord
                newOp.queryCompletionBlock = completionBlock
                db.add(newOp)
            } else {
                MeMessageHelper.downloading = false
                completion(lastDate)
            }
        }
        
        let queryOp = CKQueryOperation(query: query)
        queryOp.recordFetchedBlock = perRecord
        queryOp.queryCompletionBlock = completionBlock
        MeMessageHelper.downloading = true
        db.add(queryOp)
    }
    
    func sendImageMessage(fileUrl: URL, in context: NSManagedObjectContext, completion: (Bool) -> Void) {
        let asset = CKAsset(fileURL: fileUrl)
        let message = CKRecord(recordType: "MEMessages")
        message["asset"] = asset as CKAsset
        message["messageType"] = "image_message" as NSString
        
        let db = CKContainer.default().publicCloudDatabase
        
        db.save(message) { [weak self] (record, error) in
            guard error == nil, record != nil else {
                return
            }
            
            if let record = record {
                self?.meMessageLocaldatabaseHelper?.insertNewImageMessage(context: context, record: record, assetUrl: fileUrl)
            }
            
        }
    }
    
    func checkForSubscription() {
        
        let db = CKContainer.default().publicCloudDatabase
        
        db.fetchAllSubscriptions { (subscription, error) in
            guard error == nil, subscription != nil else { return }
            
            if subscription!.isEmpty{
                
                let options:CKQuerySubscription.Options
                options = [.firesOnRecordCreation]
                // TODO: saber el with del usuario para que cuando escribas un msg no te llegue una propia notificacion
                
                let predicate = NSPredicate(value: true)
                
                let subscription = CKQuerySubscription(recordType: "MEMessages",
                                                       predicate: predicate,
                                                       subscriptionID: "NEW_ME_MESSAGE",
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
    
    func saveUser(context: NSManagedObjectContext, fileUrl: URL?, name: String, photoData: Data?){
        let user = CKRecord(recordType: "MEUser")
        user["name"] = name as NSString
        
        if fileUrl != nil {
            let asset = CKAsset(fileURL: fileUrl!)
            user["photo"] = asset as CKAsset
        }
        
        let db = CKContainer.default().publicCloudDatabase
        meMessageLocaldatabaseHelper?.saveUserInLocalDataBase(context: context, name: name, photoData: photoData)
        
        db.save(user) { (record, error) in
            
            guard error == nil, record != nil else {
                return
            }

        }
    }
    
    func getUser(context: NSManagedObjectContext) -> User? {
        return meMessageLocaldatabaseHelper?.getUser(context: context)
    }
    
    
}






