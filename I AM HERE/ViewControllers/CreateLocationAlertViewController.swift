//
//  ShowLocationsOnMapViewController.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 3/6/2023.
//

import UIKit
import MapKit
import CoreLocation


class CreateLocationAlertViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    // Weak reference to the database controller
    weak var databaseController: DatabaseProtocol?

    // Location manager instance for managing location updates
    var locationManager: CLLocationManager = CLLocationManager()

    // Currently selected location
    var selectedLocation: LocationData!

    // Favorite location
    var favoriteLocation: Location!

    // Flag indicating if the view is loaded from favorites
    var fromFavorites = false

    // Label for displaying the radius value
    @IBOutlet weak var radiusLabel: UILabel!

    // Slider for adjusting the radius
    @IBOutlet weak var radiusSlider: UISlider!

    // Map view for displaying the location and overlay
    @IBOutlet weak var mapView: MKMapView!

    // Action method called when the radius slider value changes
    @IBAction func radiusSliderChanged(_ sender: Any) {
        // Remove existing overlays from the map
        mapView.removeOverlays(mapView.overlays)
        
        // Adjust the circle overlay based on the updated radius
        adjustCircleOverlay(radius: CLLocationDistance(radiusSlider.value))
        
        // Update the radius label with the new value
        radiusLabel.text = String(Int(radiusSlider.value)) + " meters"
    }

    
    // Action method called when the create alert button is tapped
    @IBAction func createAlert(_ sender: Any) {
        if !fromFavorites {
            // Add a location data alert using the selected location and radius
            let _ = databaseController?.addLocationDataAlert(locationData: selectedLocation, radius: radiusSlider.value)
            self.navigationController?.popViewController(animated: true)
        } else {
            // Add a location data alert using the favorite location and radius
            let _ = databaseController?.addLocationDataAlert(location: favoriteLocation, radius: radiusSlider.value)
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        mapView.delegate = self
        
        // Start of Initial Setup
        setUpLocationManager()
        setAccuracyAndDistance()
        // End of Initial Setup
        
        // Other Setup
        setAnnotationForSelectedLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    /**
     Set up Location Manager
     **/
    func setUpLocationManager() {
        // Initialize the location manager and set its delegate
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }

    
    
    /**
     Method to annotate the selected location
     */
    func setAnnotationForSelectedLocation() {
        if !fromFavorites {
            // Create a location annotation
            let locationAnnotation = MKPointAnnotation()
            locationAnnotation.title = selectedLocation.label
            locationAnnotation.coordinate = CLLocationCoordinate2D(latitude: selectedLocation.latitude ?? 0, longitude: selectedLocation.longitude ?? 0)
            
            // Add the location annotation to the map view
            mapView.addAnnotation(locationAnnotation)
            
            // Set the region to display the annotation and add a circle overlay
            mapView.setRegion(MKCoordinateRegion(center: locationAnnotation.coordinate, latitudinalMeters: 100, longitudinalMeters: 100), animated: true)
            let circleOverlay = MKCircle(center: locationAnnotation.coordinate, radius: 50)
            mapView.addOverlay(circleOverlay, level: .aboveRoads)
        } else {
            // Create a location annotation
            let locationAnnotation = MKPointAnnotation()
            locationAnnotation.title = favoriteLocation.label
            locationAnnotation.coordinate = CLLocationCoordinate2D(latitude: favoriteLocation.latitude, longitude: favoriteLocation.longitude)
            
            // Add the location annotation to the map view
            mapView.addAnnotation(locationAnnotation)
            
            // Set the region to display the annotation and add a circle overlay
            mapView.setRegion(MKCoordinateRegion(center: locationAnnotation.coordinate, latitudinalMeters: 100, longitudinalMeters: 100), animated: true)
            let circleOverlay = MKCircle(center: locationAnnotation.coordinate, radius: 50)
            mapView.addOverlay(circleOverlay, level: .aboveRoads)
        }
    }

    /**
     Method to adjust the circle overlay radius
     */
    func adjustCircleOverlay(radius: CLLocationDistance) {
        if !fromFavorites {
            // Create a circle overlay with the specified radius
            let circleOverlay = MKCircle(center: CLLocationCoordinate2D(latitude: selectedLocation.latitude ?? 0, longitude: selectedLocation.longitude ?? 0), radius: radius)
            
            // Add the circle overlay to the map view
            mapView.addOverlay(circleOverlay, level: .aboveRoads)
        } else {
            // Create a circle overlay with the specified radius
            let circleOverlay = MKCircle(center: CLLocationCoordinate2D(latitude: favoriteLocation.latitude, longitude: favoriteLocation.longitude), radius: radius)
            
            // Add the circle overlay to the map view
            mapView.addOverlay(circleOverlay, level: .aboveRoads)
        }
    }

    /**
     Renderer for the circle overlay
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleOverlay = (overlay as? MKCircle)!
        let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
        
        // Set the circle renderer properties
        circleRenderer.fillColor = UIColor.systemBlue
        circleRenderer.alpha = 0.2
        
        return circleRenderer
    }

    /**
     Method to set the desired accuracy and distance filter for location updates
     */
    func setAccuracyAndDistance() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 1
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

