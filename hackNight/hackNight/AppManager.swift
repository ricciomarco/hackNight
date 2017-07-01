//
//  AppManager.swift
//  hackNight
//
//  Created by Claudio Santonastaso on 01/07/2017.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import CoreLocation
import UIKit
import JSQMessagesViewController

let DEBUG_FLAG = true

final class AppManager: NSObject, CLLocationManagerDelegate {
    static let sharedManager = AppManager()

    var currentUser: User
    var sparkService = SparkComunication()
    let locationManager = CLLocationManager()
    
    private override init() {
        
        self.currentUser = User(image: nil, name: "Claudio Santonastaso", ID: "01")

        super.init()
        
        locationManager.delegate = self
        // 2
        locationManager.requestAlwaysAuthorization()
        
        
        
        
        
        if DEBUG_FLAG {
            let conversations = [Conversation(friend: Friend(ID: "12345",
                                                             name: "Il mio Bot",
                                                             location: CLLocationCoordinate2D(latitude: 1.0,
                                                                                              longitude: 1.0),
                                                             locationName: "Bosco di Capodimonte",
                                                             image: UIImage(named: "Placeholder"),
                                                             imageUrl: "urlACazzo"),
                                 messages: [JSQMessage(senderId: self.currentUser.ID,
                                                       displayName: self.currentUser.name,
                                                       text: "aòlsjda kls dalsjd alksd as"),
                                            JSQMessage(senderId: "12345",
                                                       displayName: "Altro", 
                                                       text: "alsdalnskads lkasndadlkn asldkn dknsl !!!")])]
            currentUser.activeConversations = conversations
        }
    }
    
    
    
}
