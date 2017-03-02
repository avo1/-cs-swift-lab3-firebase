//
//  ChatViewController.swift
//  ChatDemo
//
//  Created by Dave Vo on 2/25/17.
//  Copyright © 2017 DaveVo. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITextFieldDelegate {
    
    var currentUser: FIRUser?
    var senderId: String!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var typingIndicatorLabel: UILabel!
    
    lazy var messageRef: FIRDatabaseReference = FIRDatabase.database().reference().child("messages0217")
    var messageRefHandle: FIRDatabaseHandle?
    
    var messages = [Message]()
    
    // track user typing
    lazy var userIsTypingRef: FIRDatabaseReference = FIRDatabase.database().reference().child("typingIndicator").child(self.senderId)
    lazy var usersTypingQuery: FIRDatabaseQuery =
        FIRDatabase.database().reference().child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = currentUser?.email
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        textField.delegate = self
        
        observeNewMessages()
        observeTyping()
    }
    
    deinit {
        if let refHandle = messageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        usersTypingQuery.removeAllObservers()
    }
    
    // MARK: Firebase
    private func observeNewMessages() {
        messageRefHandle = messageRef.observe(.childAdded, with: { (snapshot) in
            
            let messageDict = snapshot.value as? [String: Any]
            
            if let msgData = messageDict {
                if let email = msgData["email"] as! String!, email.characters.count > 0 {
                    self.messages.append(Message(messageData: msgData))
                    self.tableView.reloadData()
                    let ip = NSIndexPath(row: self.messages.count-1, section: 0) as IndexPath
                    self.tableView.scrollToRow(at: ip, at: UITableViewScrollPosition.top, animated: true)
                }
            } else {
                print("Error! Could not decode message data")
            }

        })
    }
    
    private func observeTyping() {
        usersTypingQuery.observe(.value) { (data: FIRDataSnapshot) in
            // You're the only one typing, don't show the indicator
            //if data.childrenCount == 1 && self.isTyping {
            //    return
            //}
            
            // Are there others typing?
            self.typingIndicatorLabel.isHidden = data.childrenCount < 1
        }
        
        userIsTypingRef.onDisconnectRemoveValue()
    }
    
    // MARK: UITextFieldDelegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        isTyping = newText != ""
        return true
    }
    
    @IBAction func onLogout(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSend(_ sender: UIButton) {
        if let msg = textField?.text {
            if msg == "" {
                //do nothing
                return
            }
            let newMessageRef = messageRef.childByAutoId()
            let messageData: [String: Any] = [
                "senderId": currentUser?.uid ?? "",
                "email": currentUser?.email ?? "",
                "content": msg,
                "createdAt": [".sv": "timestamp"]
            ]
            newMessageRef.setValue(messageData)
            textField.text = ""
            print("new message inserted")
        }
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
        let msg = messages[indexPath.row] as Message
        cell.message = msg
        
        return cell
    }
}
