//
//  MenuTicketsTVC.swift
//  ValetParking
//
//  Created by admin on 21/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class MenuTicketsTVC: UITableViewCell {

    @IBOutlet weak var ParkingNameLbl: UILabel!
    @IBOutlet weak var ParkingImg: UIImageView!
    @IBOutlet weak var ParkingAddress: UILabel!
    @IBOutlet weak var StatusImg: UIImageView!
    @IBOutlet weak var TicketIdLbl: UILabel!
    @IBOutlet weak var PlateNoLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ParkingImg.layer.cornerRadius = 8
        ParkingImg.superview?.layer.shadowColor = UIColor.black.cgColor
        ParkingImg.superview?.layer.shadowOffset = CGSize(width: 0, height: 3)
        ParkingImg.superview?.layer.shadowOpacity = 0.3
        ParkingImg.superview?.layer.shadowRadius = 3.0
        ParkingImg.superview?.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
