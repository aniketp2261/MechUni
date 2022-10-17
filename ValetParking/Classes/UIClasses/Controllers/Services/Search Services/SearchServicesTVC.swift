//
//  SearchServicesTVC.swift
//  MechUni
//
//  Created by Sachin Patil on 04/07/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class SearchServicesTVC: UITableViewCell {
    
    @IBOutlet weak var ServiceView: UIView!
    @IBOutlet weak var ProviderView: UIView!
    
    @IBOutlet weak var ServiceNameLbl: UILabel!
    @IBOutlet weak var ServiceImg: UIImageView!
    @IBOutlet weak var ServiceDescrip: UILabel!
    
    @IBOutlet weak var ProviderNameLbl: UILabel!
    @IBOutlet weak var ProviderImg: UIImageView!
    @IBOutlet weak var ProviderTimeLbl: UILabel!
    @IBOutlet weak var ProviderAddLbl: UILabel!
    @IBOutlet weak var TwoWheelImg: UIImageView!
    @IBOutlet weak var FourWheelImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        ServiceView.layer.cornerRadius = 15
        ServiceView.layer.shadowOffset = CGSize(width: 0, height: 4)
        ServiceView.layer.shadowRadius = 3
        ServiceView.layer.shadowOpacity = 0.3
        ServiceView.layer.shadowColor = UIColor.black.cgColor
        
        ProviderView.layer.cornerRadius = 15
        ProviderView.layer.shadowOffset = CGSize(width: 0, height: 4)
        ProviderView.layer.shadowRadius = 3
        ProviderView.layer.shadowOpacity = 0.3
        ProviderView.layer.shadowColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
