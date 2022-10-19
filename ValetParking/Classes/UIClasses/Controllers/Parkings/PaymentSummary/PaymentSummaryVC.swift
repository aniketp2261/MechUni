//
//  PaymentSummaryVC.swift
//  MechUni
//
//  Created by Sachin Patil on 22/04/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import Razorpay

struct ApplyCouponsModel {
    let totalAmountAfterDiscount,discount,totalAmount,promoCode: String
}

class PaymentSummaryVC: UIViewController {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var BackActionImg: UIImageView!
    @IBOutlet weak var CouponsAvailableLbl: UILabel!
    @IBOutlet weak var ApplyCouponsBtn: UIButton!
    @IBOutlet weak var OfferDiscountMsgLbl: UILabel!
    @IBOutlet weak var HoursParkingCharges: UILabel!
    @IBOutlet weak var MinimumParkingCharges: UILabel!
    @IBOutlet weak var TotalParkingHours: UILabel!
    @IBOutlet weak var TotalParkingCharges: UILabel!
    @IBOutlet weak var DiscountView: UIView!
    @IBOutlet weak var DiscountViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ParkingChargesViewHeight : NSLayoutConstraint!
    @IBOutlet weak var Discount: UILabel!
    @IBOutlet weak var TotalAmount: UILabel!
    @IBOutlet weak var OnlinePaymentImg: UIImageView!
    @IBOutlet weak var CashPaymentImg: UIImageView!
    @IBOutlet weak var OnlinePaymentBtn: UIButton!
    @IBOutlet weak var CashPaymentBtn: UIButton!
    @IBOutlet weak var CashView: UIView!
    @IBOutlet weak var OnlineView: UIView!
    @IBOutlet weak var MakePaymentBtn: UIButton!
    
    var razorpayObj: RazorpayCheckout? = nil
    var ticketModel: TicketDetailModel? = nil
    var couponModel: CouponsModel? = nil
    var couponArray: [CouponsModel] = []
    var applyCoupon: ApplyCouponsModel? = nil
    
