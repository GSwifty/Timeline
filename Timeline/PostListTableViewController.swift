//
//  PostListTableViewController.swift
//  Timeline
//
//  Created by Garret Koontz on 1/2/17.
//  Copyright © 2017 GK. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return PostController.sharedController.posts.count    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return PostTableViewCell() }
        
        let post = PostController.sharedController.posts[indexPath.row]
        cell.update(withPost: post)
        
        return cell
    }
    
    //MARK: - Actions
    
    func setupSearchController() {
        
        let resultsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsTableViewController")
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = true
        tableView.tableHeaderView = searchController?.searchBar
        
        definesPresentationContext = true
        
    }
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let post = PostController.sharedController.posts[indexPath.row]
                if let postDVC = segue.destination as? PostDetailTableViewController {
                    postDVC.post = post
                }
            }
        }
        
        if segue.identifier == 
    }
}
