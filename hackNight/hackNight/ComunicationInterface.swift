//
//  ComunicationInterface.swift
//  hackNight
//
//  Created by Antonio Russo on 01/07/2017.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import Foundation

protocol ComunicationInterface {
    
    var delegate: ComunicationDelegate? { get set }
    
    func getFriends() -> [Friend]
    func sendMessage(to: Friend, completion: @escaping((_ success: Bool) -> Void))
}
