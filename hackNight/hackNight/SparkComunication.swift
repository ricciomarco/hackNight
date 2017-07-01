//
//  SparkComunication.swift
//  hackNight
//
//  Created by Antonio Russo on 01/07/2017.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import CoreLocation
import Foundation
import SparkSDK

class SparkComunication: ComunicationInterface {
    var spark: Spark!
    var friends = Set<Friend>()
    
    var delegate: ComunicationDelegate?
    
    init() {
        friends.insert(Friend(ID: "capemountainbot@sparkbot.io", name: "Bot di Capodimonte", location: CLLocation(), locationName: "Capodimonte", image: nil, imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Reggia_di_Capodimonte_1.JPG/260px-Reggia_di_Capodimonte_1.JPG"))
    }
    
    func login(loginViewController viewController: UIViewController) {
        let clientId = "C20ec6ebc30814a0db0fe228c26b8ec38ab8bd9ac7678ef3106023a9d6fbfbb9c"
        let clientSecret = "da128e03cf152ca4fa785451c37656b483c23b59141a16a8709ce8b2b883197f"
        let scope = "spark:all"
        let redirectUri = "Sparkdemoapp://response"

        let authenticator = OAuthAuthenticator(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri)
        spark = Spark(authenticator: authenticator)
        
        if !authenticator.authorized {
            authenticator.authorize(parentViewController: viewController) { success in
                if !success {
                    print("User not authorized")
                }
            }
        }
    }
    
    func getFriends() -> [Friend] {
        return Array(friends)
    }
    
    func sendMessage(to friend: Friend, text message: String, completion: @escaping((_ success: Bool) -> Void)) {
        spark.messages.post(personEmail: EmailAddress.fromString(friend.ID)!, text: message, completionHandler: {
            responseMessage in
            completion(true)
        })
    }
}
