//
//  NearbyParkingPlaceCVC.swift
//  ValetParking
//
//  Created by admin on 03/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import AARatingBar

class NearbyParkingPlaceCVC: UICollectionViewCell {
    @IBOutlet weak var placeTitlLbl:UILabel!
    @IBOutlet weak var minuteAwayLbl:UILabel!
    @IBOutlet weak var placeAddressLbl:UILabel!
    @IBOutlet weak var placeImg:UIImageView!
    @IBOutlet weak var shadowView:UIView!
    @IBOutlet weak var bikeImg:UIImageView!
    @IBOutlet weak var carImg:UIImageView!
    @IBOutlet weak var CarPrice: UILabel!
    @IBOutlet weak var BikePrice: UILabel!
    @IBOutlet weak var DistanceImg: UIImageView!
    @IBOutlet weak var DistanceLbl: UILabel!
}
