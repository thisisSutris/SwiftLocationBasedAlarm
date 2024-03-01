//
//  ActiveAlertsTableViewController.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 8/6/2023.
//

import UIKit
import CoreLocation
import UserNotifications

class ActiveAlertsTableViewController: UITableViewController, DatabaseListener, CLLocationManagerDelegate {
    
    
    /**
        This method is called when the list of locations is changed.
     
        - Parameter locationList: The updated list of locations.
     
        Notes:
        - This method is used to handle changes in the list of locations.
        - No specific action is performed in this method, so the body is empty.
    */
    func onLocationListChange(locationList: [Location]) {
        // Do Nothing
    }

    /**
        This method is called when the list of location alerts is changed.
     
        - Parameter locationAlertList: The updated list of location alerts.
     
        Notes:
        - This method is used to handle changes in the list of location alerts.
        - It updates the `allLocationAlerts` array with the provided `locationAlertList`.
        - After updating the data source, it reloads the `tableView` to reflect the changes.
    */
    func onLocationAlertListChange(locationAlertList: [LocationAlert]) {
        allLocationAlerts = locationAlertList
        tableView.reloadData()
    }


    // Constant for cell identifier
    let CELL_ALERT = "alertCell"

    // Array to store location alerts
    var allLocationAlerts = [LocationAlert]()

    // Current user location
    var currentLocation: CLLocationCoordinate2D?

    // Selected location alert
    var selectedLocation: LocationAlert?

    // Location manager for managing user's location
    let locationManager = CLLocationManager()

    // Weak reference to database controller
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        locationManager.delegate = self
        
        createGeoFences()
    }

    
    /**
        Updates the current location when the location manager receives new locations.
        
        - Parameters:
            - manager: The location manager object.
            - locations: An array of CLLocation objects representing the updated locations.
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location?.coordinate
    }

    
    /**
        Called before the view controller's view is about to be displayed.
        
        - Parameters:
            - animated: A Boolean value indicating whether the appearance transition is animated.
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Add the view controller as a listener to the databaseController.
        databaseController?.addListener(listener: self)
    }

    
    /**
        Called before the view controller's view is about to be dismissed.
        
        - Parameters:
            - animated: A Boolean value indicating whether the appearance transition is animated.
    */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove the view controller as a listener from the databaseController.
        databaseController?.removeListener(listener: self)
    }

    
    /**
        Creates geofence regions for all location alerts.
        Starts monitoring each geofence region.

        - Note: This method is responsible for setting up geofence regions and starting monitoring for each region.

        - Important: Ensure that `allLocationAlerts` is populated with the necessary location alert data before calling this method.
    */
    func createGeoFences() {
        for locationAlert in allLocationAlerts {
            let geoFenceRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: locationAlert.latitude, longitude: locationAlert.longitude), radius: CLLocationDistance(locationAlert.radius), identifier: locationAlert.name ?? "Location")
            geoFenceRegion.notifyOnEntry = true
            geoFenceRegion.notifyOnExit = false
            locationManager.startMonitoring(for: geoFenceRegion)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            if let circularRegion = region as? CLCircularRegion {
                createNotification(region: circularRegion)
            }
        }

        // Delegate method called when exiting a geofence
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
            if let circularRegion = region as? CLCircularRegion {
                print("Exited geofence: \(circularRegion.identifier)")
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
            if let circularRegion = region as? CLCircularRegion {
                // Geofence monitoring started for the circular region
                print("Started monitoring geofence: \(circularRegion.identifier)")
            }
        }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    
    /**
        Creates and schedules a notification for the provided region.

        - Parameters:
            - region: The region for which the notification is created.

        - Note: This method is responsible for configuring and scheduling a notification when the user enters a geofence region.

        - Important: Ensure that the necessary notification content is set before calling this method.

        - Warning: The `timeInterval` parameter of the `UNTimeIntervalNotificationTrigger` is set to 0.1 seconds, which might result in the notification being displayed immediately after scheduling. Adjust the time interval as needed.
    */
    func createNotification(region: CLRegion) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "I AM HERE"
        notificationContent.subtitle = "You are near an active alert!"

        let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let locationAlertIdentifier = "locationAlert"

        let request = UNNotificationRequest(identifier: locationAlertIdentifier,
                                            content: notificationContent, trigger: timeTrigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    
    // MARK: - Table view data source
    
    /**
        Returns the number of sections in the table view.

        - Parameter tableView: The table view requesting this information.

        - Returns: The number of sections in the table view.

        - Note: This method is part of the UITableViewDataSource protocol.
    */
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    /**
        Returns the number of rows in the specified section of the table view.

        - Parameters:
            - tableView: The table view requesting this information.
            - section: The section index in the table view.

        - Returns: The number of rows in the specified section.

        - Note: This method is part of the UITableViewDataSource protocol.
    */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allLocationAlerts.count
    }

    /**
        Returns a cell to be displayed at the specified index path.

        - Parameters:
            - tableView: The table view requesting this information.
            - indexPath: The index path locating the row in the table view.

        - Returns: A configured table view cell.

        - Note: This method is part of the UITableViewDataSource protocol.
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ALERT, for: indexPath)
        let locationAlert = allLocationAlerts[indexPath.row]
        cell.textLabel?.text = locationAlert.name
        cell.detailTextLabel?.text = String(Int(locationAlert.radius)) + " meters"

        return cell
    }

    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationAlert = allLocationAlerts[indexPath.row]
        selectedLocation = locationAlert
        performSegue(withIdentifier: "showActiveAlert", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let locationAlert = allLocationAlerts[indexPath.row]
            databaseController?.deleteLocationDataAlert(locationAlert: locationAlert)
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
        
        
//          MARK: - Navigation
         
//          In a storyboard-based application, you will often want to do a little preparation before navigation
    /**
        Prepares for the segue to the destination view controller.

        - Parameters:
            - segue: The segue object containing information about the view controllers involved in the segue.
            - sender: The object that initiated the segue.

        - Note: This method is called automatically when a segue is triggered.
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the destination view controller
        let SelectedActiveAlertViewController = segue.destination as? SelectedActiveAlertViewController
        
        // Pass the selected location to the destination view controller
        SelectedActiveAlertViewController?.selectedLocation = selectedLocation
    }
}
