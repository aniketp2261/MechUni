//
//  ParkingPlaceTVC.swift
//  ValetParking
//
//  Created by Aniket Patil on 07/09/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class ParkingPlaceTVC: UITableViewCell {

    @IBOutlet weak var placeTitlLbl: UILabel!
    @IBOutlet weak var minuteAwayLbl: UILabel!
    @IBOutlet weak var placeAddressLbl: UILabel!
    @IBOutlet weak var placeImg: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var bikeImg: UIImageView!
    @IBOutlet weak var carImg: UIImageView!
    @IBOutlet weak var CarPrice: UILabel!
    @IBOutlet weak var BikePrice: UILabel!
    @IBOutlet weak var DistanceImg: UIImageView!
    @IBOutlet weak var DistanceLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shadowView.layer.cornerRadius = 15
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
