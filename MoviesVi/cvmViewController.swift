//
//  cvmViewController.swift
//  MoviesVi
//
//  Created by Macarena Rojas on 1/23/16.
//  Copyright © 2016 Maca Rojas. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class cvmViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UISearchBarDelegate  {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //Variables

    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var refreshControl: UIRefreshControl!

    //NetworkResquest
    
    func networkRequest() {
    
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
    
    let request = NSURLRequest(URL: url!)
    
    let session = NSURLSession(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        delegate: nil,
        delegateQueue: NSOperationQueue.mainQueue()
    )
    
    let loadingState = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    loadingState.labelText = "Loading"
    
    
    let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
        completionHandler: { (dataOrNil, response, error) in
            
            
            // Hide HUD
            
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as? NSDictionary {
                        NSLog("response: \(responseDictionary)")
                        
                        
                        self.movies = responseDictionary["results"] as? [NSDictionary]
                        self.filteredMovies = self.movies
                        
                        
                        // Reload the collectionView 
                        
                        
                        self.collectionView.reloadData()
                        
                        
                        
                }
            }
    })
    task.resume()
}


    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        //UIRefreshControl
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged);collectionView.insertSubview(refreshControl, atIndex: 0)
        
    
         networkRequest()
    }

    // User can pull to refresh the movies

    
    func refreshControlAction(refreshControl: UIRefreshControl) {

        networkRequest()
        
        self.collectionView.reloadData()
        
        
        refreshControl.endRefreshing()
        
        
    }
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else {
            return 0;   }
        
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cvCell", forIndexPath: indexPath) as! cvCell
        
        
        
        let movie = self.filteredMovies![indexPath.row]
        let title = movie["title"] as! String

        cell.titleLabel.text = title

        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            
            let imageUrl = NSURL(string: baseUrl + posterPath)
            
        cell.posterImage.setImageWithURL(imageUrl!)
        
        }
       
        return cell

    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            filteredMovies = movies
        } else {
           
            filteredMovies = movies!.filter({(dataItem: NSDictionary) -> Bool in
                
                let title = dataItem["title"] as! String
                if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        
        collectionView.reloadData()
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MovieCell
    
        cell.selectionStyle = .None

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
    
        let movie = filteredMovies![indexPath!.row]
        
        let cdetailViewController = segue.destinationViewController as! cDetailViewController
        cdetailViewController.movie = movie
        
    }
    
    
    
}