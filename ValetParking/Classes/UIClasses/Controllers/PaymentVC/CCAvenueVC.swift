//
//  CCAvenueVC.swift
//  ValetParking
//
//  Created by Chauhan on 02/01/20.
//  Copyright © 2020 fugenx. All rights reserved.
//

import UIKit
import Alamofire

class CCAvenueVC: UIViewController {
    
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblTrans: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStatic: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!

    var ticketModel:TicketDetailModel? = nil
    var applyCoupon: ApplyCouponsModel? = nil
    var CouponApplied = false
    var cashpaid = false
    var transactionId = String()
    var amountPaid = String()
    var ServicesFlow = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblTitle.superview?.layer.cornerRadius = 16
        print("trans id ---- \(transactionId)")
        var dict: [String: Any]? = nil
        if transactionId != nil{
            dict = ["trnsId":transactionId,"amount":amountPaid]
//      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PaymentDetails"), object: dict)
            showSuccesPopUp(not: dict)
        }
    }
    @IBAction func okBtnClicked(_ sender: Any) {
        if self.lblTitle.text == "Payment Failed" {
//            self.navigationController?.popViewController(animated: true)
            let controllersCount = self.navigationController?.viewControllers.count ?? 0
            if controllersCount > 2 {
                self.navigationController?.viewControllers.remove(at: controllersCount - 2)
                self.navigationController?.popViewController(animated: false)
            } else {
                self.navigationController?.popViewController(animated: false)
            }
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PaymentSuccess"), object: nil, userInfo: nil)
            UserDefaults.standard.setValue("home", forKey: "SelectedTab")
            UserDefaults.standard.setValue(ticketModel?.ticketID,forKey: "TicketId")
            
            let controllersCount = self.navigationController?.viewControllers.count ?? 0
            print("controllersCount--\(controllersCount)")
            if controllersCount > 2 {
                self.navigationController?.viewControllers.remove(at: controllersCount - 2)
                self.navigationController?.popViewController(animated: false)
            } else {
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    func showSuccesPopUp(not: [String : Any]?) {
        print("PaymentData----\(not)")
        if let dict = not {
            let amount = dict["amount"] as! String
            var trnsId = dict["trnsId"] as! String
            trnsId = trnsId.replacingOccurrences(of: " ", with: "")
            DispatchQueue.main.async { [self] in
                if trnsId.count > 0 {
                    if self.cashpaid == false{
                        self.lblTrans.isHidden = false
                        self.lblTrans.text = trnsId
                        if self.ServicesFlow == true{
                            print("Other ONLINE PAYMENT")
                        } else{
                            print("Parking Online Payment")
                            self.updatePaymentDoneStatusToApi(ticketID: self.ticketModel?.ticketID ?? "",trackingId: trnsId, OrderId: self.ticketModel?.ticketOrderId ?? "")
                        }
                    } else {
                        self.lblTrans.isHidden = true
                    }
                    self.lblDesc.text = "Your payment \(amount) ₹ has been processed successfully"
                    self.lblTitle.textColor = UIColor(red: 0.0/255.0, green: 140.0/255.0, blue: 26.0/255.0, alpha: 1.0)
                    self.lblStatic.text = "Please show your transaction id to the valet boy for payment confirmation."
                    self.lblTitle.text = "Payment Successful"
                    let image = UIImage(named: "tick")?.withRenderingMode(.alwaysTemplate)
                    self.imgIcon.image = image
                    self.imgIcon.tintColor = self.lblTitle.textColor
                } else {
                    self.transactionFail()
                }
            }
        } else {
            // fail
            DispatchQueue.main.async {
                self.transactionFail()
            }
        }
    }
    func transactionFail() {
        self.lblDesc.text = "Your payment process has been failed."
        self.lblTrans.text = ""
        self.lblStatic.text = "Please try again"
        self.lblTitle.text = "Payment Failed"
        self.lblTitle.textColor = UIColor(red: 234.0/255.0, green: 37.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        let image = UIImage(named: "tick")?.withRenderingMode(.alwaysTemplate)
        self.imgIcon.image = image
        self.imgIcon.tintColor = self.lblTitle.textColor
    }
}

extension CCAvenueVC{
    func updatePaymentDoneStatusToApi(ticketID:String,trackingId: String,OrderId: String){
        var params:[String:Any] = [:]
        if CouponApplied == true{
            params = ["ticket_id":ticketID,"payment_done_status":true,"tracking_id":trackingId,"order_id":OrderId,"promo_code": self.applyCoupon?.promoCode ?? "","total_amount": Int(self.applyCoupon?.totalAmount ?? "") ?? 0,"discount": Int(self.applyCoupon?.discount ?? "") ?? 0,"total_after_discount": Int(self.applyCoupon?.totalAmountAfterDiscount ?? "") ?? 0,"payment_type":"online"]
        } else{
            params = ["ticket_id":ticketID,"payment_done_status":true,"tracking_id":trackingId,"order_id":OrderId,"total_amount": Int(self.ticketModel?.totalCharges ?? "") ?? 0,"payment_type":"online"]
        }
        print("PaymentDoneParams ---- \(params)")
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.updateVehiclePickupStatus, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                debugPrint("UpdateStatusResponse ---- \(apiResponse)")
                switch apiResponse.result {
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any] {
                        let status = apiDict["status"] as? String ?? ""
                        if status == "Success"{
                            let msg = apiDict["message"] as? String
                            self.view.makeToast(msg)
                        }
                    }
                case .failure(_):
                    self.view.makeToast(apiResponse.error?.localizedDescription)
                }
            }
        }
    }
}
