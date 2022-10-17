//
//  PaymentVC.swift
//  ValetParking
//
//  Created by Khushal on 25/01/19.
//  Copyright © 2019 fugenx. All rights reserved.
//

import UIKit


class PaymentVC: UIViewController {
    
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!

    var ticketDetails: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        status = "Car Parked";
//        "ticket_amount" = 50;
//        "ticket_id" = "TD-10009187";
        self.paymentView.layer.borderWidth = 1
        self.paymentView.layer.borderColor = UIColor(red:0.36, green:0.15, blue:0.53, alpha:1.0).cgColor
        self.paymentView.layer.cornerRadius = 20
        
        if ticketDetails != nil {
            self.lblOrderId.text = ticketDetails?["ticket_id"] as? String ?? ""
            self.amountLabel.text = "\(ticketDetails?["ticket_amount"] as! Int)"
            self.lblCurrency.text = "AED"
        }
    }
    
    @IBAction func onlinePayment(_ sender: Any) {
        if ticketDetails != nil {
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let controller = storyboard.instantiateViewController(withIdentifier: "CCAvenueVC") as! CCAvenueVC
//            controller.orderId = ticketDetails?["ticket_id"] as? String ?? "TD-10003035"
//            controller.amountStr = "\(ticketDetails?["ticket_amount"] as? Int ?? 0)"
//            controller.ticketDetails = self.ticketDetails
//            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

