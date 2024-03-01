//
//  HomeViewController.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 26/5/2023.
//

import UIKit
import UserNotifications
import CoreLocation
import MapKit

class HomeViewController: UIViewController, DatabaseListener, CLLocationManagerDelegate, MKMapViewDelegate {
    
    /** This method is called when the location list changes.
     
     - Parameter locationList: The updated location list.
     - Note: Currently, this method does nothing.
     */
    func onLocationListChange(locationList: [Location]) {
        
        // do nothing
    }
    
    /** This method is called when the location alert list changes.
     
     - Parameter locationAlertList: The updated location alert list.
     - Note: It updates the `allLocationAlerts` array with the new list and reloads the input views of the `mapView` to reflect the changes.
     */
    func onLocationAlertListChange(locationAlertList: [LocationAlert]) {
        allLocationAlerts = locationAlertList
        mapView.reloadInputViews()
    }
    
    /** The map view that displays location information. */
    @IBOutlet weak var mapView: MKMapView!
    
    /** An array that stores all location alerts. */
    var allLocationAlerts = [LocationAlert]()
    
    /** The database controller used to interact with the database. */
    weak var databaseController: DatabaseProtocol?
    
    /** The location manager responsible for handling location-related operations. */
    let locationManager = CLLocationManager()
    
    /** The current location coordinates. */
    var currentLocation: CLLocationCoordinate2D?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform any additional setup after loading the view.
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        mapView.delegate = self
        
        coreLocationSetUp()
        
        askForNotificationPermission()
    }
    
    /** Action method triggered when the refresh button is clicked. */
    @IBAction func refreshButtonClick(_ sender: Any) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        displayAllActiveAlerts(locationAlertList: allLocationAlerts)
    }
    
    /** Delegate method called when the location manager updates the locations. */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location?.coordinate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Display all active alerts on the map
        displayAllActiveAlerts(locationAlertList: allLocationAlerts)
        
        // Add listener to the database controller
        databaseController?.addListener(listener: self)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove the listener from the database controller
        databaseController?.removeListener(listener: self)
    }
    
    /** Requests user permission for notifications. */
    func askForNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
            if !granted {
                print("Permission was not granted!")
                return
            }
        }
    }
    
    /** Displays all active alerts on the map. */
    func displayAllActiveAlerts(locationAlertList: [LocationAlert]) {
        mapView.removeOverlays(mapView.overlays)
        
        // Annotate locations and add overlays for each location alert
        for alert in locationAlertList {
            annotateLocations(locationAlert: alert)
            annotateOverlay(locationAlert: alert)
        }
    }
    
    /** Annotates a location on the map. */
    func annotateLocations(locationAlert: LocationAlert) {
        let locationAlertAnnotation = MKPointAnnotation()
        locationAlertAnnotation.title = locationAlert.name
        locationAlertAnnotation.coordinate = CLLocationCoordinate2D(latitude: locationAlert.latitude, longitude: locationAlert.longitude)
        mapView.addAnnotation(locationAlertAnnotation)
    }
    
    /** Adds an overlay to the map for a location alert. */
    func annotateOverlay(locationAlert: LocationAlert) {
        let circleOverlay = MKCircle(center: CLLocationCoordinate2D(latitude: locationAlert.latitude, longitude: locationAlert.longitude), radius: CLLocationDistance(locationAlert.radius))
        
        mapView.addOverlay(circleOverlay, level: .aboveRoads)
    }
    
    
    /**
     Renderer for the circle overlay on the map.
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Cast the overlay as MKCircle
        let circleOverlay = (overlay as? MKCircle)!
        
        // Create a circle renderer for the overlay
        let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
        
        // Set the fill color of the circle
        circleRenderer.fillColor = UIColor.systemBlue
        
        // Set the alpha (transparency) of the circle
        circleRenderer.alpha = 0.2
        
        // Return the circle renderer
        return circleRenderer
    }

    
    /** Sets up Core Location functionality. */
    func coreLocationSetUp() {
        // Ask for authorization from the user to always access location.
        self.locationManager.requestAlwaysAuthorization()
        
        // Ask for authorization from the user to use location when the app is in the foreground.
        self.locationManager.requestWhenInUseAuthorization()
        
        // Set the delegate for the location manager.
        locationManager.delegate = self
        
        // Set the desired accuracy for location updates.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Start updating the location.
        locationManager.startUpdatingLocation()
    }
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}
