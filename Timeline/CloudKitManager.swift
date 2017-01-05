//
//  CloudKitManager.swift
//  Timeline
//
//  Created by Garret Koontz on 1/4/17.
//  Copyright © 2017 GK. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitManager {
    
    static let sharedController = CloudKitManager()
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    // SAVE FUNCTIONS
    
    func save(record: CKRecord, completion: ((CKRecord?, Error?) -> Void)? = nil) {
        publicDatabase.save(record) { (record, error) in
            completion?(record, error)
        }
    }
    
    func save(records:[CKRecord], perRecordCompletion: ((CKRecord?, Error?) -> Void)?, completion: (([CKRecord]?, _ error: Error?) -> Void)?) {
        
    }
    
    // FETCH RECORD FUNCTIONS
    
    func fetchRecordWithType(type: String, predicate: NSPredicate = NSPredicate(value: true), recordFetchedBlock: ((CKRecord) -> Void)?, completion: (([CKRecord]?, Error?) -> Void)?) {
        
        var fetchedRecords: [CKRecord] = []
        
        
        let query = CKQuery(recordType: type, predicate: NSPredicate(value: true))
        let queryOperation = CKQueryOperation(query: query)
        
        let perRecordBlock = { (fetchedRecord: CKRecord) -> Void in
            fetchedRecords.append(fetchedRecord)
            recordFetchedBlock?(fetchedRecord)
        }
        
        queryOperation.recordFetchedBlock = perRecordBlock
        
        var queryCompletionBlock: (CKQueryCursor?, Error?) -> Void = { (_, _) in }
        
        queryCompletionBlock = { (queryCursor: CKQueryCursor?, error: Error?) -> Void in
            
            if let queryCursor = queryCursor {
                
                let continuedQueryOperation = CKQueryOperation(cursor: queryCursor)
                continuedQueryOperation.recordFetchedBlock = perRecordBlock
                continuedQueryOperation.queryCompletionBlock = queryCompletionBlock
                
                self.publicDatabase.add(continuedQueryOperation)
                
            } else {
                completion?(fetchedRecords, error)
                
            }
        }
        
        queryOperation.queryCompletionBlock = queryCompletionBlock
        self.publicDatabase.add(queryOperation)
        
        //    func subscribeToRecords(ofType type: String, withPredicate predicate: NSPredicate, subscriptionID: String, options: CKQuerySubscriptionOptions, alertBody: String? = nil, soundName: String? = nil, contentAvailable: Bool, completion: ((CKSubscription?, Error?) -> Void)? = nil) {
        //
        //        let subscription = CKQuerySubscription(recordType: type, predicate: predicate, subscriptionID: subscriptionID, options: options)
        //
        //        let notificationInfo = CKNotificationInfo()
        //        notificationInfo.alertBody = alertBody
        //        notificationInfo.alertLaunchImage = "devsample"
        //        notificationInfo.soundName = soundName
        //        notificationInfo.shouldSendContentAvailable = contentAvailable
        //
        //        subscription.notificationInfo = notificationInfo
        //
        //        publicDatabase.save(subscription) { (subscription, error) in
        //            if let error = error {
        //                print("Unable to save CKSubscription: \(error.localizedDescription)")
        //            }
        //            completion?(subscription, error)
        //        }
        
    }
    
    
}
