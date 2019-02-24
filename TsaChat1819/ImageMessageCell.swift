//
//  ImageMessageCell.swift
//  TsaChat1819
//
//  Created by Milan Kokic on 17/02/2019.
//  Copyright © 2019 Marro Gros Gabriel. All rights reserved.
//

import Foundation
import UIKit

class ImageMessageCell: UITableViewCell {   
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var imageMessage: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
