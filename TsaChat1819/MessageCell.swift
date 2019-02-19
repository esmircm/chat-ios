//
//  MessageCell.swift
//  TsaChat1819
//
//  Created by Marro Gros Gabriel on 25/01/2019.
//  Copyright © 2019 Marro Gros Gabriel. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var bubbleImage: UIImageView?
    @IBOutlet weak var bubbleImageRight: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImage.clipsToBounds = true
        userImage.layer.cornerRadius = userImage.frame.width / 2.0
    
        // userImage.tintColor = UIColor.red
        
        bubbleImage?.image = bubbleImage?.image?.withRenderingMode(.alwaysTemplate)
        bubbleImage?.tintColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        
        bubbleImageRight?.image = bubbleImageRight?.image?.withRenderingMode(.alwaysTemplate)
        bubbleImageRight?.tintColor = UIColor.green
        
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
