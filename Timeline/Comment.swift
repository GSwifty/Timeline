//
//  Comment.swift
//  Timeline
//
//  Created by Garret Koontz on 1/2/17.
//  Copyright © 2017 GK. All rights reserved.
//

import Foundation

class Comment: SearchableRecord {
    
    var text: String
    var timestamp: Date
    var post: Post
    
    init(text: String, timestamp: Date = Date(), post: Post) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
        
    }
    
    func matches(searchTerm: String) -> Bool {
        return text.contains(searchTerm)
    }   
}
