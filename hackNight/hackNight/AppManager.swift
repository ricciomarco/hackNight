//
//  AppManager.swift
//  hackNight
//
//  Created by Claudio Santonastaso on 01/07/2017.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import Foundation

final class AppManager {
    static let sharedManager = AppManager()

    var currentUser: User
    
    private init() {
        currentUser = User(image: nil, name: "Claudio Santonastaso", ID: "01")
    }
    
}
