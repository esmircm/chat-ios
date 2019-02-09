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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImage.clipsToBounds = true
        userImage.layer.cornerRadius = userImage.frame.width / 2.0
        
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
