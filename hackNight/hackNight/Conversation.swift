//
//  Conversation.swift
//  hackNight
//
//  Created by Claudio Santonastaso on 01/07/2017.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class Conversation {
    var friendID: String
    var messages = Array<JSQMessage>()
    
    init(friendID: String, messages: [JSQMessage]) {
        self.friendID = friendID
        self.messages = messages
    }
}
