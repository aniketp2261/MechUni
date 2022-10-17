//
//  NotificationView.swift
//  ValetParking
//
//  Created by Khushal on 24/01/19.
//  Copyright © 2019 fugenx. All rights reserved.
//

import UIKit
protocol NotificationViewDelegate
{
    func removenotification(dict : Dictionary<AnyHashable, Any>)
}

class NotificationView: UIView {
    
    @IBOutlet var mView: UIView!
    @IBOutlet weak var mUserName: UILabel!
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var mTicketNo: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var mCarNo: UILabel!
    
    var delegate: NotificationViewDelegate?
    var carInfo : Dictionary = Dictionary<AnyHashable, Any>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit()
    {
        Bundle.main.loadNibNamed("NotificationView", owner: self, options: nil)
        addSubview(mView)
        mView.frame = self.bounds
        self.notificationView.layer.cornerRadius = 20
    }
    
    @IBAction func OkActn(_ sender: Any) {
        delegate?.removenotification(dict: self.carInfo)
    }
    
    @objc func reloadUI(dict : Dictionary<AnyHashable, Any>) {
        
        let strTick = "Your Ticket id is \(dict["ticket_id"] as? String ?? "")"
        let strId = dict["ticket_id"] as? String ?? ""
        let rangeId = (strTick as NSString).range(of: strId)
        let attrId = NSMutableAttributedString(string: strTick)
        attrId.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black
            , range: rangeId)
        self.mTicketNo.attributedText = attrId
        
        let strDesc = "We received your request, Our team will pick up your Car No: \(dict["plate_no"] as? String ?? "") to make it available soon"
        
        let strPlate = dict["plate_no"] as? String ?? ""
        let rangeP = (strDesc as NSString).range(of: strPlate)
        let attrDesc = NSMutableAttributedString(string: strDesc)
        attrDesc.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black
            , range: rangeP)
        lblDesc.attributedText = attrDesc

//        let strGate = "Please be available at Gate"
//        let strNo = "Gate"
//        let rangeNo = (strGate as NSString).range(of: strNo)
//        let attrNo = NSMutableAttributedString(string: strGate)
//        attrNo.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black
//            , range: rangeNo)
//        self.mCarNo.attributedText = attrNo
            
        self.carInfo = dict
        let name =  UserDefaults.standard.string(forKey: "userName")
        print(name)
        self.mUserName.text = String(format: "%@ %@,", "Hi",name!)
    }
    
}
