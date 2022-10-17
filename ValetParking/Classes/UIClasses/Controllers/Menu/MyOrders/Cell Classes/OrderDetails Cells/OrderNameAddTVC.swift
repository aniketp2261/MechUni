//
//  OrderNameAddTVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 03/06/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class OrderNameAddTVC: UITableViewCell {
    
    @IBOutlet weak var ProviderAddressLbl: UILabel!
    @IBOutlet weak var ProviderNameLbl: UILabel!
    @IBOutlet weak var CallImgView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        ProviderAddressLbl.superview?.layer.shadowColor = UIColor.black.cgColor
        ProviderAddressLbl.superview?.layer.shadowOffset = CGSize(width: 0, height: 3)
        ProviderAddressLbl.superview?.layer.shadowOpacity = 0.3
        ProviderAddressLbl.superview?.layer.shadowRadius = 3.0
        ProviderAddressLbl.superview?.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