    var CouponApplied = false
    var onlinePay = true
    var cashPay = false
    var servicesCoupons = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(PromoCodeAction(_:)), name: Notification.Name(rawValue: "PromoCode"), object: nil)
        self.BackActionImg.isUserInteractionEnabled = true
        self.BackActionImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BackAction)))
        self.DiscountViewHeight.constant = 0
        self.DiscountView.isHidden = true
        self.OfferDiscountMsgLbl.isHidden = true
        self.ParkingChargesViewHeight.constant = 143
        self.MakePaymentBtn.layer.borderWidth = 1
        self.MakePaymentBtn.layer.borderColor = UIColor.red.cgColor
        self.MakePaymentBtn.layer.cornerRadius = self.MakePaymentBtn.bounds.height/2
        self.MakePaymentBtn.addTarget(self, action: #selector(MakePaymentAction), for: .touchUpInside)
        self.ApplyCouponsBtn.layer.borderWidth = 1
        self.ApplyCouponsBtn.layer.borderColor = UIColor.black.cgColor
        self.ApplyCouponsBtn.layer.cornerRadius = 10
        self.ApplyCouponsBtn.addTarget(self, action: #selector(ApplyCouponsAction), for: .touchUpInside)
        shadowView.layer.cornerRadius = 15
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.layer.shadowRadius = 4
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowColor = UIColor.black.cgColor
        self.OnlinePaymentImg.isUserInteractionEnabled = true
        self.OnlinePaymentImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OnlinePaymentOption)))
        self.OnlinePaymentBtn.addTarget(self, action: #selector(OnlinePaymentOption), for: .touchUpInside)
        self.CashPaymentImg.isUserInteractionEnabled = true
        self.CashPaymentImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CashPaymentOption)))
        self.CashPaymentBtn.addTarget(self, action: #selector(CashPaymentOption), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCoupons()
        if ticketModel?.vehicleType == "2"{
            self.HoursParkingCharges.text = "Rs.\(ticketModel?.fourWpCost ?? "")/Hr"
        }
        else if ticketModel?.vehicleType == "1"{
            self.HoursParkingCharges.text = "Rs.\(ticketModel?.twoWpCost ?? "")/Hr"
        }
        self.TotalParkingHours.text = ticketModel?.hours
        self.TotalParkingCharges.text = "Rs.\(ticketModel?.totalCharges ?? "")"
        self.MinimumParkingCharges.text = "Rs.\(ticketModel?.minimumCharges ?? "")"
        
        if self.ticketModel?.availablePaymentType == "Cash" || ticketModel?.totalCharges == "0"{
            self.OnlineView.isHidden = true
            self.CashView.isHidden = false
            self.cashPay = true
            self.onlinePay = false
            self.CashPaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
            self.OnlinePaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
        }else if self.ticketModel?.availablePaymentType == "online"{
            self.OnlineView.isHidden = false
            self.CashView.isHidden = true
            self.cashPay = false
            self.onlinePay = true
            self.OnlinePaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
            self.CashPaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
        }else{
            self.OnlineView.isHidden = false
            self.CashView.isHidden = false
            self.cashPay = false
            self.onlinePay = true
            self.OnlinePaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
            self.CashPaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
        }
    }
    @objc func BackAction(){
        self.navigationController?.popViewController(animated: true)
    }
    @objc func PromoCodeAction(_ not: Notification){
        print(not.userInfo ?? "")
            if let dict = not.userInfo as NSDictionary? {
            if let code = dict["Code"] as? String{
                if Int(ticketModel?.totalCharges ?? "") ?? 0 <= 10{
                    AlertFunctions.showAlert(message: "", title: "Coupon is Not Applicable")
                } else{
                    applyCouponAPI(PromoCode: code)
                }
            }
        }
    }
    @objc func OnlinePaymentOption(){
        if onlinePay == false{
            OnlinePaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
            CashPaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
            onlinePay = true
            cashPay = false
        }
    }
    @objc func CashPaymentOption(){
        if cashPay == false{
            OnlinePaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
            CashPaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
            cashPay = true
            onlinePay = false
        }
    }
    @objc func ApplyCouponsAction(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ApplyOffersVC") as! ApplyOffersVC
        vc.couponModel = couponModel
        vc.couponArray = couponArray
        present(vc, animated: true, completion: nil)
    }
    @objc func MakePaymentAction(){
        if onlinePay == true{
            print("Online Payment")
            if CouponApplied == true{
                print("Online Payment CouponApplied == true")
                openRazorpayCheckout(Amount: self.applyCoupon?.totalAmountAfterDiscount ?? "")
                
            } else{
                print("Online Payment CouponApplied == false")
                openRazorpayCheckout(Amount: self.ticketModel?.totalCharges ?? "")
            }
        } else if cashPay == true{
            print("Cash Payment")
            self.updatePaymentDoneStatusToApi()
        }
    }
    func applyCouponAPI(PromoCode: String){
        CouponApplied = true
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let Params = ["_id": Int(userId) ?? 0,"total_amount": Int(ticketModel?.totalCharges ?? "") ?? 0,"promo_code": PromoCode] as [String : Any]
        print("Datts---\(Params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.BaseURL + "manage_coupons/apply_coupon", method: .post,parameters: Params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("getCoupons -- \(apiResponse)")
                SKActivityIndicator.dismiss()
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        let msg = apiDict["message"] as? String ?? ""
                        if status == "success"{
                            let results = apiDict["response_data"] as! [String:Any]
                            let totalAmountAfterDiscount = String(results["total_amount_after_discount"] as? Int ?? 0)
                            let discount = String(results["discount"] as? Int ?? 0)
                            let totalAmount = String(results["total_amount"] as? Int ?? 0)
                            let promoCode = results["promo_code"] as? String ?? ""
                            let model = ApplyCouponsModel(totalAmountAfterDiscount: totalAmountAfterDiscount, discount: discount, totalAmount: totalAmount, promoCode: promoCode)
                            self.applyCoupon = model
                            print("applyCoupon----\(self.applyCoupon)")
                            DispatchQueue.main.async {
                                self.OfferDiscountMsgLbl.isHidden = false
                                self.OfferDiscountMsgLbl.text = "Your coupon of \(PromoCode) has been applied successfully !"
                                self.DiscountViewHeight.constant = 80
                                self.DiscountView.isHidden = false
                                self.ParkingChargesViewHeight.constant = 230
                                self.Discount.text = "Rs.\(self.applyCoupon?.discount ?? "")"
                                self.TotalAmount.text = "Rs.\(self.applyCoupon?.totalAmountAfterDiscount ?? "")"
                                if self.applyCoupon?.totalAmountAfterDiscount ?? "" == "0" || self.ticketModel?.availablePaymentType == "Cash"{
                                    self.OnlinePaymentImg.isHidden = true
                                    self.OnlinePaymentBtn.isHidden = true
                                    self.CashPaymentImg.isHidden = false
                                    self.CashPaymentBtn.isHidden = false
                                    self.cashPay = true
                                    self.onlinePay = false
                                    self.CashPaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
                                    self.OnlinePaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
                                } else if self.ticketModel?.availablePaymentType == "online"{
                                    self.cashPay = false
                                    self.onlinePay = true
                                    self.OnlinePaymentImg.isHidden = false
                                    self.OnlinePaymentBtn.isHidden = false
                                    self.CashPaymentImg.isHidden = true
                                    self.CashPaymentBtn.isHidden = true
                                    self.OnlinePaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
                                    self.CashPaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
                                } else if self.ticketModel?.availablePaymentType == "Both" || self.applyCoupon?.totalAmountAfterDiscount ?? "" != "0"{
                                    self.cashPay = false
                                    self.onlinePay = true
                                    self.OnlinePaymentImg.isHidden = false
                                    self.OnlinePaymentBtn.isHidden = false
                                    self.CashPaymentImg.isHidden = false
                                    self.CashPaymentBtn.isHidden = false
                                    self.OnlinePaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
                                    self.CashPaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
                                } else{
                                    self.cashPay = false
                                    self.onlinePay = true
                                    self.OnlinePaymentImg.isHidden = false
                                    self.OnlinePaymentBtn.isHidden = false
                                    self.CashPaymentImg.isHidden = false
                                    self.CashPaymentBtn.isHidden = false
                                    self.OnlinePaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
                                    self.CashPaymentImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
                                }
                            }
                        } else {
                            AlertFunctions.showAlert(message: "", title: msg)
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    AlertFunctions.showAlert(message: "",title: apiResponse.error?.localizedDescription ?? "")
                }
            }
        } else{
            let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NetworkPopUpVC") as! NetworkPopUpVC
            self.addChild(popvc)
            popvc.view.frame = self.view.frame
            self.view.addSubview(popvc.view)
            popvc.didMove(toParent: self)
        }
    }
    
    func getCoupons(){
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)manage_coupons/get_coupon_codes?coupon_for=parking", method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("getCoupons -- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let results = apiDict["response_data"] as? [[String:Any]] ?? []
                        let status = apiDict["status"] as? String ?? ""
                        let msg = apiDict["message"] as? String ?? ""
                        self.couponArray.removeAll()
                        for result in results{
                            let promocodeBy = String(result["promocode_by"] as? Int ?? 0)
                            let discountType = String(result["discount_type"] as? Int ?? 0)
                            let validFromDate = result["valid_from_date"] as? String ?? ""
                            let validToDate = result["valid_to_date"] as? String ?? ""
                            let validFromTime = result["valid_from_time"] as? String ?? ""
                            let validToTime = result["valid_to_time"] as? String ?? ""
                            let promoImage = result["promo_image"] as? String ?? ""
                            let promoTitle = result["promo_title"] as? String ?? ""
                            let promoDiscount = String(result["promo_discount"] as? Int ?? 0)
                            let promoDescription = result["promo_description"] as? String ?? ""
                            let promoCode = result["promo_code"] as? String ?? ""
                            let minimumAmount = String(result["minimum_amount"] as? Int ?? 0)
                            let maxAmount = String(result["maximum_discount"] as? Int ?? 0)
                            let usagePerUser = String(result["usage_per_user"] as? Int ?? 0)
                            let id = result["_id"] as? String ?? ""
                            
                            let model = CouponsModel(promocodeBy: promocodeBy, discountType: discountType, validFromDate: validFromDate, validToDate: validToDate, validFromTime: validFromTime, validToTime: validToTime, promoImage: promoImage, promoTitle: promoTitle, promoDiscription: promoDescription, promoCode: promoCode, Id: id, promoDiscount: promoDiscount, minAmount: minimumAmount,maxAmount: maxAmount,usagePerUser: usagePerUser)
                            self.couponModel = model
                            self.couponArray.append(model)
                            print("Couponsssss---\(self.couponArray)")
                        }
                        DispatchQueue.main.async {
                            self.CouponsAvailableLbl.text = "You have \(self.couponArray.count) coupons available"
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    AlertFunctions.showAlert(message: apiResponse.error?.localizedDescription ?? "")
                }
            }
        }
    }
    func openRazorpayCheckout(Amount:String) {
        if APIEndPoints.BaseURL.contains("dev_apis"){
            razorpayObj = RazorpayCheckout.initWithKey(APIEndPoints.RazorPayKeyTest, andDelegate: self)
        } else{
            razorpayObj = RazorpayCheckout.initWithKey(APIEndPoints.RazorPayKeyLive, andDelegate: self)
        }
        var mobile = ""
        var name = ""
        var email = ""
        let currentDefaults = UserDefaults.standard
        let savedArray = currentDefaults.object(forKey: "userDetails") as? Data
        if savedArray != nil {
            var oldArray: [Any]? = nil
            if let anArray = savedArray {
                oldArray = NSKeyedUnarchiver.unarchiveObject(with: anArray) as? [Any]
                if let dict = oldArray?.first as? NSDictionary {
                    mobile = "+" + (dict["mobilenumber"] as? String ?? "")
                    name = (dict["firstname"] as? String ?? "") + " " + (dict["lastname"] as? String ?? "")
                    email = dict["email"] as? String ?? "abc@gmail.com"
                }
            }
        }
        mobile = UserDefaults.standard.string(forKey: "mobileNo") ?? ""
        email = UserDefaults.standard.string(forKey: "email") ?? ""
        name = UserDefaults.standard.string(forKey: "userName") ?? ""
        let Amount = Float(Amount) ?? 0.0
        print("Amountttt---\(Amount)")
        let options: [String:Any] = [
                        "amount": "\(Amount * 100)",
                        "currency": "INR",
                        "image": UIImage(named: "Logo"),
                        "name": "\(name)",
                        "prefill": [
                            "contact": "\(mobile)",
                            "email": "\(email)"
                        ],
                        "theme": [
                            "color": "#3399cc"
                        ]
                    ]
        print("Optionss---\(options)")
        if let rzp = self.razorpayObj {
            rzp.open(options, displayController: self)
        } else {
            print("Unable to initialize")
        }
    }
}

