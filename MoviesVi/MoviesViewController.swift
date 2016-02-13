//
//  MoviesViewController.swift
//  MoviesVi
//
//  Created by Macarena Rojas on 1/20/16.
//  Copyright © 2016 Maca Rojas. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

        
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var refreshControl: UIRefreshControl!

    var endpoint: String!
    

    // NetworkRequest
    func networkRequest() {
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
    
        // Makes a network request to get updated data
        
        // ... Create the NSURLRequest (myRequest) ...
        
        let request = NSURLRequest(URL: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        
        
        let loadingState = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingState.labelText = "Loading"

        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                // ... Remainder of response handling code ...

                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            // Get the array of movies dictionaries stored in results and downcast it as
                            // as an array of NSDictionary

                            self.movies = responseDictionary["results"] as? [NSDictionary]
                
                            self.filteredMovies = self.movies
                            
                            
                            // Reload the tableView now that there is new data
                            
                            
                            self.tableView.reloadData()
                            
                          
                            
                            
                    }
                }
        })
        task.resume()
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self



        // Initialize a UIRefreshControl
        // binding action to refresh control
        // insert network control into the list
       
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged);tableView.insertSubview(refreshControl, atIndex: 0)
        
        // call network request session
        networkRequest()
        }
    
        // User can pull to refresh the movies
        func refreshControlAction(refreshControl: UIRefreshControl) {
            // Make network request to fetch latest data
            networkRequest()
            
            // Update the table view data source.
            self.tableView.reloadData()
            
            // Tell the refreshControl to stop spinning
            
            refreshControl.endRefreshing()
       

        // Do any additional setup after loading the view.
       
        // Initialize a UIRefreshControl
        
        
    }

    


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let filteredMovies = filteredMovies {
            return filteredMovies.count;
        } else {
            return 0;        }
    
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        
        
        let movie = self.filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let accessoryTypes: [UITableViewCellAccessoryType] = [.DisclosureIndicator]

        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.accessoryType = accessoryTypes[indexPath.row % accessoryTypes.count]
       
        let baseUrl = "http://image.tmdb.org/t/p/w500"

        if let posterPath = movie["poster_path"] as? String {
            
        let imageUrl = NSURL(string: baseUrl + posterPath)
            
            cell.posterView.setImageWithURL(imageUrl!)

        }
        
        return cell
    
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredMovies = movies!.filter({(dataItem: NSDictionary) -> Bool in
                // If dataItem matches the searchText, return true to include it
                let title = dataItem["title"] as! String
                if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }

        tableView.reloadData()
    
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    
    }
    
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = filteredMovies![indexPath!.row]
        
        
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.movie = movie
            
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MovieCell
        
        cell.selectionStyle = .None
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

                
        // Get the new view controller using segue.destinationViewController.
        
        
        // Pass the selected object to the new view controller.
    }


}
