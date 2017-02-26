//
//  Message.swift
//  ChatDemo
//
//  Created by Dave Vo on 2/26/17.
//  Copyright © 2017 DaveVo. All rights reserved.
//

import UIKit
import NSDate_TimeAgo

class Message: NSObject {
    var sender: String!
    var content = ""
    var createdAt: Date?
    var timeStamp: String {
        return (createdAt as NSDate?)?.timeAgo() ?? ""
    }
    
    init(messageData: [String: Any]) {
        self.sender = messageData["sender"] as! String
        self.content = messageData["content"] as! String
        self.createdAt = NSDate(timeIntervalSince1970: (messageData["createdAt"] as! Double)/1000) as Date
    }
}
