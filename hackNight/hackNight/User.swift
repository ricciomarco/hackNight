//
//  User.swift
//  hackNight
//
//  Created by Claudio Santonastaso on 01/07/2017.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import UIKit

class User {
    var image: UIImage?
    var name: String
    var ID: String
    
    var myFriends = Array<Friend>()
    var activeConversations = Array<Conversation>()
    
    
    init(image: UIImage?, name: String, ID: String) {
        self.image = image
        self.name = name
        self.ID = ID
    }
    
    func getInitials() -> String {
        var initialsString = ""
        
        let array = self.name.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for string in array {
            let str = string.uppercased()
            if let initial = str.characters.first {
                initialsString.append(initial)
            }
        }
        
        return initialsString
    }
}
