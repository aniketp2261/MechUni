//
//  NotificationCell.swift
//  ValetParking
//
//  Created by Khushal on 23/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var mDescriptionLabel: UILabel!
    
    @IBOutlet weak var mTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
