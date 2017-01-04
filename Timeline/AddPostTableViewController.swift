//
//  AddPostTableViewController.swift
//  Timeline
//
//  Created by Garret Koontz on 1/2/17.
//  Copyright © 2017 GK. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    var image: UIImage?
    
        @IBOutlet weak var commentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        
        if let image = image,
        let caption = commentTextField.text, !caption.isEmpty {
            PostController.sharedController.createPost(image: image, caption: caption)
            dismiss(animated: true, completion: nil)
            
        } else {
            
            let alertController = UIAlertController(title: "Missing Information", message: "You did not enter all required information!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Try Again", style: .cancel, handler: nil)
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }  
}


