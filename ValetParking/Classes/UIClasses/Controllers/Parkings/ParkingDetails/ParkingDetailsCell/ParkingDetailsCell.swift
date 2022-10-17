//
//  ParkingDetailsCell.swift
//  ValetParking
//
//  Created by Khushal on 08/11/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit

class ParkingDetailsCell: UITableViewCell {

    @IBOutlet weak var mCircleView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        mCircleView.layer.cornerRadius = mCircleView.frame.size.height/2
        mCircleView.layer.masksToBounds = true
        mCircleView.layer.borderWidth = 1
        mCircleView.layer.borderColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
