//
//  LocalDatabaseHelper.swift
//  TsaChat1819
//
//  Created by Milan Kokic on 18/02/2019.
//  Copyright © 2019 Marro Gros Gabriel. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

protocol LocalDatabaseProtocol {
    
    func insertNewMessage(context:NSManagedObjectContext, record: CKRecord, text: String)
    
    func insertNewImageMessage(context:NSManagedObjectContext, record: CKRecord, assetUrl: URL)
    
    func insertMessagePerRecord(tempContext: NSManagedObjectContext, record: CKRecord)
    
    func saveContext(tempContext: NSManagedObjectContext)
    
}
    