extension PaymentSummaryVC: RazorpayPaymentCompletionProtocol{
    func onPaymentError(_ code: Int32, description str: String) {
        print("onPaymentError \(str)")
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CCAvenueVC") as! CCAvenueVC
        controller.CouponApplied = self.CouponApplied
        controller.ticketModel = self.ticketModel
        controller.applyCoupon = self.applyCoupon
        controller.transactionId = ""
        controller.amountPaid = ""
        self.navigationController?.pushViewController(controller, animated: false)
    }
    func onPaymentSuccess(_ payment_id: String) {
        print("onPaymentSuccess \(payment_id)")
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CCAvenueVC") as! CCAvenueVC
        controller.ticketModel = self.ticketModel
        controller.applyCoupon = self.applyCoupon
        controller.CouponApplied = self.CouponApplied
        controller.transactionId = payment_id
        if CouponApplied == true{
            controller.amountPaid = self.applyCoupon?.totalAmountAfterDiscount ?? ""
        } else{
            controller.amountPaid = self.ticketModel?.totalCharges ?? ""
        }
        self.navigationController?.pushViewController(controller, animated: false)
    }
}
extension PaymentSummaryVC{
    func updatePaymentDoneStatusToApi(){
        var params: [String:Any] = [:]
        if CouponApplied == true{
            print("Cash Coupon Applied!!!")
            params = ["ticket_id":self.ticketModel?.ticketID ?? "","payment_done_status":true,"tracking_id":"","order_id":self.ticketModel?.ticketOrderId ?? "","promo_code":self.applyCoupon?.promoCode ?? "","total_amount":Int(self.applyCoupon?.totalAmount ?? "") ?? 0,"discount":Int(self.applyCoupon?.discount ?? "") ?? 0,"total_after_discount":Int(self.applyCoupon?.totalAmountAfterDiscount ?? "") ?? 0,"payment_type":"Cash"]
        } else{
            print("Cash without Coupon!!!")
            params = ["ticket_id":self.ticketModel?.ticketID ?? "","payment_done_status":true,"tracking_id":"","order_id":self.ticketModel?.ticketOrderId ?? "","total_amount":Int(self.ticketModel?.totalCharges ?? "") ?? 0,"payment_type":"Cash"]
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
                            DispatchQueue.main.async {
                                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CCAvenueVC") as! CCAvenueVC
                                controller.transactionId = "Amount Paid.."
                                controller.cashpaid = true
                                if self.CouponApplied == true{
                                    controller.amountPaid = self.applyCoupon?.totalAmountAfterDiscount ?? ""
                                } else{
                                    controller.amountPaid = self.ticketModel?.totalCharges ?? ""
                                }
                                self.navigationController?.pushViewController(controller, animated: false)
                            }
                        }
                    }
                case .failure(_):
                    self.view.makeToast(apiResponse.error?.localizedDescription)
                }
            }
        }
    }
}

