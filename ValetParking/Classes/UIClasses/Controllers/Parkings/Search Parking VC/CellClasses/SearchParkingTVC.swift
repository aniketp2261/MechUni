//
//  SearchParkingTVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 12/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import AARatingBar

class SearchParkingTVC: UITableViewCell {
    @IBOutlet weak var placeTitlLbl:UILabel!
    @IBOutlet weak var minuteAwayLbl:UILabel!
    @IBOutlet weak var parkingPlaceChargesLbl:UILabel!
    @IBOutlet weak var placeAddressLbl:UILabel!
    @IBOutlet weak var placeImg:UIImageView!
    @IBOutlet weak var shadowView:UIView!
    @IBOutlet weak var bikeImg:UIImageView!
    @IBOutlet weak var carImg:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
