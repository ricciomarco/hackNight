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
    var friendsList = Array<Friend>()
    var friendsNearMe = Set<Friend>()
    
    private override init() {
        
        self.currentUser = User(image: nil, name: "Claudio Santonastaso", ID: "01")

        super.init()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        friendsList = sparkService.getFriends()
        

        if DEBUG_FLAG {
            let conversations = [Conversation(friend: Friend(ID: "capemountainbot@sparkbot.io",
                                                             name: "Il mio Bot",
                                                             location: CLLocation(latitude: 1.0,
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for friend in friendsList {
            if userIsCloseTo(location: friend.location, maxDistance: 100) {
                print("Adding")

                friendsNearMe.insert(friend)
                
                let nc = NotificationCenter.default
                nc.post(name:Notification.Name(rawValue:"FriendListUpdated"),
                        object: nil,
                        userInfo: nil )
            } else {
                print("Removing")
                friendsNearMe.remove(friend)
                
                let nc = NotificationCenter.default
                nc.post(name:Notification.Name(rawValue:"FriendListUpdated"),
                        object: nil,
                        userInfo: nil )
            }
        }
    }
    
    func userIsCloseTo(location: CLLocation, maxDistance: Double) ->Bool {
        print("User Location = \(locationManager.location!)")
        print("Friend Location = \(location)")
        let distance = (locationManager.location?.distance(from: location))!
        print(distance)
        return distance < maxDistance
    }
    
    
}
