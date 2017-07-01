//
//  ComunicationInterface.swift
//  hackNight
//
//  Created by Antonio Russo on 01/07/2017.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import Foundation
import SparkSDK

protocol ComunicationInterface {
    
    var delegate: ComunicationDelegate? { get set }
    
    func getFriends() -> [Friend]
    
    // WARNING: Completion is always called with success = true
    func sendMessage(to friend: Friend, text message: String, completion: @escaping((_ message: Message) -> Void))
}
