//
//  TicketsCVC.swift
//  ValetParking
//
//  Created by admin on 04/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class TicketsCVC: UICollectionViewCell {
    @IBOutlet weak var ticketIdLbl:UILabel!
    @IBOutlet weak var dateLbl:UILabel!
    @IBOutlet weak var timeLbl:UILabel!
    @IBOutlet weak var plateNumberLbl:UILabel!
    @IBOutlet weak var containerView:UIView!
    
    let firstGradientColor = #colorLiteral(red: 0.6196078431, green: 0.4361436286, blue: 0.7019607843, alpha: 1)
    let secondGradientColor = #colorLiteral(red: 0.8306146639, green: 0.746713687, blue: 0.8944023337, alpha: 1)

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.setVerticalGradientBackground(colorLeft: firstGradientColor, colorRight: secondGradientColor)
        containerView.layer.cornerRadius = 16
    }
}
