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
    
    func save(record: CKRecord, completion: ((Error?) -> Void)? = nil) {
        
    }
    
    func subscribeToRecords(ofType type: String, withPredicate predicate: NSPredicate, subscriptionID: String, options: CKQuerySubscriptionOptions, alertBody: String? = nil, soundName: String? = nil, contentAvailable: Bool, completion: ((CKSubscription?, Error?) -> Void)? = nil) {
        
        let subscription = CKQuerySubscription(recordType: type, predicate: predicate, subscriptionID: subscriptionID, options: options)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = alertBody
        notificationInfo.soundName = soundName
        notificationInfo.shouldSendContentAvailable = contentAvailable
        
        subscription.notificationInfo = notificationInfo
        
        publicDatabase.save(subscription) { (subscription, error) in
            if let error = error {
                print("Unable to save CKSubscription: \(error.localizedDescription)")
            }
            completion?(subscription, error)
        }
        
    }
}
