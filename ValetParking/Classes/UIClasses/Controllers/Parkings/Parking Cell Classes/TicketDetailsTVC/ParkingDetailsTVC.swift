//
//  ParkingDetailsTVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 10/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class ParkingDetailsTVC: UITableViewCell {

    @IBOutlet weak var ParkingImgView: UIImageView!
    @IBOutlet weak var platnoLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
