//
//  ViewController.swift
//  hackNight
//
//  Created by Marco Riccio on 01/07/17.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import UIKit
import SparkSDK
import JSQMessagesViewController


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var shadowView: UIView!

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var tabelView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var hideCollectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var showCollectionConstraint: NSLayoutConstraint!
    
    var availableFriends = Array<Friend>()
    var conversationsArray: Array<Conversation> {
        return AppManager.sharedManager.currentUser.activeConversations
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabelView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
        let newConvID = AppManager.sharedManager.openConversationByBotID
        
        if newConvID.characters.count > 0 {
            
            openConversationBy(ID: newConvID)
            AppManager.sharedManager.openConversationByBotID = ""
        }
    }
    
    func openConversationBy(ID:String) {
        let conversationController = UIStoryboard.init(name: "Conversation", bundle: Bundle.main).instantiateInitialViewController() as! ConversationViewController
        
        if let conversation = AppManager.sharedManager.conversationByBot(ID: ID) {
            conversationController.conversation = conversation
        } else {
            if let friend = AppManager.sharedManager.friend(ID: ID) {
                conversationController.conversation = Conversation(friend: friend,
                                                                   messages: Array<JSQMessage>())
                conversationController.didPressSend(nil, withMessageText: "Hello",
                                                    senderId: AppManager.sharedManager.currentUser.ID,
                                                    senderDisplayName: AppManager.sharedManager.currentUser.name,
                                                    date: Date())
                AppManager.sharedManager.currentUser.activeConversations.append(conversationController.conversation!)
            }
            
        }
        
        
        self.navigationController?.pushViewController(conversationController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tabelView.tableFooterView = UIView()
        AppManager.sharedManager.sparkService.login(loginViewController: self) {
            DispatchQueue.main.async {
                self.tabelView.reloadData()
            }
            AppManager.sharedManager.friendsList = AppManager.sharedManager.sparkService.getFriends()
        }
        //self.perform(#selector(showCollection), with: nil, afterDelay: 1.0)
//        conversationsArray = AppManager.sharedManager.currentUser.activeConversations
        
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.8
        shadowView.layer.shadowRadius = 2
        shadowView.layer.shadowOffset = CGSize(width: 0, height: -2)
        shadowView.layer.masksToBounds = false
        
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(forName:Notification.Name(rawValue:"FriendListUpdated"),
                       object:nil, queue:nil) {
                        notification in
                        let newArray = Array(AppManager.sharedManager.friendsNearMe)
                        if self.availableFriends.count != newArray.count {
                            self.availableFriends = newArray
                            self.collectionView.reloadData()
                            
                            if self.availableFriends.count > 0 {
                                self.showCollection()
                                print("Show Collection")
                            } else {
                                print("Hide Collection")

                                self.hideCollection()
                            }
                        }
                        
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func newFriendIn(array: Array<Friend>) -> Bool {
        for friend in array {
            if !self.availableFriends.contains(friend) {
                print("True")

                return true
            }
        }
        print("False")

        return false
    }
    
    func showCollection() {
        self.view.removeConstraint(hideCollectionConstraint)
        self.view.addConstraint(showCollectionConstraint)

        UIView.setAnimationCurve(UIViewAnimationCurve.easeInOut)
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }

    func hideCollection() {
        print("hideCollection")
//        self.showCollectionConstraint.constant = -95
        
        self.view.removeConstraint(showCollectionConstraint)
        self.view.addConstraint(hideCollectionConstraint)
        
        UIView.setAnimationCurve(UIViewAnimationCurve.easeInOut)
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return conversationsArray.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ConversationTableViewCell
     
        let conversation = conversationsArray[indexPath.row]
        let friend = conversation.friend
        
        cell.locationLabel.text = friend.locationName
        cell.nameLabel.text = friend.name
        
        cell.profileImageView.image = friend.image

        if let lastMessage = conversation.messages.last {
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "dd/MM/yy"
            let dateString = dateFormatter.string(from:lastMessage.date)
            cell.dateLabel.text = dateString
            
            cell.lastMessageLabel.text = lastMessage.text
            
        }
        
     // Configure the cell...
     
     return cell
     }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationController = UIStoryboard.init(name: "Conversation", bundle: Bundle.main).instantiateInitialViewController() as! ConversationViewController
        
        conversationController.conversation = conversationsArray[indexPath.row]
        
        self.navigationController?.pushViewController(conversationController, animated: true)
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return availableFriends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath) as! NearMeCollectionViewCell
        
        // Configure the cell
        
        let friend = availableFriends[indexPath.row]
        
        if let image = friend.image {
            cell.imageView.image = image
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openConversationBy(ID: availableFriends[indexPath.row].ID)
    }
    
    
}

