//
//  OTPVC.swift
//  ValetParking
//
//  Created by Khushal on 16/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import Toast_Swift

class OTPVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mSubmitBtn: UIButton!
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var first: CustomFontTextField!
    @IBOutlet weak var second: CustomFontTextField!
    @IBOutlet weak var third: CustomFontTextField!
    @IBOutlet weak var fourth: CustomFontTextField!
    
    // var userArray : NSArray = []
    var otpDetails: String?
    var mob: String?
    var email: String?
    //var type: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  self.view.makeToast(otpDetails)
        self.mTitleLabel.text = "Enter the otp send to +91***** *****"
        self.mSubmitBtn.layer.cornerRadius = 20
        self.mSubmitBtn.layer.borderWidth = 1
        self.mSubmitBtn.layer.borderColor = #colorLiteral(red: 1, green: 0.0862745098, blue: 0.0862745098, alpha: 1)
        
//        self.first.layer.cornerRadius = 16
//        self.first.layer.borderWidth = 1
//        self.first.layer.borderColor = UIColor.gray.cgColor
//        self.first.layer.cornerRadius = 20
//
//        self.second.layer.cornerRadius = 16
//        self.second.layer.borderWidth = 1
//        self.second.layer.borderColor = UIColor.gray.cgColor
//        self.second.layer.cornerRadius = 20
//
//        self.third.layer.cornerRadius = 16
//        self.third.layer.borderWidth = 1
//        self.third.layer.borderColor = UIColor.gray.cgColor
//        self.third.layer.cornerRadius = 20
//
//        self.fourth.layer.cornerRadius = 16
//        self.fourth.layer.borderWidth = 1
//        self.fourth.layer.borderColor = UIColor.gray.cgColor
//        self.fourth.layer.cornerRadius = 20
        
        first.delegate = self
        second.delegate = self
        third.delegate = self
        fourth.delegate = self
        first.keyboardType = .numberPad
        second.keyboardType = .numberPad
        third.keyboardType = .numberPad
        fourth.keyboardType = .numberPad
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        do {
            // This allows numeric text only, but also backspace for deletes
            if string.count > 0 && !Scanner(string: string).scanInt32(nil) {
                return false
            }
            if Int(range.location) > 0 {
                return false
            }
            if (textField.text?.count ?? 0) == 0 {
                // perform(Selector(changeTextFieldFocus:), with: textField, afterDelay: 0)
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
    }
    @objc func changeTextFieldFocus(toNextTextField textField: UITextField?) {
        let tagValue: Int = (textField?.tag ?? 0) + 1
        let txtField = view.viewWithTag(tagValue) as? UITextField
        //let value = textField?.text
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
    
    @IBAction func backPress(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editingChanged(_ sender: Any) {
    
    let totalStr = String(format : "%@%@%@%@",first.text!,second.text!,third.text!,fourth.text!)
        let count = totalStr.count
        if(count == 4)
        {
          //  self.mSubmitBtn.backgroundColor = UIColor(red:0.36, green:0.15, blue:0.53, alpha:1.0)
            //self.mSubmitBtn.alpha = 1
        }
        else{
           // self.mSubmitBtn.backgroundColor = UIColor(red:0.59, green:0.40, blue:0.77, alpha:1.0)
            //self.mSubmitBtn.alpha = 0.7
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Button Actionns
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
        
    }

    
    @IBAction func mSubmitActn(_ sender: Any) {
        //regOTP()
//        if type == "reg"
//        {
//            mTitleLabel.text = "Register"
            regOTP()

//        }
//        else {
//           mTitleLabel.text = "Forgot Password"
//            forgotOTP()
//       }
    }
    
func regOTP()
{
        let totalStr = String(format : "%@%@%@%@",first.text!,second.text!,third.text!,fourth.text!)
       
        let parameters: Parameters =
            [
                "mobilenumber" : String(format: "%@", mob!),
                "otp": totalStr as Any
        ]
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)\(APIEndPoints.otpVerify)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("Response: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                let message = JSON["message"] as? String
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String
                                
                                if status == "failed" {
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                } else{
                                    UserDefaults.standard.setValue("1", forKey: "isLoggedin")
                                    self.view.makeToast("You have been registered successfully\(message)")
                                    let contentArr = JSON["result"] as? NSArray
                                    let dict = contentArr?.firstObject as? NSDictionary
                                    print("OTPVerifyRes---\(dict)")
                                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: contentArr),forKey: "userDetails")
                                    UserDefaults.standard.setValue(dict?["email"] as? String ?? "", forKey: "email")
                                    UserDefaults.standard.setValue(dict?["mobilenumber"] as? String ?? "", forKey: "mobileNo")
                                    let firstname = dict?["firstname"] as? String ?? ""
                                    UserDefaults.standard.setValue(firstname, forKey: "firstname")
                                    let lastName = dict?["lastname"] as? String ?? ""
                                    UserDefaults.standard.setValue(lastName, forKey: "lastname")
                                    UserDefaults.standard.setValue("\(firstname) \(lastName)", forKey: "userName")
                                    UserDefaults.standard.setValue(dict?["image"] as? String ?? "", forKey: "userImage")
                                    UserDefaults.standard.setValue(dict?["_id"] as Any, forKey: "userID")
                                    UserDefaults.standard.setValue(dict?["password"] as Any, forKey: "userPassword")
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                                    self.navigationController?.pushViewController(vc, animated: true)
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
            
    
    @IBAction func mResendCode(_ sender: Any) {
        
        let parameters: Parameters =
            [
                
                "mobilenumber": String(format: "%@", mob!),
        ]
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)customer_table/resendotp", method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
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
                                    SKActivityIndicator.dismiss()
                                    
                                    let contentArr = JSON["result"] as? NSArray
                                    let dict = contentArr?.firstObject as! NSDictionary
                                    self.otpDetails = (dict["otp"] as! String)
                                    self.view.makeToast(self.otpDetails)
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
        }
        else{
            self.view.makeToast(Constants.OFFLINE_MESSAGE)
        }
    }
   
}
