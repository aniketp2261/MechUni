//
//  NearbyServicesTVC.swift
//  MechUni
//
//  Created by Sachin Patil on 11/05/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class NearbyServicesTVC: UITableViewCell {
    
    @IBOutlet weak var ServiceCategoryName: UILabel!
    @IBOutlet weak var ServiceCategoryImg: UIImageView!
    @IBOutlet weak var TwoWheelerImg2: UIImageView!
    @IBOutlet weak var FourWheelerImg2: UIImageView!
    @IBOutlet weak var ServicesView: UIView!
    @IBOutlet weak var CategoryView: ShadowView!
    @IBOutlet weak var ServiceImg: UIImageView!
    @IBOutlet weak var ServiceNameLbl: UILabel!
    @IBOutlet weak var ServiceTimeLbl: UILabel!
    @IBOutlet weak var ServicePickUpLbl: UILabel!
    @IBOutlet weak var ServiceAddressLbl: UILabel!
    @IBOutlet weak var TotalCostLbl: UILabel!
    @IBOutlet weak var FourWheelerImg: UIImageView!
    @IBOutlet weak var TwoWheelerImg: UIImageView!
    @IBOutlet weak var DistanceImg: UIImageView!
    @IBOutlet weak var DistanceLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
