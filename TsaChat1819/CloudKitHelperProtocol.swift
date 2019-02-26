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

protocol CloudKitHelperProtocol {
    
    func myName(_ completion:@escaping (String?)->Void)
    
    func downloadMessages(from: Date?, in context: NSManagedObjectContext, _ completion: @escaping (Date?)->Void)
    
    func sendImageMessage(fileUrl: URL, in context: NSManagedObjectContext, completion: (Bool)->Void)
    
    func sendMessage(_ text: String, in context: NSManagedObjectContext, completion: (Bool)->Void)
    
    func checkForSubscription()
    
    func getUser(context: NSManagedObjectContext) -> User?

}
