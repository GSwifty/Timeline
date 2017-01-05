//
//  PostController.swift
//  Timeline
//
//  Created by Garret Koontz on 1/2/17.
//  Copyright © 2017 GK. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class PostController {
    
    static let sharedController = PostController()
    
    var posts = [Post]() {
        didSet {
            DispatchQueue.main.async {
                let nc = NotificationCenter.default
                nc.post(name: PostController.PostsChangedNotification, object: self)
            }
        }
    }
    
    var comments: [Comment] = []
    
    var isSyncing: Bool = false
    
    let cloudKitManager = CloudKitManager()
    
    static let PostsChangedNotification = Notification.Name("PostsChangedNotification")
    static let PostCommentsChangedNotification = Notification.Name("PostCommentsChangedNotification")
    
    init(){
        
        performFullSync()
    }
    
    // CRUD
    
    func createPost(image: UIImage, caption: String, completion: ((Post) -> Void)?) {
        guard let data = UIImageJPEGRepresentation(image, 1.0) else { return }
        let post = Post(photoData: data)
        addComment(post: post, commentText: caption)
        
        cloudKitManager.save(record: CKRecord(post)) { (record, error) in
            guard let record = record else {
                if let error = error {
                    print("Error saving new post to CloudKit: \(error)")
                    return
                }
                completion?(post)
                return
            }
            post.cloudKitRecordID = record.recordID
        }
        
    }
    
    @discardableResult func addComment(post: Post, commentText: String, completion: @escaping ((Comment) -> Void) = { _ in }) -> Comment {
        let comment = Comment(text: commentText, post: post)
        post.comments.append(comment)
        
        cloudKitManager.save(record: CKRecord(comment)) { (record, error) in
            if let error = error {
                print("Error saving new comment to CloudKit: \(error)")
                return
            }
            comment.cloudKitRecordID = record?.recordID
            completion(comment)
        }
        
        DispatchQueue.main.async {
            let nc = NotificationCenter.default
            nc.post(name: PostController.PostCommentsChangedNotification, object: post)
        }
        return comment
    }
    
    // Helper Functions
    
    private func recordsOf(type: String) -> [CloudKitSyncable] {
        switch type {
        case "Post":
            return posts.flatMap { $0 as CloudKitSyncable }
        case "Comment":
            return comments.flatMap { $0 as CloudKitSyncable }
        default:
            return []
        }
    }
    
    func syncedRecords(ofType type: String) -> [CloudKitSyncable] {
        
        return recordsOf(type: type).filter { $0.isSynced }
    }
    
    func unsyncedRecords(ofType type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { !$0.isSynced }
    }
    
    func fetchNewRecords(ofType type: String, completion: @escaping (() -> Void) = { _ in }) {
        
        var referencesToExclude = [CKReference]()
        
        var predicate: NSPredicate!
        
        referencesToExclude = self.syncedRecords(ofType: type).flatMap {$0.cloudKitReference }
        predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referencesToExclude])
        
        if referencesToExclude.isEmpty {
            predicate = NSPredicate(value: true)
        }
        
        cloudKitManager.fetchRecordWithType(type: type, predicate: predicate, recordFetchedBlock: { (record) in
            switch type {
            case Post.kType:
                if let post = Post(record: record) {
                    self.posts.append(post)
                }
            case Comment.kType:
                guard let postReference = record[Comment.kPost] as? CKReference,
                    let postIndex = self.posts.index(where: { $0.cloudKitRecordID == postReference.recordID }),
                    let comment = Comment(record: record) else { return }
                let post = self.posts[postIndex]
                post.comments.append(comment)
                comment.post = post
            default:
                return
            }
            
        }) { (records, error) in
            if let error = error {
                print("Error fetching CloudKit records of type \(type): \(error)")
            }
            completion()
        }
        
    }
    
    func pushChangesToCloudKit(completion: @escaping ((_ success: Bool, Error?) -> Void) = { _,_ in }) {
        
        let unsavedPosts = unsyncedRecords(ofType: Post.kType) as? [Post] ?? []
        let unsavedComments = unsyncedRecords(ofType: Comment.kType) as? [Comment] ?? []
        var unsavedObjectsByRecord = [CKRecord: CloudKitSyncable]()
        
        for post in unsavedPosts {
            let record = CKRecord(post)
            unsavedObjectsByRecord[record] = post
        }
        for comment in unsavedComments {
            let record = CKRecord(comment)
            unsavedObjectsByRecord[record] = comment
        }
        
        let unsavedRecords = Array(unsavedObjectsByRecord.keys)
        
        cloudKitManager.save(records: unsavedRecords, perRecordCompletion: { (record, error) in
            
            guard let record = record else { return }
            unsavedObjectsByRecord[record]?.cloudKitRecordID = record.recordID
            
            
        }) { (records, error) in
            let success = records != nil
            completion(success, error)
        }
        
    }
    
    //MARK: - Sync
    
    func performFullSync(completion: @escaping (() -> Void) = { _ in }) {
        
        guard !isSyncing else {
            completion()
            return
        }
        
        isSyncing = true
        
        pushChangesToCloudKit { (success) in
            
            self.fetchNewRecords(ofType: Post.kType) {
                
                self.fetchNewRecords(ofType: Comment.kType) {
                    
                    self.isSyncing = false
                    
                    completion()
                }
            }
        }
    }
}
