//
//  CompleteTicketCell.swift
//  ValetParking
//
//  Created by Khushal on 23/01/19.
//  Copyright © 2019 fugenx. All rights reserved.
//

import UIKit

class CompleteTicketCell: UITableViewCell {
    
    @IBOutlet weak var mTicketView: UIView!
    @IBOutlet weak var mTicketID: UILabel!
    @IBOutlet weak var mCarNo: UILabel!
    @IBOutlet weak var parkingName: UILabel!
    @IBOutlet weak var mDate: UILabel!
    @IBOutlet weak var mTime: UILabel!
    @IBOutlet weak var parkingAmount: UILabel!
    @IBOutlet weak var paymentMode: UILabel!
    @IBOutlet weak var RaiseComplaint: UIButton!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.mTicketView.layer.borderWidth = 2
        self.mTicketView.layer.borderColor = UIColor.lightGray.cgColor
        self.RaiseComplaint.layer.borderWidth = 2
        self.RaiseComplaint.layer.borderColor = UIColor.gray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
