//
//  ServicesPaymentSummaryVC.swift
//  MechUni
//
//  Created by Sachin Patil on 17/06/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import Razorpay

class ServicesPaymentSummaryVC: UIViewController {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var BackActionImg: UIImageView!
    @IBOutlet weak var CouponsAvailableLbl: UILabel!
    @IBOutlet weak var ApplyCouponsBtn: UIButton!
    @IBOutlet weak var OfferDiscountMsgLbl: UILabel!
    @IBOutlet weak var TotalServicesCharges: UILabel!
    @IBOutlet weak var DiscountView: UIView!
    @IBOutlet weak var DiscountViewHeight: NSLayoutConstraint!
    @IBOutlet weak var Discount: UILabel!
    @IBOutlet weak var TotalAmount: UILabel!
    @IBOutlet weak var MakePaymentBtn: UIButton!
    
    var OrderDetails: OrderDetailsModel? = nil
    var couponModel: CouponsModel? = nil
    var couponArray: [CouponsModel] = []
    var applyCoupon: ApplyCouponsModel? = nil
    var razorpayObj: RazorpayCheckout? = nil
    var CouponApplied = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(PromoCodeAction(_:)), name: Notification.Name(rawValue: "PromoCodeServices"), object: nil)
        self.BackActionImg.isUserInteractionEnabled = true
        self.BackActionImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BackAction)))
        self.DiscountViewHeight.constant = 0
        self.DiscountView.isHidden = true
        self.OfferDiscountMsgLbl.isHidden = true
        self.MakePaymentBtn.layer.borderWidth = 1
        self.MakePaymentBtn.layer.borderColor = UIColor.red.cgColor
        self.MakePaymentBtn.layer.cornerRadius = self.MakePaymentBtn.bounds.height/2
        self.MakePaymentBtn.addTarget(self, action: #selector(MakePaymentAction), for: .touchUpInside)
        self.ApplyCouponsBtn.layer.borderWidth = 1
        self.ApplyCouponsBtn.layer.borderColor = UIColor.black.cgColor
        self.ApplyCouponsBtn.layer.cornerRadius = 10
        self.ApplyCouponsBtn.addTarget(self, action: #selector(ApplyCouponsAction), for: .touchUpInside)
        shadowView.layer.cornerRadius = 15
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowColor = UIColor.black.cgColor
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getCoupons()
        self.TotalServicesCharges.text = "Rs.\(OrderDetails?.orderAmount ?? "").0"
    }
    @objc func BackAction(){
        self.navigationController?.popViewController(animated: true)
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
    @objc func ApplyCouponsAction(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ApplyOffersVC") as! ApplyOffersVC
        vc.couponModel = couponModel
        vc.couponArray = couponArray
        vc.ServicesCoupons = true
        present(vc, animated: true, completion: nil)
    }
    @objc func MakePaymentAction(){
        if CouponApplied == true{
            openRazorpayCheckout(Amount: applyCoupon?.totalAmountAfterDiscount ?? "")
        } else{
            openRazorpayCheckout(Amount: OrderDetails?.orderAmount ?? "")
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
    func applyCouponAPI(PromoCode: String){
        CouponApplied = true
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let Params = ["_id": Int(userId) ?? 0,"total_amount": Int(OrderDetails?.orderAmount ?? "") ?? 0,"promo_code": PromoCode] as [String : Any]
        print("Datts---\(Params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.BaseURL+"manage_coupons/apply_service_coupon", method: .post,parameters: Params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("getCoupons -- \(apiResponse)")
                SKActivityIndicator.dismiss()
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        let msg = apiDict["message"] as? String ?? ""
                        if status == "success"{
                            let results = apiDict["response_data"] as! [String:Any]
                            let totalAmountAfterDiscount = results["total_amount_after_discount"] as? String ?? ""
                            let discount = results["discount"] as? String ?? ""
                            let totalAmount = results["total_amount"] as? String ?? ""
                            let promoCode = results["promo_code"] as? String ?? ""
                            let model = ApplyCouponsModel(totalAmountAfterDiscount: totalAmountAfterDiscount, discount: discount, totalAmount: totalAmount, promoCode: promoCode)
                            self.applyCoupon = model
                            print("applyCoupon----\(self.applyCoupon)")
                            DispatchQueue.main.async {
                                self.OfferDiscountMsgLbl.isHidden = false
                                self.OfferDiscountMsgLbl.text = "Your coupon of \(PromoCode) has been applied successfully !"
                                self.DiscountViewHeight.constant = 80
                                self.DiscountView.isHidden = false
                                let discount = Float(self.applyCoupon?.discount ?? "") ?? 0.0
                                let totalAmount = Float(self.applyCoupon?.totalAmountAfterDiscount ?? "") ?? 0.0
                                self.Discount.text = "Rs.\(String(format: "%.0f", discount)).0"
                                self.TotalAmount.text = "Rs.\(String(format: "%.0f", totalAmount)).0"
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
        }
    }
    
    func getCoupons(){
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.BaseURL+"manage_coupons/get_coupon_codes?coupon_for=service", method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
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
    func updatePaymentStatus(paymentType: String, paymentId: String, orderId: String){
        let params: [String: Any]
        if CouponApplied == true{
            params = ["payment_method":paymentType,"payment_id":paymentId,"order_id":orderId,"total_amount_after_discount":applyCoupon?.totalAmountAfterDiscount ?? "","discount":applyCoupon?.discount ?? "","total_amount":applyCoupon?.totalAmount ?? "","promo_code":applyCoupon?.promoCode ?? ""]
        } else{
            params = ["payment_method":paymentType,"payment_id":paymentId,"order_id":orderId,"total_amount_after_discount":OrderDetails?.totalAfterDiscount ?? "","discount":OrderDetails?.discount ?? "","total_amount":OrderDetails?.totalAmount ?? "","promo_code":OrderDetails?.promoCode ?? ""]
        }
        print("updatePaymentStatusParams--- \(params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.updateOrderStatus, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("updatePaymentStatusRes--- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        let msg = apiDict["message"] as? String ?? ""
                        if status == "success" {
                                
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
extension ServicesPaymentSummaryVC: RazorpayPaymentCompletionProtocol{
    func onPaymentError(_ code: Int32, description str: String) {
        print("onPaymentError \(str)")
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CCAvenueVC") as! CCAvenueVC
        controller.CouponApplied = self.CouponApplied
        controller.applyCoupon = self.applyCoupon
        controller.transactionId = ""
        controller.amountPaid = ""
        self.navigationController?.pushViewController(controller, animated: false)
    }
    func onPaymentSuccess(_ payment_id: String) {
        print("onPaymentSuccess \(payment_id)")
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CCAvenueVC") as! CCAvenueVC
        controller.applyCoupon = self.applyCoupon
        controller.CouponApplied = self.CouponApplied
        controller.transactionId = payment_id
        controller.ServicesFlow = true
        updatePaymentStatus(paymentType: "online", paymentId: payment_id, orderId: OrderDetails?.orderId ?? "")
        if CouponApplied == true{
            controller.amountPaid = self.applyCoupon?.totalAmountAfterDiscount ?? ""
        } else{
            controller.amountPaid = self.OrderDetails?.orderAmount ?? ""
        }
        self.navigationController?.pushViewController(controller, animated: false)
    }
}
