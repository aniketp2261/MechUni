//
//  AddMobileNoVC.swift
//  ValetParking
//
//  Created by Aniket Patil on 05/09/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import SKCountryPicker

class AddMobileNoVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var AddMobView: UIView!
    @IBOutlet weak var MobileTF: UITextField!
    @IBOutlet weak var FlagBtn: UIButton!
    @IBOutlet weak var FlagImg: UIImageView!
    @IBOutlet weak var SaveBtn: UIButton!
    
    @IBOutlet weak var OTPView: UIView!
    @IBOutlet weak var mSubmitBtn: UIButton!
    @IBOutlet weak var first: CustomFontTextField!
    @IBOutlet weak var second: CustomFontTextField!
    @IBOutlet weak var third: CustomFontTextField!
    @IBOutlet weak var fourth: CustomFontTextField!

    var code: String = ""
    var mob: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AddMobView.isHidden = false
        OTPView.isHidden = true
        first.delegate = self
        second.delegate = self
        third.delegate = self
        fourth.delegate = self
        first.keyboardType = .numberPad
        second.keyboardType = .numberPad
        third.keyboardType = .numberPad
        fourth.keyboardType = .numberPad
        MobileTF.keyboardType = .numberPad
        let country = CountryManager.shared.currentCountry
        FlagBtn.setTitle(country?.dialingCode, for: .normal)
        FlagImg.image = country?.flag
        let Code = country?.dialingCode?.split(separator: "+")
        code = String(Code?[0] ?? "")
        SaveBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SaveAction)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
            
            // This allows numeric text only, but also backspace for deletes
            if string.count > 0 && !Scanner(string: string).scanInt32(nil) {
                return false
            }
            if Int(range.location) > 0 {
                return false
            }
            if (textField.text?.count ?? 0) == 0 {
                perform(#selector(changeTextFieldFocus), with: textField, afterDelay: 0)
            }
            
            let  char = string.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            
            if (isBackSpace == -92) {
                perform(#selector(keyboardInputShouldDelete), with: textField, afterDelay: 0)
                print("Backspace was pressed")
            }
            
            //perform(Selector(("secureTextField:")), with: textField, afterDelay: 0)
            //        NSString * proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
            //        return !(proposedNewString.length>1);
            return true
    }
    
    @IBAction func countryBtnClicked(_ sender: Any) {
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { (country: Country) in
            self.FlagBtn.setTitle(country.dialingCode, for: .normal)
            self.FlagImg.image = country.flag
            let Code = country.dialingCode?.split(separator: "+")
            self.code = String(Code?[0] ?? "")
        }
        countryController.detailColor = UIColor.black
    }
    @objc func SaveAction() {
        if MobileTF.text != ""{
            AddMobile()
        } else{
            self.view.makeToast("Enter the Mobile Number")
        }
    }
    
    @objc func changeTextFieldFocus(toNextTextField textField: UITextField?) {
        let tagValue: Int = (textField?.tag ?? 0) + 1
        let txtField = view.viewWithTag(tagValue) as? UITextField
        if textField?.tag == 101 {
            
        } else if textField?.tag == 102 {
            
        } else if textField?.tag == 103 {
            
        } else if textField?.tag == 104 {
            
        }
        txtField?.becomeFirstResponder()
    }

    @objc func keyboardInputShouldDelete(_ textField: UITextField?) -> Bool {
        let shouldDelete = true
        if (textField?.text?.count ?? 0) == 0 && (textField?.text == "") {
            let tagValue: Int = (textField?.tag ?? 0) - 1
            let txtField = view.viewWithTag(tagValue) as? UITextField
            if textField?.tag == 101 {
                
            } else if textField?.tag == 102 {
                
            } else if textField?.tag == 103 {
                
            } else if textField?.tag == 104 {
                
            }
            txtField?.becomeFirstResponder()
        }
        return shouldDelete
    }
    
    func secureTextField(_ txtView: UITextField?) {
        txtView?.isSecureTextEntry = true
    }
    
    @IBAction func editingChanged(_ sender: Any) {
    
        let totalStr = String(format : "%@%@%@%@",first.text!,second.text!,third.text!,fourth.text!)
        let count = totalStr.count
        if(count == 4) {
          //  self.mSubmitBtn.backgroundColor = UIColor(red:0.36, green:0.15, blue:0.53, alpha:1.0)
            //self.mSubmitBtn.alpha = 1
        } else{
           // self.mSubmitBtn.backgroundColor = UIColor(red:0.59, green:0.40, blue:0.77, alpha:1.0)
            //self.mSubmitBtn.alpha = 0.7
        }
    }

    @IBAction func mSubmitAction(_ sender: Any) {
        if fourth.text != ""{
            regOTP()
        } else{
            self.view.makeToast("Enter the Valid OTP...")
        }
    }
    
    func AddMobile() {
        print("Codeee---\(code)")
        let mobileText = String(format : "%@","\(code)\(MobileTF.text!)")
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""

        let parameters: Parameters =
        [
            "mobilenumber": mobileText,
            "customer_id": Int(userId) ?? 0
        ]
        if Connectivity.isConnectedToInternet
        {
            print(parameters)
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.addMobileOTP, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("ResAddMob: \(response)")
                        if let apiDict = response.value as? [String:Any] {
                            let status = apiDict["status"] as? String ?? ""
                            let message = apiDict["message"] as? String ?? ""
                            if status == "success" {
                                self.AddMobView.isHidden = true
                                self.OTPView.isHidden = false
                                self.mob = mobileText
                            } else{
                                SKActivityIndicator.dismiss()
                                self.view.makeToast(message)
                            }
                        }
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
    
    func regOTP()
    {
            let totalStr = String(format : "%@%@%@%@",first.text!,second.text!,third.text!,fourth.text!)
            let userId = UserDefaults.standard.string(forKey: "userID") ?? ""

            let parameters: Parameters =
            [
                "mobilenumber" : String(format: "%@", mob),
                "customer_id" : userId,
                "otp": totalStr as Any
            ]
            if Connectivity.isConnectedToInternet
            {
                SKActivityIndicator.show("Loading...")
                Alamofire.request("\(APIEndPoints.VerifyOTPAfterAdding)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                    .responseJSON { response in
                        switch response.result {
                        case .success:
                            SKActivityIndicator.dismiss()
                            print("Response: \(response)")
                            
                            if let apiDict = response.value as? [String:Any]{
                                let status = apiDict["status"] as? String ?? ""
                                let message = apiDict["message"] as? String ?? ""
                                if status == "success" {
                                    self.dismiss(animated: true, completion: nil)
                                } else{
                                    SKActivityIndicator.dismiss()
                                    self.view.makeToast(message)
                                }
                            }
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
