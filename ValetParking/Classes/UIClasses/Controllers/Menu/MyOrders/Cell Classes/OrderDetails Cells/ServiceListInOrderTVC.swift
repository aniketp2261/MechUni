//
//  ServiceListInOrderTVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 04/08/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class ServiceListInOrderTVC: UITableViewCell {

    @IBOutlet weak var ServiceName: UILabel!
    @IBOutlet weak var ServiceCost: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
