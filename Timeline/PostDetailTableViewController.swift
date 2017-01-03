//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Garret Koontz on 1/2/17.
//  Copyright © 2017 GK. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var followButton: UIBarButtonItem!
    
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
    }
    
    func updateViews() {
        guard let post = post, isViewLoaded else { return }
        
        imageView.image = post.photo
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return post?.comments.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        guard let post = post else { return cell }
        let comment = post.comments[indexPath.row]
        
        cell.textLabel?.text = comment.text
        return cell
        
    }
    
    // Actions
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        
        var commentTextField: UITextField?
        
        let alertController = UIAlertController(title: "Add Comment", message: "Enter a comment below", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter comment..."
            commentTextField = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addCommentAction = UIAlertAction(title: "OK", style: .default) { (_) in
            guard let comment = commentTextField?.text, !comment.isEmpty,
            let post = self.post else { return }
            
            PostController.sharedController.addComment(post: post, commentText: comment)
            self.tableView.reloadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addCommentAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
    }
    
    
    
    
}
