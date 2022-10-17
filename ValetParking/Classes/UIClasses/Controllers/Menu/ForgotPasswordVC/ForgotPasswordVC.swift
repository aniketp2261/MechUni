//
//  ForgotPasswordVC.swift
//  ValetParking
//
//  Created by Khushal on 23/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire
import SKActivityIndicatorView
import SKCountryPicker

class ForgotPasswordVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mMobileNoView: UIView!
    @IBOutlet weak var countryBtn: UIButton!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var mMobileNoTF: UITextField!
    @IBOutlet weak var mLabel: UILabel!
    @IBOutlet weak var mSubmitBtn: UIButton!
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mSubmitBtn.layer.cornerRadius = 20
        self.mSubmitBtn.layer.borderWidth = 1
        self.mSubmitBtn.layer.borderColor = #colorLiteral(red: 1, green: 0.0862745098, blue: 0.0862745098, alpha: 1)
        self.mMobileNoView.layer.cornerRadius = 20
        self.mMobileNoView.layer.borderWidth = 1
        self.mMobileNoView.layer.borderColor = UIColor.gray.cgColor
        
        // placeholder color
        mMobileNoTF.placeholder = "Enter mobile number"
        
        let country = CountryManager.shared.currentCountry
        countryBtn.setTitle(country?.dialingCode, for: .normal)
        imgFlag.image = country?.flag
        mMobileNoTF.keyboardType = .numberPad
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == mMobileNoTF{
            if Int(range.location) >= 10
            {
                return false
            }
        }
        return true
    }
    
    //Email Validation
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    // Button Actions
    
    @IBAction func countryBtnClicked(_ sender: Any) {
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { (country: Country) in
            self.imgFlag.image = country.flag
            self.countryBtn.setTitle(country.dialingCode, for: .normal)
        }
        countryController.detailColor = UIColor.black
    }
    
    @IBAction func mSkip(_ sender: Any) {
       // Home
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mSubmitBtn(_ sender: Any) {
        if(mMobileNoTF.text == "")
        {
            self.view.makeToast("Please enter your mobile number!");
            return
        } else if(mMobileNoTF.text!.count < 10 || mMobileNoTF.text!.count > 10)
        {
            self.view.makeToast("Please enter proper mobile number!")
            return
        }
    
        
        let cc = self.countryBtn.currentTitle
        let strCC = cc?.dropFirst()
        
        let parameters: Parameters =
            [
                   "mobile_email": mMobileNoTF.text!.count > 0 ? "\(strCC!)\(self.mMobileNoTF.text!)" : ""
        ]
     //   "mobilenumber": mMobileNoTF.text!.count > 0 ? "\(strCC!)\(self.mMobileNoTF.text!)" : ""

        if Connectivity.isConnectedToInternet
        {
            print("Param Forgot Password = \(parameters)")
            print("URL Forgot Password = \(APIEndPoints.BaseURL)\(APIEndPoints.forgotpassword)")

            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)\(APIEndPoints.forgotpassword)", method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        print("Response: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                let message = JSON["message"] as? String
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String
                                
                                if status == "failed" {
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                }else{
                                    let dict = JSON["result"] as? NSDictionary
                                    //let dict = contentArr?.firstObject as! NSDictionary
                                    //                                UserDefaults.standard.set(dict["_id"] as Any, forKey: "userID")
                                    
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = storyboard.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
                                    //vc.mob = self.mEmailTF.text
                                    //vc.email = self.mEmailTF.text
                                    // vc.type = "forgotPswd"
                                    vc.otpDetails = dict!["otp"] as? String ?? "0000"
//                                    self.view.makeToast("Your otp is \(dict!["otp"] as? String ?? "0000")")
                                    DispatchQueue.main.async {
                                        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                                            SKActivityIndicator.dismiss()
                                            self.navigationController?.pushViewController(vc, animated: true)
                                              }
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
