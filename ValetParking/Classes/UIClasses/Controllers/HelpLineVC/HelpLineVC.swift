//
//  HelpLineVC.swift
//  ValetParking
//
//  Created by Khushal on 15/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire
import SKActivityIndicatorView
import SKCountryPicker

class HelpLineVC: UIViewController, UITextFieldDelegate, UIAlertViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var countryBtn: UIButton!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var imgLeftMenu: UIImageView!
    @IBOutlet weak var lbNumber: UILabel!

    
    @IBOutlet weak var mNameView: UIView!
    @IBOutlet weak var mEmailView: UIView!
    @IBOutlet weak var mPhoneView: UIView!
    @IBOutlet weak var mMessageView: UIView!
    
    @IBOutlet weak var mNameTF: UITextField!
    @IBOutlet weak var mPhoneNoTF: UITextField!
    @IBOutlet weak var mEmailTF: UITextField!
    
    @IBOutlet weak var messageTV: UITextView!

    @IBOutlet weak var messageTF: UITextField!
    
    @IBOutlet weak var mSubmitBtn: UIButton!
    
    var isFromMenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mNameView.layer.cornerRadius = 20
        self.mNameView.layer.borderWidth = 1
        self.mNameView.layer.borderColor = UIColor.gray.cgColor
        self.mEmailView.layer.cornerRadius = 20
        self.mEmailView.layer.borderWidth = 1
        self.mEmailView.layer.borderColor = UIColor.gray.cgColor
        self.mPhoneView.layer.cornerRadius = 20
        self.mPhoneView.layer.borderWidth = 1
        self.mPhoneView.layer.borderColor = UIColor.gray.cgColor
        self.mMessageView.layer.cornerRadius = 20
        self.mMessageView.layer.borderWidth = 1
        self.mMessageView.layer.borderColor = UIColor.gray.cgColor
        self.mSubmitBtn.layer.cornerRadius = 20
        
        let country = CountryManager.shared.currentCountry
        countryBtn.setTitle(country?.dialingCode, for: .normal)
        imgFlag.image = country?.flag
        
        //placeholder color
        mNameTF.attributedPlaceholder = NSAttributedString(string:"Your name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        mPhoneNoTF.attributedPlaceholder = NSAttributedString(string:"Your phone number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        mEmailTF.attributedPlaceholder = NSAttributedString(string:"Your email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
//         messageTF.attributedPlaceholder = NSAttributedString(string:"Your message", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])

        imgLeftMenu.image = isFromMenu ? UIImage(named: "menu") : UIImage(named: "back")
        messageTV.text = "Your message"
//        messageTV.placeholderColor = UIColor.black
        messageTV.textColor = UIColor.black

        self.getHelpLineNumber()
        
//        self.mSubmitBtn.alpha = 0.5
//        self.mSubmitBtn.isUserInteractionEnabled = false
    }

    
    func getHelpLineNumber() {

        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            //ANLoader.showLoading()
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(Constants.BASEURL)admin_helpline/get_number", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("Response: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                let status = JSON["status"] as? String
                                if status == "failed" {
                                    //ANLoader.hide()
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                }else{
                                    if let arrRe = JSON["result"] as? [[String:Any]], arrRe.count > 0 {
                                        let dict = arrRe[0]
                                        if let number = dict["helpline_number"] as? Int {
                                            self.lbNumber.text = "+\(number)"
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
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == mPhoneNoTF{
            if Int(range.location) >= 10
            {
                return false
            }
        }
        
        return true
    }

    //Email Validate
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    // Button Actn
    @IBAction func countryBtnClicked(_ sender: Any) {
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { (country: Country) in
            self.imgFlag.image = country.flag
            self.countryBtn.setTitle(country.dialingCode, for: .normal)
        }
        countryController.detailColor = UIColor.black
    }
    
    
    @IBAction func leftButtonClicked(_ sender: Any) {
        if isFromMenu {
            self.showLeftView(sender)
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func mSubmitActn(_ sender: Any) {

        if(mNameTF.text == "")
        {
            self.view.makeToast("Please enter your name");
            
            return
        }
      else if(mEmailTF.text == "")
        {
            self.view.makeToast("Please enter your email");
            
            return
        }
        else
        {
            var bool = self.isValidEmail(testStr: mEmailTF.text!)
            if bool == false{
                self.view.makeToast("Please enter a valid email");
                return
            }
            print(bool)
        }
        if(mPhoneNoTF.text == "")
        {
            self.view.makeToast("Please enter your phone number");
            
            return
        }else if(messageTV.text == "Your message" || messageTV.text.count == 0)
        {
            self.view.makeToast("Please enter your message");
            
            return
        }
        let cc = self.countryBtn.currentTitle
        let strCC = cc?.dropFirst()
      //
        let parameters: Parameters =
            [
                "name": String(format: "%@", self.mNameTF.text!),
                "mobilenumber": "\(strCC!)\(self.mPhoneNoTF.text!)",
                "email": String(format: "%@", self.mEmailTF.text!),
                  "message": String(format: "%@", self.messageTV.text!)
                
                ]
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            //ANLoader.showLoading()
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(Constants.BASEURL)help_line/add_help_line", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
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
                                    //ANLoader.hide()
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                }else{
                                    
                                    //self.view.makeToast("Your query has been submitted succesfully");
                                    let alert = UIAlertView(title: "", message: "Your query has been submitted succesfully", delegate: self, cancelButtonTitle: "OK")
                                    alert.tag = 100
                                    alert.show()
                                    // self.present(alert, animated: true, completion: nil)
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
    }
      
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == 100 {
            let isLoggedin = UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
            if(isLoggedin == true)
            {
                self.navigationController?.popViewController(animated: false)
            } else {
                if isFromMenu {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let updatedTxt = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        if range.location == 0 && (updatedTxt == " ") || range.location == 0 && (updatedTxt == "\n"){
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Your message" {
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Your message"
        }
    }
}


