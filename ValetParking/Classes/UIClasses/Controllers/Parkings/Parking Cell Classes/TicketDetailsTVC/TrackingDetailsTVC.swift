//
//  TrackingDetailsTVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 10/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class TrackingDetailsTVC: UITableViewCell {

    @IBOutlet weak var CarParkedImg: UIImageView!
    @IBOutlet weak var CarPickedImg: UIImageView!
    @IBOutlet weak var PaymentSuccImg: UIImageView!
    @IBOutlet weak var PaymentSuccView: UIView!
    @IBOutlet weak var CarParkedDateLbl: UILabel!
    @IBOutlet weak var CarPickedUpLbl: UILabel!
    @IBOutlet weak var PaymentSuccLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
