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
    var friends = Dictionary<String, Friend>()
    var roomsToFollow = Dictionary<String, Room>()
    
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
        return Array(friends.values)
    }
    
    func sendMessage(to friend: Friend, text message: String, completion: @escaping((_ message: Message) -> Void)) {
        spark.messages.post(personEmail: EmailAddress.fromString(friend.ID)!, text: message, completionHandler: {
            responseMessage in
            if let message = responseMessage.result.data {
                if let roomId = message.roomId {
                    self.spark.rooms.get(roomId: roomId) {
                        roomResponse in
                        if let room = roomResponse.result.data {
                            self.roomsToFollow[roomId] = room
                        }
                    }
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
        let rooms = Array(roomsToFollow.values)
        for r in rooms {
            spark.messages.list(roomId: r.id!, max: 1) {
                responseMessage in
                if let message = responseMessage.result.data?[0] {
                    if let friend = self.friends[(message.personEmail?.toString())!] {
                        self.delegate?.onNewMessageUpdate(from: friend, message: message)
                    } else {
                        print("[SPARK LOGGER] Nessuna risposta dal bot")
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
                    self.roomsToFollow[r.id!] = r
                    let friend = BotData.friendByName[r.title!]!
                    self.friends[friend.ID] = friend
                }
            }
            self.downloadMessagesHystory(completion: completion)
        }
    }
    
    private func downloadMessagesHystory(completion: @escaping(() -> Void)) {
        let rooms = Array(roomsToFollow.values)
        print("[SPARK LOGGER] Caricando chat precedenti")
        for r in rooms {
            spark.messages.list(roomId: r.id!) {
                messagesResponse in
                if let messages = messagesResponse.result.data {
                    var jsqMessages = [JSQMessage]()
                    for m in messages {
                        jsqMessages.insert(JSQMessage(senderId: m.personEmail!.toString(),
                                                      displayName: m.personEmail!.toString(),
                                                      text: m.text!), at: 0)
                    }
                    if let friend = self.friends[BotData.friendByName[r.title!]!.ID] {
                        AppManager.sharedManager.currentUser.activeConversations.append(Conversation(friend: friend, messages: jsqMessages))
                    }
                }
                completion()
            }
        }
    }
}

struct BotData {
    public static let friendByName = [
        "CapeMountainBot": Friend(ID: "capemountainbot@sparkbot.io", name: "Museo di Capodimonte", location: CLLocation(latitude: 37.33155713, longitude: -122.03071078), locationName: "Capodimonte", image: UIImage(named: "Placeholder"), imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Reggia_di_Capodimonte_1.JPG/260px-Reggia_di_Capodimonte_1.JPG"),
        "StatuaDelGigante": Friend(ID: "statuadelgigante@sparkbot.io", name: "Statua del Gigante", location: CLLocation(latitude: 37.33155713, longitude: -122.03071078), locationName: "Capodimonte", image: UIImage(named: "Placeholder"), imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Reggia_di_Capodimonte_1.JPG/260px-Reggia_di_Capodimonte_1.JPG")
    ]
}
