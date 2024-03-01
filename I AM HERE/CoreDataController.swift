//
//  CoreDataController.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 25/5/2023.
//

import Foundation
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate, DatabaseProtocol{
    
    
    /**
     Adds a new LocationAlert entity to the persistent container with the given LocationData and radius.
     
     - Parameters:
         - locationData: The LocationData object containing latitude, longitude, label, and name information.
         - radius: The radius of the location alert.
     - Returns: The newly created LocationAlert entity.
     */
    func addLocationDataAlert(locationData: LocationData, radius: Float) -> LocationAlert {
        let locationAlert = NSEntityDescription.insertNewObject(forEntityName: "LocationAlert", into: persistentContainer.viewContext) as! LocationAlert
        
        // Set the properties of the LocationAlert entity
        locationAlert.latitude = locationData.latitude ?? 0
        locationAlert.longitude = locationData.longitude ?? 0
        locationAlert.label = locationData.label
        locationAlert.name = locationData.name
        locationAlert.radius = radius
        
        return locationAlert
    }

    /**
     Adds a new LocationAlert entity to the persistent container with the given Location and radius.
     
     - Parameters:
         - location: The Location object containing latitude, longitude, label, and name information.
         - radius: The radius of the location alert.
     - Returns: The newly created LocationAlert entity.
     */
    func addLocationDataAlert(location: Location, radius: Float) -> LocationAlert {
        let locationAlert = NSEntityDescription.insertNewObject(forEntityName: "LocationAlert", into: persistentContainer.viewContext) as! LocationAlert
        
        // Set the properties of the LocationAlert entity
        locationAlert.latitude = location.latitude
        locationAlert.longitude = location.longitude
        locationAlert.label = location.label
        locationAlert.name = location.name
        locationAlert.radius = radius
        
        return locationAlert
    }

    /**
     Deletes the given LocationAlert entity from the persistent container.
     
     - Parameter locationAlert: The LocationAlert entity to delete.
     */
    func deleteLocationDataAlert(locationAlert: LocationAlert) {
        persistentContainer.viewContext.delete(locationAlert)
    }

    /**
     Deletes the given Location entity from the persistent container.
     
     - Parameter location: The Location entity to delete.
     */
    func deleteLocation(location: Location) {
        persistentContainer.viewContext.delete(location)
    }

    
    /**
     Adds a listener to the database with the provided DatabaseListener.
     
     - Parameter listener: The DatabaseListener to add.
     */
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        // Notify the listener about the current location and location alert lists
        listener.onLocationListChange(locationList: fetchAllLocations())
        listener.onLocationAlertListChange(locationAlertList: fetchAllLocationAlerts())
    }

    /**
     Removes a listener from the database.
     
     - Parameter listener: The DatabaseListener to remove.
     */
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }

    /**
     Adds a new Location entity to the persistent container with the given LocationData.
     
     - Parameter locationData: The LocationData object containing latitude, longitude, label, and name information.
     - Returns: The newly created Location entity.
     */
    func addLocation(locationData: LocationData) -> Location {
        let location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: persistentContainer.viewContext) as! Location
        
        // Set the properties of the Location entity
        location.latitude = locationData.latitude ?? 0
        location.longitude = locationData.longitude ?? 0
        location.label = locationData.label
        location.name = locationData.name
        
        return location
    }

    /**
     Handles the content change event of the fetched results controller.
     Notifies the listeners about the updated location and location alert lists.
     */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Notify listeners about the updated location list
        listeners.invoke { listener in
            listener.onLocationListChange(locationList: fetchAllLocations())
        }
        
        // Notify listeners about the updated location alert list
        listeners.invoke { listener in
            listener.onLocationAlertListChange(locationAlertList: fetchAllLocationAlerts())
        }
    }

    /**
     Saves changes in the persistent container's view context to Core Data.
     If there are changes, the data is saved; otherwise, no action is taken.
     */
    func cleanUp() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data with error \(error)")
            }
        }
    }

    
    // Multicast delegate to manage multiple listeners
    var listeners = MulticastDelegate<DatabaseListener>()
    
    // Core Data persistent container
    var persistentContainer: NSPersistentContainer
    
    // Fetched results controller for Location entity
    var allLocationFetchedResultsController: NSFetchedResultsController<Location>?
    
    // Fetched results controller for LocationAlert entity
    var allLocationAlertFetchedResultsController: NSFetchedResultsController<LocationAlert>?

    /**
     Initializes the database manager and sets up the Core Data persistent container.
     */
    override init() {
        persistentContainer = NSPersistentContainer(name: "LocationDataModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error {
                fatalError("Failed to load Core Data stack with error: \(error)")
            }
        }
        super.init()
    }

    /**
     Fetches all the locations from the database.
     
     - Returns: An array of Location objects.
     */
    func fetchAllLocations() -> [Location] {
        if allLocationFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allLocationFetchedResultsController = NSFetchedResultsController<Location>( fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            allLocationFetchedResultsController?.delegate = self
            
            do {
                try allLocationFetchedResultsController?.performFetch()
                
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        if let locations = allLocationFetchedResultsController?.fetchedObjects {
            return locations
        }
        
        return [Location]()
    }

    /**
     Fetches all the location alerts from the database.
     
     - Returns: An array of LocationAlert objects.
     */
    func fetchAllLocationAlerts() -> [LocationAlert]{
        if allLocationAlertFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<LocationAlert> = LocationAlert.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allLocationAlertFetchedResultsController = NSFetchedResultsController<LocationAlert>( fetchRequest:fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            allLocationAlertFetchedResultsController?.delegate = self
            
            do {
                try allLocationAlertFetchedResultsController?.performFetch()
                
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        if let locationAlerts = allLocationAlertFetchedResultsController?.fetchedObjects {
            return locationAlerts
        }
        
        return [LocationAlert]()
    }

    
    
}
