//
//  MechbrainPaymentSummaryVC.swift
//  ValetParking
//
//  Created by Aniket Patil on 06/09/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import Razorpay

class MechbrainPaymentSummaryVC: UIViewController {

    @IBOutlet weak var BackImg: UIImageView!
    @IBOutlet weak var CouponsView: ShadowView!
    @IBOutlet weak var ApplyCouponBtn: UIButton!
    @IBOutlet weak var CouponLbl: UILabel!
    @IBOutlet weak var CouponViewHeight: NSLayoutConstraint!
    @IBOutlet weak var OfferDiscountMsgLbl: UILabel!
    @IBOutlet weak var MechServiceView: UIView!
    @IBOutlet weak var DiscountView: UIView!
    @IBOutlet weak var DiscountViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var TotalServiceCostLbl: UILabel!
    @IBOutlet weak var DiscountCostLbl: UILabel!
    @IBOutlet weak var TotalAmtLbl: UILabel!
    @IBOutlet weak var OnlineImg: UIImageView!
    @IBOutlet weak var OnlineBtn: UIButton!
    @IBOutlet weak var CashImg: UIImageView!
    @IBOutlet weak var CashBtn: UIButton!
    
    @IBOutlet weak var MakePaymentBtn: UIButton!
    
    var OrderDetails: OrderDetailsModel? = nil
    var razorpayObj: RazorpayCheckout? = nil
    var ticketModel: TicketDetailModel? = nil
    var couponModel: CouponsModel? = nil
    var couponArray: [CouponsModel] = []
    var applyCoupon: ApplyCouponsModel? = nil
    
    var onlinePay = true
    var cashPay = false
    var CouponApplied = false

