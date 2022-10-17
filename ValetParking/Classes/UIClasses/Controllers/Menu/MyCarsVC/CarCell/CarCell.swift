//
//  CarCell.swift
//  ValetParking
//
//  Created by Khushal on 21/11/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit

class CarCell: UITableViewCell {
    

    @IBOutlet weak var EditDeleteStackView: UIStackView!
    @IBOutlet weak var mEditBtn: UIImageView!
    @IBOutlet weak var mDelete: UIImageView!
    @IBOutlet weak var selectBtn:UIButton!
    @IBOutlet weak var carNumberLbl:UILabel!
    @IBOutlet weak var vehicleTypeLbl:UILabel!
    @IBOutlet weak var vehicleImg:UIImageView!
    @IBOutlet weak var VehicleTypeImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectBtn.isHidden = true
        selectBtn.layer.borderWidth = 1
        selectBtn.layer.borderColor = UIColor.red.cgColor
        selectBtn.layer.cornerRadius = selectBtn.bounds.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
