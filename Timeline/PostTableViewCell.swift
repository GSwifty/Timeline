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

    var post: Post?
    
    func updateWithPost(){
        postImageView.image = post?.photo

    }

}
