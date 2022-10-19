//
//  SettingsVC.swift
//  ValetParking
//
//  Created by Khushal on 22/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import Toast_Swift

class ChangePasswordVC: UIViewController {
    
    @IBOutlet weak var mCurrentPswdView: UIView!
    @IBOutlet weak var mNewPswdView: UIView!
    @IBOutlet weak var mRePswdView: UIView!
    @IBOutlet weak var BackImg: UIImageView!
    
    @IBOutlet weak var mCurrentPswdTF: CustomFontTextField!
    @IBOutlet weak var mRePswdTF: CustomFontTextField!
    @IBOutlet weak var mNewPswdTF: CustomFontTextField!
    
    @IBOutlet weak var CurrentTFEye : UIButton!
    @IBOutlet weak var NewPassTFEye : UIButton!
    @IBOutlet weak var RePassTFEye : UIButton!

    var curentPswd : String!
    var iconClick1 = true
    var iconClick2 = true
    var iconClick3 = true
    
    @IBOutlet weak var mSaveBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mCurrentPswdView.layer.cornerRadius = 20
        self.mCurrentPswdView.layer.borderWidth = 1
        self.mCurrentPswdView.layer.borderColor = UIColor.gray.cgColor
        self.mNewPswdView.layer.cornerRadius = 20
        self.mNewPswdView.layer.borderWidth = 1
        self.mNewPswdView.layer.borderColor = UIColor.gray.cgColor
        self.mRePswdView.layer.cornerRadius = 20
        self.mRePswdView.layer.borderWidth = 1
        self.mRePswdView.layer.borderColor = UIColor.gray.cgColor
        self.mSaveBtn.layer.borderWidth = 1
        self.mSaveBtn.layer.borderColor = UIColor.red.cgColor
        self.mSaveBtn.layer.cornerRadius = mSaveBtn.bounds.height/2
        self.curentPswd = UserDefaults.standard.string(forKey: "userPassword")
        BackImg.isUserInteractionEnabled = true
        BackImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(back)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        if (mNewPswdTF.text?.count)! < 6
        {
            self.view.makeToast("Minimum 6 character should enter");
        }
    }
    @IBAction func CurrentPassHideShow(){
        if(iconClick1 == true) {
            mCurrentPswdTF.isSecureTextEntry = false
            CurrentTFEye.setImage(UIImage(named: "eye24px"), for: .normal)
        } else {
            CurrentTFEye.setImage(UIImage(named: "eyeD24px"), for: .normal)
            mCurrentPswdTF.isSecureTextEntry = true
        }
       iconClick1 = !iconClick1
    }
    @IBAction func NewPassHideShow(){
        if(iconClick2 == true) {
            mNewPswdTF.isSecureTextEntry = false
            NewPassTFEye.setImage(UIImage(named: "eye24px"), for: .normal)
        } else {
            NewPassTFEye.setImage(UIImage(named: "eyeD24px"), for: .normal)
            mNewPswdTF.isSecureTextEntry = true
        }
       iconClick2 = !iconClick2
    }
    @IBAction func RePassHideShow(){
        if(iconClick3 == true) {
            mRePswdTF.isSecureTextEntry = false
            RePassTFEye.setImage(UIImage(named: "eye24px"), for: .normal)
        } else {
            RePassTFEye.setImage(UIImage(named: "eyeD24px"), for: .normal)
            mRePswdTF.isSecureTextEntry = true
        }
       iconClick3 = !iconClick3
    }
    
    @IBAction func mSave(_ sender: Any) {

        if(mCurrentPswdTF.text == "")
        {
            self.view.makeToast("Please enter your current password.");
            return
        }
        else if(mNewPswdTF.text == "")
        {
            self.view.makeToast("Please enter your new password.");
            return
        }
        else if(mRePswdTF.text == "")
        {
            self.view.makeToast("Please confirm your new password.");
            return
        }
        if mNewPswdTF.text != mRePswdTF.text {
            self.view.makeToast("Password and confirm password should be same.")
            return
        }
        if(mCurrentPswdTF.text != curentPswd)
        {
            self.view.makeToast("Your current password is not correct.")
            return
        }
        if(mNewPswdTF.text?.count ?? 0 < 6){
            self.view.makeToast("Minimum 6 character should enter");
            return
        }
        let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
        let parameters: Parameters =
        [
            "_id": idValue as Any,
            "password": String(format: "%@", self.mNewPswdTF.text!)
        ]
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)customer_table/change_password", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
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
                                } else {
                                    let message = "Your password has been changed successfully."
                                    self.view.makeToast(message);
                                    self.mCurrentPswdTF.text = ""
                                    self.mNewPswdTF.text = ""
                                    self.mRePswdTF.text = ""
                                    UserDefaults.standard.setValue(false, forKey: "isLoggedin")
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let myVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                                    if let aVC = myVC {
                                        Constants.kNavigationController?.pushViewController(aVC, animated: true)
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
    @objc func back() {
        self.navigationController?.popViewController(animated: false)
    }
    
}
