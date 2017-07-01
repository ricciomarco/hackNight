//
//  ViewController.swift
//  hackNight
//
//  Created by Marco Riccio on 01/07/17.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import UIKit




class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var tabelView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var hideCollectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var showCollectionConstraint: NSLayoutConstraint!
    
    var availableFriends = Array<Friend>()
    var conversationsArray = Array<Conversation>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.perform(#selector(showCollection), with: nil, afterDelay: 1.0)
        conversationsArray = AppManager.sharedManager.currentUser.activeConversations
        // Do any additional setup after loading the view, typically from a nib.
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
            
            dateFormatter.dateFormat = "dd/MM/yyyy"
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
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
}

