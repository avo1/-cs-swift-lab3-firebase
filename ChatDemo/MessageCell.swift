//
//  MessageCell.swift
//  ChatDemo
//
//  Created by Dave Vo on 2/26/17.
//  Copyright © 2017 DaveVo. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var message: Message! {
        didSet {
            senderLabel.text = message.senderEmail
            msgLabel.text = message.content
            timeLabel.text = message.timeStamp
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
