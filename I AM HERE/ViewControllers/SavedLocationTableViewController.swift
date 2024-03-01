//
//  SavedLocationTableViewController.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 17/5/2023.
//

import UIKit

class SavedLocationTableViewController: UITableViewController, DatabaseListener {
    
    func onLocationAlertListChange(locationAlertList: [LocationAlert]) {
        // Do Nothing
    }
    
    
    func onLocationListChange(locationList: [Location]) {
        allLocations = locationList
        tableView.reloadData()
    }
    
    
    let CELL_LOCATION = "locationCell"
    
    var allLocations = [Location]()
    
    weak var databaseController: DatabaseProtocol?
    
    var selectedLocation : Location?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
    }
    
    /**
        Called when the view is about to appear on the screen.
        - Parameter animated: A boolean value indicating whether the appearance should be animated.
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add the listener to the database controller to receive updates.
        databaseController?.addListener(listener: self)
    }

    /**
        Called when the view is about to disappear from the screen.
        - Parameter animated: A boolean value indicating whether the disappearance should be animated.
    */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove the listener from the database controller to stop receiving updates.
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        // This method determines the number of sections in the table view.
        // In this case, we only have one section, so we return 1.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        // This method determines the number of rows in the specified section of the table view.
        // In this case, we return the count of allLocations, which represents the number of rows.
        return allLocations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This method configures and returns a table view cell for the specified index path.
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath)
        let location = allLocations[indexPath.row]
        
        // Set the text labels of the cell to display the name and label of the location.
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = location.label
        
        // Return the configured cell.
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // This method is called when a row in the table view is selected.
        
        let location = allLocations[indexPath.row]
        
        // Set the selectedLocation property to the selected location.
        selectedLocation = location
        
        // Perform the segue with the identifier "SelectRadius" to transition to the next view controller.
        performSegue(withIdentifier: "SelectRadius", sender: self)
    }

    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // This method is called when the user performs an editing action on a cell.
        // It handles the deletion of a location when the delete editing style is selected.
        
        if editingStyle == .delete {
            // If the editing style is delete, we proceed with deleting the location.
            
            let location = allLocations[indexPath.row]
            
            // Call the deleteLocation method of the database controller to delete the location.
            databaseController?.deleteLocation(location: location)
        }
    }
    

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
        // This method is called just before a segue is performed.
        // It allows you to prepare data or configure the destination view controller before the transition.
        
        // Check if the destination view controller is of type CreateLocationAlertViewController.
        if let createLocationAlertViewController = segue.destination as? CreateLocationAlertViewController {
            
            // Set the properties of the createLocationAlertViewController.
            createLocationAlertViewController.fromFavorites = true
            createLocationAlertViewController.favoriteLocation = selectedLocation
        }
    }

}
