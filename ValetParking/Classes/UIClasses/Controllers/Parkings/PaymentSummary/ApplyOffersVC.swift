//
//  ApplyOffersVC.swift
//  MechUni
//
//  Created by Sachin Patil on 22/04/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import SKActivityIndicatorView


struct CouponsModel{
    let promocodeBy, discountType: String
    let validFromDate, validToDate: String
    let validFromTime, validToTime: String
    let promoImage, promoTitle, promoDiscription, promoCode, Id: String
    let promoDiscount, minAmount, maxAmount, usagePerUser: String
}

class ApplyOffersVC: UIViewController {

    @IBOutlet weak var CloseImg: UIImageView!
    @IBOutlet weak var OffersTableView: UITableView!
    @IBOutlet weak var bottomSheetView:UIView!
    
    var couponModel: CouponsModel? = nil
    var couponArray: [CouponsModel] = []
    var ServicesCoupons = false
    var MechbrainCoupons = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OffersTableView.delegate = self
        OffersTableView.dataSource = self
        OffersTableView.reloadData()
        OffersTableView.separatorStyle = .none
        OffersTableView.rowHeight = UITableView.automaticDimension
        OffersTableView.estimatedRowHeight = 140
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        bottomSheetView.layer.cornerRadius = 30
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(exitGesture))
        view.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(exitGesture))
        CloseImg.addGestureRecognizer(tapGesture)
    }
    @objc func exitGesture(){
        dismiss(animated: true, completion: nil)
    }
}
class OffersTVC: UITableViewCell{
    @IBOutlet weak var PromoCodeLbl: UILabel!
    @IBOutlet weak var Offer1stLbl: UILabel!
    @IBOutlet weak var Offers2ndLbl: UILabel!
    @IBOutlet weak var ApplyLbl: UILabel!
    
}
extension ApplyOffersVC: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return couponArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "OffersTVC") as? OffersTVC {
            cell.PromoCodeLbl.text = couponArray[indexPath.row].promoCode
            cell.Offer1stLbl.text = couponArray[indexPath.row].promoTitle
            cell.Offers2ndLbl.text = couponArray[indexPath.row].promoDiscription
            cell.Offers2ndLbl.numberOfLines = 3
            cell.selectionStyle = .none
            cell.PromoCodeLbl.layer.borderWidth = 1
            cell.PromoCodeLbl.layer.borderColor = UIColor.black.cgColor
            cell.PromoCodeLbl.layer.cornerRadius = 8
            cell.ApplyLbl.layer.borderWidth = 1
            cell.ApplyLbl.layer.borderColor = UIColor.red.cgColor
            cell.ApplyLbl.layer.cornerRadius = cell.ApplyLbl.bounds.height/2
            cell.PromoCodeLbl.superview?.layer.shadowColor = UIColor.black.cgColor
            cell.PromoCodeLbl.superview?.layer.shadowOffset = CGSize(width: 0, height: 3)
            cell.PromoCodeLbl.superview?.layer.shadowOpacity = 0.3
            cell.PromoCodeLbl.superview?.layer.shadowRadius = 3.0
            cell.PromoCodeLbl.superview?.layer.cornerRadius = 15
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Promocode = couponArray[indexPath.row].promoCode
        let DataDict: [String: Any] = ["Code": Promocode]
        if ServicesCoupons == true{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "PromoCodeServices"), object: nil,userInfo: DataDict)
        } else if MechbrainCoupons == true{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "PromoCodeMechbrain"), object: nil,userInfo: DataDict)
        } else{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "PromoCode"), object: nil,userInfo: DataDict)
        }
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
