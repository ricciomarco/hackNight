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
import PKHUD
import PopupDialog

class ConversationViewController: JSQMessagesViewController, JSQMessagesKeyboardControllerDelegate {

    var shadowView2: UIView?
    var observer: NSObjectProtocol?

    var shouldShowError = true
    var conversation: Conversation?

    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    
    let sendingColor = UIColor(colorLiteralRed: 247/255.0, green: 203/255.0, blue: 87/255.0, alpha: 1.0)
    let incomingColor = UIColor(colorLiteralRed: 136/255.0, green: 137/255.0, blue: 142/255.0, alpha: 1.0)

    
    override func viewWillAppear(_ animated: Bool) {
        assert((conversation != nil), "Conversation is nil")
        
        AppManager.sharedManager.sparkService.spark.phone.register() { error in
            if let error = error {
                print("___Device Not Registered")
                // Device not registered, and calls will not be sent or received
            } else {
                print("___Device Registered")

                // Device registered
            }
        }
        
    }
    
    func keyboardController(_ keyboardController: JSQMessagesKeyboardController!, keyboardDidChangeFrame keyboardFrame: CGRect) {
        print("lakdnslkdnalksdn")
        var rect = self.collectionView.frame
        rect.origin.y = keyboardFrame.origin.y - rect.size.height
        self.collectionView.frame = rect
        
        rect = self.inputToolbar.frame
        rect.origin.y = keyboardFrame.origin.y - rect.size.height
        self.inputToolbar.frame = rect
    }
    
    @IBAction func operatorCallPressed() {
        print("BeginningCall")
        if AppManager.sharedManager.userIsCloseTo(location: (self.conversation?.friend.location)!, maxDistance: 100) {
            HUD.show(.labeledProgress(title: "Attendere", subtitle: "Contattando la Guida"))
            
            let address = "claudio.santonastaso@gmail.com"
            let mediaOption = MediaOption.audioOnly()
            
            AppManager.sharedManager.sparkService.spark.phone.dial(address, option:mediaOption) { ret in
                switch ret {
                case .success(let call):
                    // success
                    call.onConnected = {
                        print("___Connected")
                        HUD.flash(.success, delay: 1.0)
                        HUD.flash(.success, onView: self.view, delay: 0.0, completion: { (bool) in
                            let title = call.to?.email ?? ""
                            let message = "Chiamata in corso"
                            let image = self.conversation?.friend.image
                            
                            // Create the dialog
                            let popup = PopupDialog(title: title, message: message, image: image, buttonAlignment: UILayoutConstraintAxis.vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, gestureDismissal: false, completion: nil)
                            
                            // Create buttons
                            let buttonOne = CancelButton(title: "Riaggancia") {
                                print("You canceled the car dialog.")
                                if call.status == CallStatus.connected {
                                    self.shouldShowError = false
                                    call.hangup(completionHandler: { (error) in
                                        popup.dismiss()
                                        self.shouldShowError = true
                                    })
                                }
                            }
                            
                            // Add buttons to dialog
                            // Alternatively, you can use popup.addButton(buttonOne)
                            // to add a single button
                            popup.addButtons([buttonOne])
                            
                            // Present dialog
                            self.present(popup, animated: true, completion: nil)
                        })
                        
                    }
                    call.onDisconnected = { reason in
                        print("___Disconnected")
                        if self.shouldShowError {
                            HUD.flash(.error , delay: 1.0)
                        }
                    }
                case .failure(let error):
                    print(error)
                    break
                    // failure
                }
            }
            
        } else {
            let alertController = UIAlertController(title: "Non Disponibile", message: "Devi essere vicino alla statua per poter usufruire di una guida", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Annulla", style: UIAlertActionStyle.cancel) {
                (result : UIAlertAction) -> Void in
            }
            
            let okAction = UIAlertAction(title: "Direzioni", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
                
                let regionDistance:CLLocationDistance = 10000
                let coordinates = self.conversation?.friend.location.coordinate
                let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates!, regionDistance, regionDistance)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                ]
                let placemark = MKPlacemark(coordinate: coordinates!, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = self.conversation?.friend.name
                mapItem.openInMaps(launchOptions: options)
                
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.scrollToBottom(animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.keyboardController.beginListeningForKeyboard()
        self.keyboardController.delegate = self
        
        
        self.title = conversation?.friend.name
        
        
        
        shadowView2 = UIView(frame: CGRect(x: 0, y: 63, width: self.view.frame.size.width, height: 1))
        self.view.addSubview(shadowView2!)
        self.view.bringSubview(toFront: shadowView2!)
        shadowView2?.backgroundColor = UIColor.red
        shadowView2?.layer.shadowColor = UIColor.black.cgColor
        shadowView2?.layer.shadowOpacity = 1.0
        shadowView2?.layer.shadowRadius = 4
        shadowView2?.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView2?.layer.masksToBounds = false
        
        let color = UIColor(colorLiteralRed: 201/255.0, green: 116/255.0, blue: 28/255.0, alpha: 1.0)

        
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.rightBarButtonItem.setTitleColor(color, for: UIControlState.normal)
        
        self.senderId = AppManager.sharedManager.currentUser.ID
        self.senderDisplayName = AppManager.sharedManager.currentUser.name
        self.automaticallyScrollsToMostRecentMessage = true

        self.navigationController?.navigationBar.tintColor = color
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : color]
        
        
        incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegular(), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: incomingColor)
        outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegular(), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: sendingColor)
        
        // Do any additional setup after loading the view.

        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        observer = nc.addObserver(forName: Notification.Name(rawValue: "ConversationUpdate"), object: (conversation?.friend)!, queue: nil) {
            notification in
            if let isUserSending = notification.userInfo?["isUserSending"] {
                self.conversation?.messages.append(JSQMessage(senderId: AppManager.sharedManager.currentUser.ID, displayName: AppManager.sharedManager.currentUser.name, text: notification.userInfo!["text"] as! String))
                self.collectionView.reloadData()
                self.scrollToBottom(animated: true)
            } else {
                if (self.conversation?.messages.last)!.text != notification.userInfo?["text"] as! String {
                    if self.conversation!.friend == notification.object as! Friend {
                        self.conversation?.messages.append(JSQMessage(senderId: (self.conversation?.friend.ID)!, displayName: (self.conversation?.friend.name)!, text: notification.userInfo!["text"] as! String))
                        self.collectionView.reloadData()
                        self.scrollToBottom(animated: true)

                    }
                }
            }
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.removeObserver(observer!)
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
        let isBot = conversation!.messages[indexPath.item].senderId == self.senderId ? false : true
        
        if isBot {
            return JSQMessagesAvatarImageFactory.avatarImage(with: conversation?.friend.image, diameter: 48)
        } else {
            return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: AppManager.sharedManager.currentUser.getInitials(),
                                                             backgroundColor: sendingColor,
                                                             textColor: UIColor.white,
                                                             font: UIFont(name: "Arial", size: 17),
                                                             diameter: 48)
        }
        

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
