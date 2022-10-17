//
//  TicketTVCell.swift
//  ValetParking
//
//  Created by Khushal on 19/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit

class TicketTVCell: UITableViewCell {
    @IBOutlet weak var mTicketView: UIView!
    @IBOutlet weak var mTicketId: UILabel!
    @IBOutlet weak var mTicketNo: UILabel!
    @IBOutlet weak var mCarNo: UILabel!
    @IBOutlet weak var mCarNoLabel: UILabel!
    @IBOutlet weak var mallLabel: UILabel!
    @IBOutlet weak var mDateLabel: UILabel!
    @IBOutlet weak var mTimeLabel: UILabel!
    @IBOutlet weak var lblAmount: UILabel!

    @IBOutlet weak var mRequestCarBtn: UIButton!
    
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mTicketView.layer.borderWidth = 2
        self.mTicketView.layer.borderColor = UIColor.lightGray.cgColor
        self.mRequestCarBtn.layer.borderWidth = 2
        self.mRequestCarBtn.layer.borderColor = UIColor.gray.cgColor
        self.mTicketView.layer.cornerRadius = 20
        self.mRequestCarBtn.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
