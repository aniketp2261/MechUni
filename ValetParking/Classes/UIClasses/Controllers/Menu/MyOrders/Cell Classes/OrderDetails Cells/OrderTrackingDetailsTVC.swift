//
//  OrderTrackingDetailsTVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 03/06/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class OrderTrackingDetailsTVC: UITableViewCell {
    
    @IBOutlet weak var OrderConfirmedDate: UILabel!
    @IBOutlet weak var OrderPickupDate: UILabel!
    @IBOutlet weak var OrderArrivedLbl: UILabel!
    @IBOutlet weak var OrderInProgressDate: UILabel!
    @IBOutlet weak var OrderCompletedDate: UILabel!
    @IBOutlet weak var OrderSucessfullyDate: UILabel!
    @IBOutlet weak var PickUpView: UIView!
    @IBOutlet weak var PickUpHeight: NSLayoutConstraint!
    
    @IBOutlet weak var OrderConfirmedImg: UIImageView!
    @IBOutlet weak var OrderPickUpImg: UIImageView!
    @IBOutlet weak var OrderInprogressImg: UIImageView!
    @IBOutlet weak var OrderCompletedImg: UIImageView!
    @IBOutlet weak var OrderSuccessfulImg: UIImageView!
    @IBOutlet weak var PaymentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
