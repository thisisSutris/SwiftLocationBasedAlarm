//
//  LocationAlert+CoreDataProperties.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 8/6/2023.
//
//

import Foundation
import CoreData


extension LocationAlert {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationAlert> {
        return NSFetchRequest<LocationAlert>(entityName: "LocationAlert")
    }

    @NSManaged public var radius: Float
    @NSManaged public var name: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var label: String?

}

extension LocationAlert : Identifiable {

}
