//
//  Alert+CoreDataProperties.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 8/6/2023.
//
//

import Foundation
import CoreData


extension Alert {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Alert> {
        return NSFetchRequest<Alert>(entityName: "Alert")
    }

    @NSManaged public var radius: Double
    @NSManaged public var name: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var label: String?

}

extension Alert : Identifiable {

}
