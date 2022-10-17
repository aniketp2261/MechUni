//
//  NearbyServicesCVC.swift
//  MechUni
//
//  Created by Sachin Patil on 10/05/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class NearbyServicesCVC: UICollectionViewCell {
    
    @IBOutlet weak var ShadowView: UIView!
    @IBOutlet weak var ServiceImg: UIImageView!
    @IBOutlet weak var ServiceNameLbl: UILabel!
    @IBOutlet weak var ServiceTimeLbl: UILabel!
    @IBOutlet weak var ServiceAddressLbl: UILabel!
    @IBOutlet weak var pickUpLbl: UILabel!
    @IBOutlet weak var FourWheelerImg: UIImageView!
    @IBOutlet weak var TwoWheelerImg: UIImageView!
    @IBOutlet weak var DistanceImg: UIImageView!
    @IBOutlet weak var DistanceLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ServiceImg.layer.cornerRadius = 10
        ShadowView.layer.cornerRadius = 15
        ShadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        ShadowView.layer.shadowRadius = 3
        ShadowView.layer.shadowOpacity = 0.3
        ShadowView.layer.shadowColor = UIColor.black.cgColor
    }

}
