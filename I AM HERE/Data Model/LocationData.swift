//
//  LocationData.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 25/5/2023.
//

import Foundation

class LocationData: NSObject, Decodable{
    var latitude : Double?
    var longitude: Double?
    var label: String?
    var name: String?
    
    private enum LocationKeys: String, CodingKey{
        case latitude
        case longitude
        case label
        case name
    }
    
    
    required init(from decoder: Decoder) throws {
        let locationContainer = try decoder.container(keyedBy: LocationKeys.self)
        latitude = try locationContainer.decode(Double.self, forKey: .latitude)
        longitude = try locationContainer.decode(Double.self, forKey: .longitude)
        label = try locationContainer.decode(String.self, forKey: .label)
        name = try locationContainer.decode(String.self, forKey: .name)
    }
}
