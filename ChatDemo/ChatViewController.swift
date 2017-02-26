//
//  ChatViewController.swift
//  ChatDemo
//
//  Created by Dave Vo on 2/25/17.
//  Copyright © 2017 DaveVo. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    var senderName = ""
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    lazy var messageRef: FIRDatabaseReference = FIRDatabase.database().reference().child("messages0217")
    var messageRefHandle: FIRDatabaseHandle?
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "hi \(senderName)"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        observeNewMessages()
    }
    
    deinit {
        if let refHandle = messageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    // MARK: Firebase
    private func observeNewMessages() {
        messageRefHandle = messageRef.observe(.childAdded, with: { (snapshot) in
            let messageData = snapshot.value as! Dictionary<String, Any>
            
            if let name = messageData["sender"] as! String!, name.characters.count > 0 {
                self.messages.append(Message(messageData: messageData))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode message data")
            }
            
        })
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
                "sender": senderName,
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
        
        if senderName == msg.sender {
            msg.sender = "You"
            
            cell.senderLabel.textColor = UIColor.blue
            cell.msgLabel.textColor = UIColor.blue
        }
        cell.message = msg
        
        return cell
    }
}
