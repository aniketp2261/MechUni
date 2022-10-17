//
//  MyOrdersCVC.swift
//  MechUni
//
//  Created by Sachin Patil on 04/07/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class MyOrdersCVC: UICollectionViewCell {

    @IBOutlet weak var orderIdLbl:UILabel!
    @IBOutlet weak var dateLbl:UILabel!
    @IBOutlet weak var timeLbl:UILabel!
    @IBOutlet weak var plateNumberLbl:UILabel!
    @IBOutlet weak var containerView:UIView!
    
    let firstGradientColor = #colorLiteral(red: 0.5843137503, green: 0.7947619339, blue: 0.4196078479, alpha: 1)
    let secondGradientColor = #colorLiteral(red: 0.2392156869, green: 0.6979740688, blue: 0.9686274529, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.setVerticalGradientBackground(colorLeft: firstGradientColor, colorRight: secondGradientColor)
        containerView.layer.cornerRadius = 16
    }
}
