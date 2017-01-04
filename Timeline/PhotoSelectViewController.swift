//
//  PhotoSelectViewController.swift
//  Timeline
//
//  Created by Garret Koontz on 1/3/17.
//  Copyright © 2017 GK. All rights reserved.
//

import UIKit

class PhotoSelectViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - Actions
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        imageView.image = #imageLiteral(resourceName: "devsample")
        selectImageButton.setTitle("", for: .normal)
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
