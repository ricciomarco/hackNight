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
import JSQMessagesViewController

class SparkComunication: ComunicationInterface {
    var spark: Spark!
    var friends = Set<Friend>()
    var roomsToFollow = Set<String>()
    var roomsDispatchQueue = DispatchQueue(label: "Rooms")
    
    var timer = Timer()
    
    var delegate: ComunicationDelegate?
    
    func login(loginViewController viewController: UIViewController, completion: @escaping(()-> (Void))) {
        let clientId = "C20ec6ebc30814a0db0fe228c26b8ec38ab8bd9ac7678ef3106023a9d6fbfbb9c"
        let clientSecret = "da128e03cf152ca4fa785451c37656b483c23b59141a16a8709ce8b2b883197f"
        let scope = "spark:all"
        let redirectUri = "Sparkdemoapp://response"

        let authenticator = OAuthAuthenticator(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri)
        spark = Spark(authenticator: authenticator)
        
        if !authenticator.authorized {
            authenticator.authorize(parentViewController: viewController) { success in
                if !success {
                    print("[SPARK LOGGER] User not authorized")
                }
                self.initAfterLogin(completion: completion)
            }
        } else {
            self.initAfterLogin(completion: completion)
        }
    }
    
    func getFriends() -> [Friend] {
        return Array(friends)
    }
    
    func sendMessage(to friend: Friend, text message: String, completion: @escaping((_ message: Message) -> Void)) {
        spark.messages.post(personEmail: EmailAddress.fromString(friend.ID)!, text: message, completionHandler: {
            responseMessage in
            if let message = responseMessage.result.data {
                if let room = message.roomId {
                    self.roomsToFollow.insert(room)
                }
                completion(message)
            }
        })
    }
    
    private func initAfterLogin(completion: @escaping(() -> Void)) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {
            timer in
            print("[SPARK LOGGER] Verifying last bot messages")
            self.checkRoomsToFollow()
        }
        self.getRoomsWithFriends(completion: completion)
    }
    
    private func checkRoomsToFollow() {
        let rooms = Array(roomsToFollow)
        for r in rooms {
            spark.messages.list(roomId: r, max: 1) {
                responseMessage in
                if let message = responseMessage.result.data?[0] {
                    let friend = self.friends.flatMap({
                        f -> (Friend?) in
                        if f.ID == message.personEmail?.toString() {
                            return f
                        } else {
                            return nil
                        }
                    })
                    if friend.count == 1 {
                        self.delegate?.onNewMessageUpdate(from: friend[0], message: message)
                    } else {
                        print("C'è un problema tra i bot")
                    }
                }
            }
        }
    }
    
    private func getRoomsWithFriends(completion: @escaping(() -> Void)) {
        self.spark.rooms.list(type: RoomType.direct) {
            roomsResponse in
            if let rooms = roomsResponse.result.data {
                for r in rooms {
                    self.roomsToFollow.insert(r.id!)
                    self.friends.insert(BotData.friendByName[r.title!]!)
                }
            }
            self.downloadMessagesHystory(completion: completion)
        }
    }
    
    private func downloadMessagesHystory(completion: @escaping(() -> Void)) {
        let rooms = Array(roomsToFollow)
        print("[SPARK LOGGER] Caricando chat precedenti")
        for r in rooms {
            spark.messages.list(roomId: r) {
                messagesResponse in
                if let messages = messagesResponse.result.data {
                    var jsqMessages = [JSQMessage]()
                    for m in messages {
                        jsqMessages.append(JSQMessage(senderId: m.personEmail!.toString(),
                                                      displayName: m.personEmail!.toString(),
                                                      text: m.text!))
                    }
                    print(jsqMessages)
                    AppManager.sharedManager.currentUser.activeConversations.append(Conversation(friend: self.friends.first!, messages: jsqMessages))
                }
                completion()
            }
        }
    }
}

struct BotData {
    public static let friendByName = [
        "CapeMountainBot": Friend(ID: "capemountainbot@sparkbot.io", name: "Museo di Capodimonte", location: CLLocation(latitude: 37.33155713, longitude: -122.03071078), locationName: "Capodimonte", image: UIImage(named: "Placeholder"), imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Reggia_di_Capodimonte_1.JPG/260px-Reggia_di_Capodimonte_1.JPG")
    ]
}
