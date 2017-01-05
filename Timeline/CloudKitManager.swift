//
//  CloudKitManager.swift
//  Timeline
//
//  Created by Garret Koontz on 1/4/17.
//  Copyright © 2017 GK. All rights reserved.
//

import UIKit
import CloudKit

class CloudKitManager {
    
    static let sharedController = CloudKitManager()
    
    init() {
        checkCloudKitAvailability()
    }
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    // SAVE FUNCTIONS
    
    func save(record: CKRecord, completion: ((CKRecord?, Error?) -> Void)? = nil) {
        publicDatabase.save(record) { (record, error) in
            completion?(record, error)
        }
    }
    
    func saveRecords(_ records: [CKRecord], perRecordCompletion: ((_ record: CKRecord?, _ error: Error?) -> Void)?, completion: ((_ records: [CKRecord]?, _ error: Error?) -> Void)?) {
        
        modifyRecords(records, perRecordCompletion: perRecordCompletion, completion: completion)
    }

    
    func modifyRecords(_ records: [CKRecord], perRecordCompletion: ((_ record: CKRecord?, _ error: Error?) -> Void)?, completion: ((_ records: [CKRecord]?, _ error: Error?) -> Void)?) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        operation.qualityOfService = .userInteractive
        
        operation.perRecordCompletionBlock = perRecordCompletion
        
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            (completion?(records, error))!
        }
        
        publicDatabase.add(operation)
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
    
    func checkCloudKitAvailability() {
        
        CKContainer.default().accountStatus() {
            (accountStatus:CKAccountStatus, error:Error?) -> Void in
            
            switch accountStatus {
            case .available:
                print("CloudKit available. Initializing full sync.")
                return
            default:
                self.handleCloudKitUnavailable(accountStatus, error: error)
            }
        }
    } // Is CloudKit available?
    
    func handleCloudKitUnavailable(_ accountStatus: CKAccountStatus, error:Error?) {
        
        var errorText = "Synchronization is disabled\n"
        if let error = error {
            print("handleCloudKitUnavailable ERROR: \(error)")
            print("An error occured: \(error.localizedDescription)")
            errorText += error.localizedDescription
        }
        
        switch accountStatus {
        case .restricted:
            errorText += "iCloud is not available due to restrictions"
        case .noAccount:
            errorText += "There is no CloudKit account setup.\nYou can setup iCloud in the Settings app."
        default:
            break
        }
        
        displayCloudKitNotAvailableError(errorText)
    } // Prepare our excuse for why it's not working
    
    func displayCloudKitNotAvailableError(_ errorText: String) {
        
        DispatchQueue.main.async(execute: {
            
            let alertController = UIAlertController(title: "iCloud Synchronization Error", message: errorText, preferredStyle: .alert)
            
            let dismissAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil);
            
            alertController.addAction(dismissAction)
            
            if let appDelegate = UIApplication.shared.delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        })
    } // Give our excuse
    
    
}
