//
//  SearchLocationCreateAlertTableViewController.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 26/5/2023.
//

import UIKit


class SearchLocationCreateAlertTableViewController: UITableViewController, UISearchBarDelegate{
    
    weak var databaseController: DatabaseProtocol?
    
    var selectedLocation : LocationData?
    
    let CELL_LOCATION = "locationCell"
    let REQUEST_STRING = "http://api.positionstack.com/v1/forward"
    let API_KEY = "3d402bc90a109c5d446247ac56893571"
    var newLocations = [LocationData]()
    var indicator = UIActivityIndicatorView()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Get the shared AppDelegate instance and assign the database controller.
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        // Create a search controller for location search.
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Where would you like to go today ?"
        searchController.searchBar.showsCancelButton = false
        
        // Set the search controller as the navigation item's search controller.
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Configure the activity indicator.
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        // Position the activity indicator at the center of the view using constraints.
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

   
    
    func requestLocationNamed(_ locationName: String) async {
        // This method requests location data for the given location name.
        
        // Encode the location name to ensure it can be used in a URL query.
        guard let queryString = locationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("String can't be queried")
            return
        }
        
        // Construct the request URL with the API key and encoded location name.
        guard let requestUrl = URL(string: "\(REQUEST_STRING)?access_key=\(API_KEY)&query=\(queryString)&country=AU") else {
            print("Invalid URL.")
            return
        }
        
        // Create a URL request with the constructed request URL.
        let urlRequest = URLRequest(url: requestUrl)
        print(urlRequest)
        
        do {
            // Perform the URL request and retrieve the data.
            let (data, request) = try await URLSession.shared.data(for: urlRequest)
            
            // Stop the activity indicator animation.
            indicator.stopAnimating()
            
            // Decode the retrieved data into SearchData object using JSONDecoder.
            let decoder = JSONDecoder()
            let searchData = try decoder.decode(SearchData.self, from: data)
            
            // Append the locations from the search data to the newLocations array and reload the table view.
            if let location = searchData.locations {
                newLocations.append(contentsOf: location)
                tableView.reloadData()
            }
        } catch let error {
            // Handle any errors that occurred during the request.
            print(error)
        }
    }

    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // This method is called when the search bar text editing ends.
        
        // Remove all previous locations from the newLocations array.
        newLocations.removeAll()
        
        // Reload the table view to reflect the changes.
        tableView.reloadData()
        
        // Check if there is a non-empty search text.
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        // Dismiss the search controller.
        navigationItem.searchController?.dismiss(animated: true)
        
        // Start animating the activity indicator.
        indicator.startAnimating()
        
        Task {
            // Await the asynchronous requestLocationNamed method.
            await requestLocationNamed(searchText)
        }
    }

    
    

    
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // This method returns the number of sections in the table view.
        // In this case, there is only one section.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // This method returns the number of rows in the specified section of the table view.
        // In this case, the number of rows is equal to the count of newLocations array.
        return newLocations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This method configures and returns a cell for the specified index path in the table view.
        
        // Dequeue a reusable cell using the provided identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath)
        
        // Retrieve the location for the current index path.
        let location = newLocations[indexPath.row]
        
        // Configure the cell's text labels with the location data.
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = location.label
        
        // Return the configured cell.
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // This method is called when a row is selected in the table view.
        
        // Retrieve the location for the selected row.
        let location = newLocations[indexPath.row]
        
        // Set the selectedLocation property to the selected location.
        selectedLocation = location
        
        // Perform a segue with the specified identifier to transition to the CreateAlert view controller.
        performSegue(withIdentifier: "CreateAlert", sender: self)
    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // This method is called before a segue is performed.
        
        // Check if the destination view controller is of type CreateLocationAlertViewController.
        if let createLocationAlertViewController = segue.destination as? CreateLocationAlertViewController {
            
            // Pass the selectedLocation to the CreateLocationAlertViewController.
            createLocationAlertViewController.selectedLocation = selectedLocation
        }
    }

    

}
