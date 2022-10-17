//
//  ProviderServicesTVC.swift
//  MechUni
//
//  Created by Sachin Patil on 24/05/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class ProviderServicesTVC: UITableViewCell {
    
    @IBOutlet weak var ServiceImg: UIImageView!
    @IBOutlet weak var ServiceName: UILabel!
    @IBOutlet weak var ServiceDetail: UILabel!
    @IBOutlet weak var ServiceCost: UILabel!
    @IBOutlet weak var CarImg: UIImageView!
    @IBOutlet weak var BikeImg: UIImageView!
    @IBOutlet weak var PickupImg: UIImageView!
    @IBOutlet weak var AddCartBtn: UIButton!
    @IBOutlet weak var DeleteCartBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        AddCartBtn.layer.borderColor = UIColor.red.cgColor
        ServiceImg.superview?.layer.cornerRadius = 15
        ServiceImg.superview?.layer.shadowOffset = CGSize(width: 0, height: 3)
        ServiceImg.superview?.layer.shadowRadius = 3
        ServiceImg.superview?.layer.shadowOpacity = 0.3
        ServiceImg.superview?.layer.shadowColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
