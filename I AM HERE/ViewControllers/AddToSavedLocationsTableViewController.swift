//
//  SearchLocationTableViewController.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 25/5/2023.
//

import UIKit

class AddToSavedLocationsTableViewController: UITableViewController, UISearchBarDelegate {
    
    weak var databaseController: DatabaseProtocol?
    
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
        
        /**
         Set up the database controller
        */
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        /**
         Set up the search controller
        */
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Location"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        /**
         Set up the activity indicator view
        */
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    func requestLocationNamed(_ locationName: String) async {
        // This method is responsible for making an asynchronous request to search for a location by name.
        
        // Ensure that the location name can be properly queried.
        guard let queryString = locationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("String can't be queried")
            return
        }
        
        // Create the request URL using the location name, API key, and additional query parameters.
        guard let requestUrl = URL(string: "\(REQUEST_STRING)?access_key=\(API_KEY)&query=\(queryString)&country=AU") else {
            print("Invalid URL.")
            return
        }
        
        // Create a URLRequest with the request URL.
        let urlRequest = URLRequest(url: requestUrl)
        print(urlRequest)
        
        do {
            // Make an asynchronous data request using URLSession.shared.
            let (data, request) = try await URLSession.shared.data(for: urlRequest)
            indicator.stopAnimating()
            
            // Decode the retrieved data into SearchData model using JSONDecoder.
            let decoder = JSONDecoder()
            let searchData = try decoder.decode(SearchData.self, from: data)
            
            if let location = searchData.locations {
                // Append the retrieved locations to the newLocations array and reload the table view.
                newLocations.append(contentsOf: location)
                tableView.reloadData()
            }
        }
        catch let error {
            print(error)
        }
    }

    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // This method is called when the user finishes editing the search text.
        
        // Remove all previous search results.
        newLocations.removeAll()
        
        // Reload the table view to reflect the changes.
        tableView.reloadData()
        
        // Check if the search text is available and not empty.
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        // Dismiss the search controller.
        navigationItem.searchController?.dismiss(animated: true)
        
        // Start animating the activity indicator.
        indicator.startAnimating()
        
        // Perform an asynchronous task to request locations based on the search text.
        Task {
            await requestLocationNamed(searchText)
            print()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // This method returns the number of sections in the table view.
        
        // Return 1, as there is only one section.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // This method returns the number of rows in the specified section.
        
        // Return the count of newLocations array, as it represents the number of rows.
        return newLocations.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This method configures and returns a cell for the specified index path in the table view.
        
        // Dequeue a reusable cell with the specified identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath)
        
        // Retrieve the location for the current index path.
        let location = newLocations[indexPath.row]
        
        // Set the text labels of the cell with the location's name and label.
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = location.label
        
        // Return the configured cell.
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // This method is called when the user selects a row in the table view.
        
        // Retrieve the selected location from the newLocations array.
        let location = newLocations[indexPath.row]
        
        // Add the selected location to the database using the database controller.
        let _ = databaseController?.addLocation(locationData: location)
        
        // Create a notification content with title, subtitle, and body.
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "I AM HERE"
        notificationContent.subtitle = "Location is saved"
        notificationContent.body = location.label ?? "Pin"
        
        // Create a time-based trigger for the notification.
        let timeInterval = UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
        
        // Assign an identifier for the notification.
        let notificationIdentifier = "notificationIdentifier"
        
        // Create a notification request with the content and trigger.
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: timeInterval)
        
        // Add the notification request to the notification center.
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        // Pop the current view controller from the navigation controller stack.
        navigationController?.popViewController(animated: true)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
