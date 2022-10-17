//
//  MechBrainOrdersCVC.swift
//  ValetParking
//
//  Created by Aniket Patil on 10/09/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class MechBrainOrdersCVC: UICollectionViewCell {
    
    @IBOutlet weak var orderIdLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var plateNumberLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    let firstGradientColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
    let secondGradientColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.setVerticalGradientBackground(colorLeft: firstGradientColor, colorRight: secondGradientColor)
        containerView.layer.cornerRadius = 16
    }

}
