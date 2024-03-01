//
//  SelectedActiveAlertViewController.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 8/6/2023.
//

import UIKit
import MapKit

class SelectedActiveAlertViewController: UIViewController, MKMapViewDelegate {
    
    // Variable to hold the selected location alert
    var selectedLocation: LocationAlert?

    // Outlet for the map view
    @IBOutlet weak var mapView: MKMapView!

    // Outlet for the radius label
    @IBOutlet weak var radiusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegate of the map view to self
        mapView.delegate = self
        
        // Do any additional setup after loading the view.
        
        // Call a method to set the annotation for the selected location
        setAnnotationForSelectedLocation()
        
        // Set the radius label text to the selected location's radius
        radiusLabel.text = String(Int(selectedLocation?.radius ?? 50)) + " meters"
    }

    
    /**
     Method to set the annotation for the selected location
     */
    func setAnnotationForSelectedLocation() {
        // Create a new location annotation
        let locationAnnotation = MKPointAnnotation()
        locationAnnotation.title = selectedLocation?.label
        locationAnnotation.coordinate = CLLocationCoordinate2D(latitude: selectedLocation?.latitude ?? 0, longitude: selectedLocation?.longitude ?? 0)
        
        // Add the location annotation to the map view
        mapView.addAnnotation(locationAnnotation)
        
        // Set the region of the map view to focus on the selected location
        mapView.setRegion(MKCoordinateRegion(center: locationAnnotation.coordinate, latitudinalMeters: 100, longitudinalMeters: 100), animated: true)
        
        // Create a circle overlay based on the selected location's radius
        let circleOverlay = MKCircle(center: locationAnnotation.coordinate, radius: CLLocationDistance(selectedLocation?.radius ?? 50))
        
        // Add the circle overlay to the map view
        mapView.addOverlay(circleOverlay, level: .aboveRoads)
    }

    /**
     Renderer for the circle overlay
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Retrieve the circle overlay
        let circleOverlay = (overlay as? MKCircle)!
        
        // Create a renderer for the circle overlay
        let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
        
        // Set the fill color for the circle renderer
        circleRenderer.fillColor = UIColor.systemBlue
        
        // Set the transparency level for the circle renderer
        circleRenderer.alpha = 0.2
        
        // Return the circle renderer
        return circleRenderer
    }

    

    
////     MARK: - Navigation
//
//     //In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
//

}
