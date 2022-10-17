//
//  TicketDownloadBtnTVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 10/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class TicketDownloadBtnTVC: UITableViewCell {

    @IBOutlet weak var ScanQrBtn: UIButton!
    @IBOutlet weak var ShareBtn: UIButton!
    @IBOutlet weak var ShareBtnWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ScanQrBtn.addBorder(color: .red)
        ScanQrBtn.layer.cornerRadius = ScanQrBtn.bounds.height/2
        ShareBtn.addBorder(color: .gray)
        ShareBtnWidth.constant = 50
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
