//
//  PopUpView.swift
//  ValetParking
//
//  Created by Khushal on 02/01/19.
//  Copyright © 2019 fugenx. All rights reserved.
//

import UIKit
protocol PopUpViewDelegate
{
    func removePopUp(dict : Dictionary<AnyHashable, Any>)
    func moveToVC(_ viewController : UIViewController)
    
}

class PopUpView: UIView {

    @IBOutlet weak var popView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var mTicketID: UILabel!
    @IBOutlet weak var mCarNo: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!

    @IBOutlet weak var mOKButton: UIButton!
    var carInfo : Dictionary = Dictionary<AnyHashable, Any>()
    var delegate: PopUpViewDelegate?
    var navigationController = UINavigationController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        let name =  UserDefaults.standard.string(forKey: "userName")
//        self.userName.text = name
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit()
    {
        
        Bundle.main.loadNibNamed("PopUpView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        self.popView.layer.cornerRadius = 20

        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.reloadUI(notification:)), name: NSNotification.Name(rawValue: "left_navigation"), object: nil)
    }
    
    @IBAction func RemoveView(_ sender: Any) {
       
        delegate?.removePopUp(dict: self.carInfo)
        
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "ParkedCarVC") as! ParkedCarVC
//        vc.ParkedCarInfo = carInfo
//        self.navigationController.pushViewController(vc, animated: false)
        
        
    }

    @objc func reloadUI(dict : Dictionary<AnyHashable, Any>) {
       
        self.carInfo = dict
        
        let strTick = "Your Ticket id is \(dict["ticket_id"] as? String ?? "")"
        let strId = dict["ticket_id"] as? String ?? ""
        let rangeId = (strTick as NSString).range(of: strId)
        let attrId = NSMutableAttributedString(string: strTick)
        attrId.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black
            , range: rangeId)
        self.mTicketID.attributedText = attrId
        
        
        let strDesc = "scanned for Car No: \(dict["plate_no"] as? String ?? "")"
        let strPlate = dict["plate_no"] as? String ?? ""
        let rangeP = (strDesc as NSString).range(of: strPlate)
        let attrDesc = NSMutableAttributedString(string: strDesc)
        attrDesc.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black
            , range: rangeP)
        self.mCarNo.attributedText = attrDesc
        
        let name =  UserDefaults.standard.string(forKey: "userName")
        print(name)
        self.userName.text = String(format: "%@ %@,", "Hi",name!)

        UserDefaults.standard.setValue(carInfo, forKey: "parkedCarDetails")
        let details =  UserDefaults.standard.dictionary(forKey: "parkedCarDetails")
        print(details)
        print(details!["gcm.notification.ticket_id"] )
    }
}
