//
//  MeMessageLocalDatabaseImplementation.swift
//  TsaChat1819
//
//  Created by Milan Kokic on 18/02/2019.
//  Copyright © 2019 Marro Gros Gabriel. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class MeMessageLocalDatabaseHelper {
    func getUser(context: NSManagedObjectContext) -> User? {
        var user: User?
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                user = data as? User
            }
            
        } catch {
            
            print("Failed")
        }
        
        return user
    }
    
    func insertNewMessage(context : NSManagedObjectContext, record: CKRecord, text: String) {
        context.perform {
            let message = NSEntityDescription.insertNewObject(forEntityName: "MEMessage", into: context) as! MEMessage
            message.text = text
            message.userCode = record.creatorUserRecordID?.recordName
            message.date = record.creationDate
            message.recordName = record.recordID.recordName
            message.messageType = "text_message"
            try? context.save()
        }
    }
    
    func insertNewImageMessage(context: NSManagedObjectContext, record: CKRecord, assetUrl: URL){
        
        context.perform {
            let message = NSEntityDescription.insertNewObject(forEntityName: "MEMessage", into: context) as! MEMessage
            message.userCode = record.creatorUserRecordID?.recordName
            message.date = record.creationDate
            message.recordName = record.recordID.recordName
            let File : CKAsset? = record["asset"]
            
            if let file = File {
                message.assetUrl = self.saveFileToCache(file: file)
            }
            
            message.messageType = "image_message"
            try? context.save()
        }
    }
    
    func insertMessagePerRecord(tempContext: NSManagedObjectContext, record: CKRecord) {
        
        tempContext.perform {
            
            let recordCode = record.recordID.recordName
            
            let req = NSFetchRequest(entityName: "MEMessage") as NSFetchRequest<MEMessage>
            req.predicate = NSPredicate(format: "recordName == %@", recordCode)
            
            guard let results = try? tempContext.fetch(req), results.isEmpty else {
                return
            }
            
            let newMessage = NSEntityDescription.insertNewObject(forEntityName: "MEMessage",
                                                                 into: tempContext) as! MEMessage
            let File : CKAsset? = record["asset"]
            
            if let file = File {
                newMessage.assetUrl = self.saveFileToCache(file: file)
            }
            
            newMessage.messageType = record["messageType"]
            
            
            if let text = record["text"] as? NSString {
                newMessage.text = text as String
            }
            
            newMessage.userCode = record.creatorUserRecordID?.recordName
            newMessage.date = record.creationDate
        }
        
    }
    
    func saveContext(tempContext: NSManagedObjectContext) {
        tempContext.perform {
            try? tempContext.save()
            if let parent = tempContext.parent {
                parent.perform {
                    try? parent.save()
                }
            }
        }
    }
    
    private func saveFileToCache(file: CKAsset ) -> URL {
        let data: Data
        data = try! NSData(contentsOf: file.fileURL) as Data
        let cacheDirectoryURL =
            try? FileManager.default.url(for: .cachesDirectory,
                                         in: .userDomainMask,
                                         appropriateFor: nil,
                                         create: false)
        
        let temporaryFilename = ProcessInfo().globallyUniqueString
        
        let temporaryFileURL =
            cacheDirectoryURL?.appendingPathComponent(temporaryFilename)
        
        try? data.write(to: temporaryFileURL!,
                        options: .atomicWrite)
        
        return temporaryFileURL!
    }
    
    func saveUserInLocalDataBase(context: NSManagedObjectContext, name: String, photoData: Data?) {
        context.perform {
            let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
            user.name = name
            if let photo = photoData {
                user.profilePhoto = photo as Data
            }
            try? context.save()
        }
    }
}
