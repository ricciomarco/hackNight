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
    var friend: Friend
    var messages = Array<JSQMessage>()
    
    init(friend: Friend, messages: [JSQMessage]) {
        self.friend = friend
        self.messages = messages
    }
}
