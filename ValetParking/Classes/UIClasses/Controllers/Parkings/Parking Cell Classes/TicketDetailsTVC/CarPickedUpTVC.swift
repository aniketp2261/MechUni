//
//  CarPickedUpTVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 10/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class CarPickedUpTVC: UITableViewCell {

    @IBOutlet weak var ParkingChargesLbl: UILabel!
    @IBOutlet weak var MinimumParkingChargesLbl: UILabel!
    @IBOutlet weak var TotalParkingHours: UILabel!
    @IBOutlet weak var TotalParkingCharges: UILabel!
    @IBOutlet weak var backView:UIView!
    @IBOutlet weak var DiscountLbl: UILabel!
    @IBOutlet weak var PaidAmountLbl: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var DiscountStackView: UIStackView!
    @IBOutlet weak var PaidAmountStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
