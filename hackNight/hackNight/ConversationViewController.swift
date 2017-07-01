//
//  ConversationViewController.swift
//  hackNight
//
//  Created by Claudio Santonastaso on 01/07/2017.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ConversationViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()

    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = AppManager.sharedManager.currentUser.ID
        self.senderDisplayName = "IO"
        
        let message = JSQMessage(senderId: self.senderId, displayName: "IO", text: "aòlsjda kls dalsjd alksd as")
        let message2 = JSQMessage(senderId: "654321", displayName: "Altro", text: "alsdalnskads lkasndadlkn asldkn dknsl !!!")
        
        messages.append(message!)
        messages.append(message2!)

        incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegular(), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: UIColor.blue)
        outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegular(), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: UIColor.red)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        
        return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        
        let initials = messages[indexPath.item].senderId == self.senderId ? "XX" : AppManager.sharedManager.currentUser.getInitials()
        return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials,
                                                         backgroundColor: UIColor.blue,
                                                         textColor: UIColor.white,
                                                         font: UIFont(name: "Arial", size: 17),
                                                         diameter: 32)

    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
