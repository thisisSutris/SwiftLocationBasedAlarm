//
//  DatabaseProtocol.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 25/5/2023.
//

import Foundation

protocol DatabaseListener: AnyObject {
    
    func onLocationListChange(locationList: [Location])
    
    func onLocationAlertListChange(locationAlertList: [LocationAlert])
    
}

protocol DatabaseProtocol: AnyObject {
    func addListener(listener: DatabaseListener)
    
    func removeListener(listener: DatabaseListener)
    
    func addLocation(locationData: LocationData) -> Location
    
    func deleteLocation(location: Location)
    
    func addLocationDataAlert(locationData: LocationData, radius: Float) -> LocationAlert
    
    func addLocationDataAlert(location: Location, radius: Float) -> LocationAlert
    
    func deleteLocationDataAlert(locationAlert: LocationAlert)

    func cleanUp()
}
