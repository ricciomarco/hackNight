//
//  ComunicationDelegate.swift
//  hackNight
//
//  Created by Antonio Russo on 01/07/2017.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import Foundation
import SparkSDK

protocol ComunicationDelegate {
    func onNewMessageUpdate(from friend: Friend, message: Message)
}
