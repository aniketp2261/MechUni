//
//  ResetPasswordVC.swift
//  ValetParking
//
//  Created by Khushal on 14/11/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import Toast_Swift

class ResetPasswordVC: UIViewController {
    
    @IBOutlet weak var mEnterOTPView: UIView!
    @IBOutlet weak var mNewPasswordView: UIView!
    @IBOutlet weak var mEnterOTPTF: UITextField!
    @IBOutlet weak var mNewPasswordTF: UITextField!
    @IBOutlet weak var mSubmitBtn: UIButton!
    var timer = Timer()
    
    var otpDetails: String?
    override func viewDidLoad() {
        super.viewDidLoad()
      //   self.view.makeToast(otpDetails)
        self.mEnterOTPView.layer.cornerRadius = 20
        self.mEnterOTPView.layer.borderWidth = 1
        self.mEnterOTPView.layer.borderColor = UIColor.gray.cgColor
        self.mNewPasswordView.layer.cornerRadius = 20
        self.mNewPasswordView.layer.borderWidth = 1
        self.mNewPasswordView.layer.borderColor = UIColor.gray.cgColor
        self.mSubmitBtn.layer.cornerRadius = 20
        self.mSubmitBtn.layer.borderWidth = 1
        self.mSubmitBtn.layer.borderColor = #colorLiteral(red: 1, green: 0.0862745098, blue: 0.0862745098, alpha: 1)
        //placeholder color
        mEnterOTPTF.placeholder = "Enter OTP"
        mNewPasswordTF.placeholder = "Enter New Password"
        mEnterOTPTF.keyboardType = .numberPad
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func backToLast(_ sender: UIButton?) {
        self.view.makeToast("Please submit all the details first!")
        //self.navigationController?.popViewController(animated: true)
    }
    
   @IBAction func backToLogin(_ sender: UIButton?) {
        let arrNav = self.navigationController?.viewControllers
        for vc in arrNav! {
            if vc.isKind(of: LoginVC.self) {
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- Button Action
    
    @IBAction func mSubmitActn(_ sender: Any) {
        if(mEnterOTPTF.text == "")
        {
            self.view.makeToast("Please enter your OTP!");
            return
        }
        else if(mEnterOTPTF.text != otpDetails)
        {
            self.view.makeToast("OTP didn't match!");
            return
        }
        else if(mNewPasswordTF.text == "")
        {
            self.view.makeToast("Please enter your new password!");
            
            return
        }
            let parameters: Parameters =
                [
                    "otp": String(format: "%@", self.mEnterOTPTF.text!),
                    "password": String(format: "%@", self.mNewPasswordTF.text!)
            ]
            print(parameters)
            if Connectivity.isConnectedToInternet
            {
                print("Yes! internet is available.")
                SKActivityIndicator.show("Loading...")
                Alamofire.request("\(APIEndPoints.BaseURL)\(APIEndPoints.resetpassword)", method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil)
                    .responseJSON { response in
                        switch response.result {
                        case .success:
                            print("Response: \(response)")
                            if let json = response.result.value {
                                if let JSON = json as? NSDictionary {
                                    let message = JSON["message"] as? String
                                    print(JSON["status"] as? String ?? "")
                                    let status = JSON["status"] as? String
                                    
                                    if status == "success" {
                                        let contentArr = JSON["result"] as? NSArray
                                        let dict = contentArr?.firstObject as! NSDictionary
                                        UserDefaults.standard.setValue(dict["_id"] as Any, forKey: "userID")
                                        DispatchQueue.main.async {
                                            self.view.makeToast(message)
                                            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                                                SKActivityIndicator.dismiss()
                                                self.backToLogin(nil)
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            self.view.makeToast(message)
                                        }
                                    }
                                } else {
                                    self.view.makeToast("Json Error...!!!")
                                }
                            }
                            break
                        case .failure(let error):
                            SKActivityIndicator.dismiss()
                            print(error)
                            
                            
                            break
                        }
                }
            } else{
                NetworkPopUpVC.sharedInstance.Popup(vc: self)
           }
        }

}
