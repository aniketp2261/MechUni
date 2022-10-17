//
//  CategoryProvidersTVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 13/06/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class CategoryProvidersTVC: UITableViewCell {

    @IBOutlet weak var ShadowView: UIView!
    @IBOutlet weak var ProviderImg: UIImageView!
    @IBOutlet weak var ProviderName: UILabel!
    @IBOutlet weak var FourWheelerImg: UIImageView!
    @IBOutlet weak var TwoWheelerImg: UIImageView!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var AddtocartBtn: UIButton!
    @IBOutlet weak var RemovecartBtn: UIButton!
    @IBOutlet weak var ServiceName: UILabel!
    @IBOutlet weak var ServiceCost: UILabel!
    @IBOutlet weak var PickUpLbl: UILabel!
    @IBOutlet weak var LocationLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        AddtocartBtn.layer.borderColor = UIColor.red.cgColor
        ServiceName.tintColor = .red
        ShadowView.layer.cornerRadius = 15
        ShadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        ShadowView.layer.shadowRadius = 3
        ShadowView.layer.shadowOpacity = 0.3
        ShadowView.layer.shadowColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
