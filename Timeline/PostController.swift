//
//  PostController.swift
//  Timeline
//
//  Created by Garret Koontz on 1/2/17.
//  Copyright © 2017 GK. All rights reserved.
//

import Foundation
import UIKit

class PostController {
    
    static let sharedController = PostController()

    var posts: [Post] = []
    
    // CRUD 
    
    func createPost(image: UIImage, caption: String) {
        guard let data = UIImageJPEGRepresentation(image, 0.7) else { return }
        let post = Post(photoData: data)
        posts.append(post)
        let captionText = addComment(post: post, commentText: caption)
    }
    
    func addComment(post: Post, commentText: String) {
        let comment = Comment(text: commentText, post: post)
        post.comments.append(comment)
    }
    
    
    
    
}
