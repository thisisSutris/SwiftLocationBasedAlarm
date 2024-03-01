//
//  SearchData.swift
//  I AM HERE
//
//  Created by Sutrisno Macbook on 25/5/2023.
//

import Foundation

class SearchData: NSObject, Decodable{
    
    private enum CodingKeys: String, CodingKey{
        case locations = "data"
        
    }
    
    var locations: [LocationData]?
    
}
