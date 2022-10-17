//
//  AllSearchTVC.swift
//  MechUni
//
//  Created by Aniket Patil on 10/10/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class AllSearchTVC: UITableViewCell {
    @IBOutlet weak var ServiceView: UIView!
    @IBOutlet weak var ProviderView: UIView!
    @IBOutlet weak var ParkingView: UIView!
    
    @IBOutlet weak var ServiceImg: UIImageView!
    @IBOutlet weak var ServiceNameLbl: UILabel!
    @IBOutlet weak var ServiceDescLbl: UILabel!
    
    @IBOutlet weak var ProviderImg: UIImageView!
    @IBOutlet weak var ProviderNameLbl: UILabel!
    @IBOutlet weak var ProviderDisLbl: UILabel!
    @IBOutlet weak var ProviderTimeLbl: UILabel!
    @IBOutlet weak var ProviderPickUpLbl: UILabel!
    @IBOutlet weak var ProviderCarImg: UIImageView!
    @IBOutlet weak var ProviderBikeImg: UIImageView!
    @IBOutlet weak var ProviderAddLbl: UILabel!
    
    @IBOutlet weak var ParkingImg: UIImageView!
    @IBOutlet weak var ParkingNameLbl: UILabel!
    @IBOutlet weak var ParkingDisLbl: UILabel!
    @IBOutlet weak var ParkingTimeLbl: UILabel!
    @IBOutlet weak var ParkingCarImg: UIImageView!
    @IBOutlet weak var ParkingCarHrsLbl: UILabel!
    @IBOutlet weak var ParkingBikeImg: UIImageView!
    @IBOutlet weak var ParkingBikeHrsLbl: UILabel!
    @IBOutlet weak var ParkingAddLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ServiceView.layer.cornerRadius = 15
        ServiceView.layer.shadowOffset = CGSize(width: 0, height: 3)
        ServiceView.layer.shadowRadius = 3
        ServiceView.layer.shadowOpacity = 0.3
        ProviderView.layer.shadowColor = UIColor.black.cgColor
        
        ProviderView.layer.cornerRadius = 15
        ProviderView.layer.shadowOffset = CGSize(width: 0, height: 3)
        ProviderView.layer.shadowRadius = 3
        ProviderView.layer.shadowOpacity = 0.3
        ProviderView.layer.shadowColor = UIColor.black.cgColor
        
        ParkingView.layer.cornerRadius = 15
        ParkingView.layer.shadowOffset = CGSize(width: 0, height: 3)
        ParkingView.layer.shadowRadius = 3
        ParkingView.layer.shadowOpacity = 0.3
        ParkingView.layer.shadowColor = UIColor.black.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
