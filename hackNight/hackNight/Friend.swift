//
//  Friend.swift
//  hackNight
//
//  Created by Claudio Santonastaso on 01/07/2017.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import UIKit
import CoreLocation

class Friend: NSObject {
    var ID: String
    var name: String
    
    var location: CLLocation
    var locationName: String
    
    var image: UIImage?
    var imageUrl: String
    
    init(ID: String, name: String, location: CLLocation, locationName: String, image: UIImage?, imageUrl: String) {
        self.ID = ID
        self.name = name
        self.location = location
        self.image = image
        self.imageUrl = imageUrl
        self.locationName = locationName
    }
}
