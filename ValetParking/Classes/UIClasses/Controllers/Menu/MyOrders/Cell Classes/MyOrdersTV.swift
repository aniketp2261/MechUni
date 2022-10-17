//
//  MyOrdersTV.swift
//  ValetParking
//
//  Created by Sachin Patil on 01/06/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class MyOrdersTV: UITableViewCell {

    @IBOutlet weak var ProviderNameLbl: UILabel!
    @IBOutlet weak var ProviderImg: UIImageView!
    @IBOutlet weak var ProviderAddress: UILabel!
    @IBOutlet weak var StatusImg: UIImageView!
    @IBOutlet weak var OrderIdLbl: UILabel!
    @IBOutlet weak var PlateNoLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ProviderNameLbl.superview?.layer.shadowColor = UIColor.black.cgColor
        ProviderNameLbl.superview?.layer.shadowOffset = CGSize(width: 0, height: 3)
        ProviderNameLbl.superview?.layer.shadowOpacity = 0.3
        ProviderNameLbl.superview?.layer.shadowRadius = 3.0
        ProviderNameLbl.superview?.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