    override func viewDidLoad() {
        super.viewDidLoad()
        DiscountView.isHidden = true
        DiscountViewHeight.constant = 0
        MakePaymentBtn.layer.cornerRadius = MakePaymentBtn.bounds.height / 2
        MakePaymentBtn.layer.borderWidth = 1
        MakePaymentBtn.layer.borderColor = UIColor.red.cgColor
        MechServiceView.layer.cornerRadius = 15
        MechServiceView.layer.shadowOffset = CGSize(width: 0, height: 3)
        MechServiceView.layer.shadowRadius = 3
        MechServiceView.layer.shadowOpacity = 0.3
        MechServiceView.layer.shadowColor = UIColor.black.cgColor
        ApplyCouponBtn.layer.borderWidth = 1
        ApplyCouponBtn.layer.cornerRadius = 10
        ApplyCouponBtn.layer.borderColor = UIColor.black.cgColor
        ApplyCouponBtn.addTarget(self, action: #selector(ApplyCouponsAction), for: .touchUpInside)
        BackImg.isUserInteractionEnabled = true
        BackImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BackAction)))
        OnlineImg.isUserInteractionEnabled = true
        OnlineImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OnlinePaymentOption)))
        OnlineBtn.addTarget(self, action: #selector(OnlinePaymentOption), for: .touchUpInside)
        CashImg.isUserInteractionEnabled = true
        CashImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CashPaymentOption)))
        CashBtn.addTarget(self, action: #selector(CashPaymentOption), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(PromoCodeAction(_:)), name: Notification.Name(rawValue: "PromoCodeMechbrain"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("OrderDetails---\(OrderDetails)")
        getCoupons()
        self.TotalServiceCostLbl.text = "Rs.\(OrderDetails?.orderAmount ?? "")"
    }
    @objc func BackAction(){
        self.navigationController?.popViewController(animated: true)
    }
    func OnlineMode(){
        self.OnlineImg.isHidden = false
        self.OnlineBtn.isHidden = false
        self.CashImg.isHidden = true
        self.CashBtn.isHidden = true
        self.cashPay = false
        self.onlinePay = true
        self.CashImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
        self.OnlineImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
    }
    func CashMode(){
        self.OnlineImg.isHidden = true
        self.OnlineBtn.isHidden = true
        self.CashImg.isHidden = false
        self.CashBtn.isHidden = false
        self.cashPay = true
        self.onlinePay = false
        self.CashImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
        self.OnlineImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
    }
    func BothMode(){
        self.OnlineImg.isHidden = false
        self.OnlineBtn.isHidden = false
        self.CashImg.isHidden = false
        self.CashBtn.isHidden = false
        self.cashPay = false
        self.onlinePay = true
        self.CashImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
        self.OnlineImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
    }
    @objc func OnlinePaymentOption(){
        if onlinePay == false{
            OnlineImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
            CashImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
            onlinePay = true
            cashPay = false
        }
    }
    @objc func CashPaymentOption(){
        if cashPay == false{
            OnlineImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
            CashImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
            cashPay = true
            onlinePay = false
        }
    }
    @objc func ApplyCouponsAction(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ApplyOffersVC") as! ApplyOffersVC
        vc.couponModel = couponModel
        vc.couponArray = couponArray
        vc.MechbrainCoupons = true
        present(vc, animated: true, completion: nil)
    }
    @objc func PromoCodeAction(_ not: Notification){
        print(not.userInfo ?? "")
            if let dict = not.userInfo as NSDictionary? {
            if let code = dict["Code"] as? String{
                if Int(OrderDetails?.orderAmount ?? "") ?? 0 <= 10{
                    AlertFunctions.showAlert(message: "", title: "Coupon is Not Applicable")
                } else{
                    applyCouponAPI(PromoCode: code)
                }
            }
        }
    }
    func getCoupons(){
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.BaseURL+"manage_coupons/get_coupon_codes?coupon_for=mechbrain", method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("getMechbrainCoupons -- \(apiResponse)")
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
                            print("MechCouponss---\(self.couponArray)")
                        }
                        DispatchQueue.main.async {
                            self.CouponLbl.text = "You have \(self.couponArray.count) coupons available"
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    AlertFunctions.showAlert(message: apiResponse.error?.localizedDescription ?? "")
                }
            }
        }
    }
    func applyCouponAPI(PromoCode: String){
        CouponApplied = true
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let Params = ["_id": Int(userId) ?? 0,"total_amount": Int(OrderDetails?.orderAmount ?? "") ?? 0,"promo_code": PromoCode] as [String : Any]
        print("Datts---\(Params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.BaseURL+"manage_coupons/apply_coupon", method: .post,parameters: Params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
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
                                self.DiscountViewHeight.constant = 70
                                self.DiscountView.isHidden = false
                                self.DiscountCostLbl.text = "Rs.\(self.applyCoupon?.discount ?? "")"
                                self.TotalAmtLbl.text = "Rs.\(self.applyCoupon?.totalAmountAfterDiscount ?? "")"
                                if self.applyCoupon?.totalAmountAfterDiscount ?? "" == "0"{
                                    self.CashMode()
                                } else{
                                    self.BothMode()
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
    
    @IBAction func PaymentAction(_ sender: Any) {
        if onlinePay == true{
            if CouponApplied == true{
                print("Online Payment CouponApplied == true")
                openRazorpayCheckout(Amount: self.applyCoupon?.totalAmountAfterDiscount ?? "")
                
            } else{
                print("Online Payment CouponApplied == false")
                openRazorpayCheckout(Amount: self.OrderDetails?.orderAmount ?? "")
            }
        } else if cashPay == true{
            print("Cash Payment")
            updatePaymentStatus(paymentType: "cash", paymentId: "", orderId: self.OrderDetails?.orderId ?? "", couponApplied: self.CouponApplied)
        }
    }
    func updatePaymentStatus(paymentType: String, paymentId: String, orderId: String, couponApplied: Bool){
        var params: [String: Any] = [:]
        if couponApplied == true{
            params = ["payment_method": paymentType,"payment_id": paymentId,"order_id": orderId,"total_amount_after_discount": applyCoupon?.totalAmountAfterDiscount ?? "","discount": applyCoupon?.discount ?? "","total_amount": self.applyCoupon?.totalAmount ?? "","promo_code": self.applyCoupon?.promoCode ?? ""]
        } else{
            params = ["payment_method": paymentType,"payment_id": paymentId,"order_id": orderId,"total_amount_after_discount": OrderDetails?.totalAfterDiscount ?? "","discount": OrderDetails?.discount ?? "","total_amount": OrderDetails?.orderAmount ?? "","promo_code": OrderDetails?.promoCode ?? ""]
        }
        print("updatePaymentStatusParams--- \(params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.mechbrainUpdateStatus, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("updatePaymentStatusRes--- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        let msg = apiDict["message"] as? String ?? ""
                        if status == "success" {
                            DispatchQueue.main.async {
                                if paymentType == "cash"{
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let controller = storyboard.instantiateViewController(withIdentifier: "CCAvenueVC") as! CCAvenueVC
                                    controller.transactionId = "Amount Paid.."
                                    controller.cashpaid = true
                                    if couponApplied == true{
                                        controller.amountPaid = self.applyCoupon?.totalAmountAfterDiscount ?? ""
                                    } else{
                                        controller.amountPaid = self.OrderDetails?.orderAmount ?? ""
                                    }
                                    self.navigationController?.pushViewController(controller, animated: false)
                                }
                            }
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    AlertFunctions.showAlert(message: "",title: apiResponse.error?.localizedDescription ?? "")
                }
            }
        }
    }
}
extension MechbrainPaymentSummaryVC: RazorpayPaymentCompletionProtocol{
    func onPaymentError(_ code: Int32, description str: String) {
        print("onPaymentError \(str)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CCAvenueVC") as! CCAvenueVC
        controller.CouponApplied = self.CouponApplied
        controller.applyCoupon = self.applyCoupon
        controller.transactionId = ""
        controller.amountPaid = ""
        self.navigationController?.pushViewController(controller, animated: false)
    }
    func onPaymentSuccess(_ payment_id: String) {
        print("onPaymentSuccess \(payment_id)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CCAvenueVC") as! CCAvenueVC
        controller.applyCoupon = self.applyCoupon
        controller.CouponApplied = self.CouponApplied
        controller.transactionId = payment_id
        controller.ServicesFlow = true
        updatePaymentStatus(paymentType: "online", paymentId: payment_id, orderId: OrderDetails?.orderId ?? "", couponApplied: self.CouponApplied)
        if CouponApplied == true{
            controller.amountPaid = self.applyCoupon?.totalAmountAfterDiscount ?? ""
        } else{
            controller.amountPaid = self.OrderDetails?.orderAmount ?? ""
        }
        self.navigationController?.pushViewController(controller, animated: false)
    }
}
