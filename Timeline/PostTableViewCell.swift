//
//  PostTableViewCell.swift
//  Timeline
//
//  Created by Garret Koontz on 1/2/17.
//  Copyright © 2017 GK. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    
    
    
    func updateWithPost(post: Post){
        postImageView.image = post.photo
        
    }
    
    var post: Post? {
        didSet {
            guard let post = post else { return }
            updateWithPost(post: post)
        }
    }
}
