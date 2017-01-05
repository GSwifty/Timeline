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
        
        requestFullSync()
        
        if tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(postsChanged(notification:)), name: PostController.PostsChangedNotification, object: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.sharedController.posts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return PostTableViewCell() }
        
        let posts = PostController.sharedController.posts
        cell.post = posts[indexPath.row]
        
        return cell
    }
    
    //MARK: - Actions
    
    
    func postsChanged(notification: NSNotification) {
        tableView.reloadData()
    }
    
    func setupSearchController() {
        
        let resultsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsTableViewController")
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = true
        tableView.tableHeaderView = searchController?.searchBar
        
        definesPresentationContext = true
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let resultsViewController = searchController.searchResultsController as? SearchResultsTableViewController,
            let searchTerm = searchController.searchBar.text?.lowercased() {
            let posts = PostController.sharedController.posts
            let filteredPosts = posts.filter {$0.matches(searchTerm: searchTerm) }.map { $0 as SearchableRecord }
            resultsViewController.resultsArray = filteredPosts
            resultsViewController.tableView.reloadData()
        }
    }
    
    
    @IBAction func refreshControlValueChanged(_ sender: UIRefreshControl) {
        requestFullSync {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func requestFullSync(_ completion: (() -> Void)? = nil) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        PostController.sharedController.performFullSync {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            completion?()
        }
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
        
        if segue.identifier == "toPostDetailFromSearch" {
            if let detailViewController = segue.destination as? PostDetailTableViewController,
                let sender = sender as? PostTableViewCell,
                let indexPath = (searchController?.searchResultsController as? SearchResultsTableViewController)?.tableView.indexPath(for: sender),
                let searchTerm = searchController?.searchBar.text?.lowercased() {
                let posts = PostController.sharedController.posts.filter({ $0.matches(searchTerm: searchTerm) } )
                let post = posts[indexPath.row]
                detailViewController.post = post
            }
        }
    }
}
