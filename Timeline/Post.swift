//
//  Post.swift
//  Timeline
//
//  Created by Garret Koontz on 1/2/17.
//  Copyright © 2017 GK. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Post: CloudKitSyncable {
    
    static let kType = "Post"
    static let kPhotoData = "photoData"
    static let kTimeStamp = "timestamp"
    
    var photoData: Data?
    var timestamp: Date
    var comments: [Comment]
    var photo: UIImage? {
        guard let photoData = self.photoData else { return nil }
        return UIImage(data: photoData)
    }
    
    init(photoData: Data?, timestamp: Date = Date(), comments: [Comment] = []){
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
    }
    
    
    //MARK: - CloudKitSyncable
    
    var recordType: String {
        return Post.kType
    }
    
    var cloudKitRecordID: CKRecordID?
    
    
    convenience required init?(record: CKRecord) {
        
        guard let timestamp = record.creationDate,
            let photoAsset = record[Post.kPhotoData] as? CKAsset else { return nil }
        let photoData = try? Data(contentsOf: photoAsset.fileURL)
        self.init(photoData: photoData, timestamp: timestamp)
        cloudKitRecordID = record.recordID
    }
    
    fileprivate var temporaryPhotoURL: URL {
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        try? photoData?.write(to: fileURL, options: .atomic)
        
        return fileURL
    }
    
}


extension Post: SearchableRecord {
    
    func matches(searchTerm: String) -> Bool {
        let matchedComments = comments.filter { $0.matches(searchTerm: searchTerm) }
        return !matchedComments.isEmpty
    }
}

extension CKRecord {
    
    convenience init(_ post: Post) {
        let recordID = CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: post.recordType, recordID: recordID)
        
        self[Post.kTimeStamp] = post.timestamp as CKRecordValue?
        self[Post.kPhotoData] = CKAsset(fileURL: post.temporaryPhotoURL)

    }
}

