//
//  VehicleDetailsTVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 03/06/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class VehicleDetailsTVC: UITableViewCell {
    
    @IBOutlet weak var VehicleImgView: UIImageView!
    @IBOutlet weak var VehicleNoLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
