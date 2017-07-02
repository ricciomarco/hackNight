//
//  ConversationViewController.swift
//  hackNight
//
//  Created by Claudio Santonastaso on 01/07/2017.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SparkSDK

class ConversationViewController: JSQMessagesViewController {

    var conversation: Conversation?

    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    override func viewWillAppear(_ animated: Bool) {
        assert((conversation != nil), "Conversation is nil")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = conversation?.friend.name
        
        self.senderId = AppManager.sharedManager.currentUser.ID
        self.senderDisplayName = AppManager.sharedManager.currentUser.name
        self.automaticallyScrollsToMostRecentMessage = true

        incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegular(), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: UIColor.blue)
        outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegular(), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: UIColor.red)
        
        // Do any additional setup after loading the view.

        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(forName: Notification.Name(rawValue: "ConversationUpdate"), object: (conversation?.friend)!, queue: nil) {
            notification in
            if let isUserSending = notification.userInfo?["isUserSending"] {
                self.conversation?.messages.append(JSQMessage(senderId: AppManager.sharedManager.currentUser.ID, displayName: AppManager.sharedManager.currentUser.name, text: notification.userInfo!["text"] as! String))
                self.collectionView.reloadData()
            } else {
                if (self.conversation?.messages.last)!.text != notification.userInfo!["text"] as! String {
                    self.conversation?.messages.append(JSQMessage(senderId: (self.conversation?.friend.ID)!, displayName: (self.conversation?.friend.name)!, text: notification.userInfo!["text"] as! String))
                    self.collectionView.reloadData()
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return conversation!.messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversation!.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        
        return conversation!.messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        
        let initials = conversation!.messages[indexPath.item].senderId == self.senderId ? "XX" : AppManager.sharedManager.currentUser.getInitials()
        return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials,
                                                         backgroundColor: UIColor.blue,
                                                         textColor: UIColor.white,
                                                         font: UIFont(name: "Arial", size: 17),
                                                         diameter: 32)

    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        AppManager.sharedManager.sparkService.sendMessage(to: conversation!.friend, text: text) {
            message in
            let nc = NotificationCenter.default
            nc.post(name:Notification.Name(rawValue: "ConversationUpdate"),
                    object: (self.conversation?.friend)!,
                    userInfo: [
                        "isUserSending": true,
                        "text": message.text!
                ])
            self.inputToolbar.contentView.textView.text = ""
        }
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
