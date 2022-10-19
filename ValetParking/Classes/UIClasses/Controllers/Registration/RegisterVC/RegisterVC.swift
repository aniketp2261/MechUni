//
//  RegisterVC.swift
//  ValetParking
//
//  Created by Khushal on 16/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire
import SKActivityIndicatorView
import SKCountryPicker
import SafariServices

class RegisterVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //UIView
    @IBOutlet weak var mMobileNoView: UIView!
    @IBOutlet weak var mEmailView: UIView!
    @IBOutlet weak var mPasswordView: UIView!
    @IBOutlet weak var mRePassword: UIView!
    @IBOutlet weak var mUploadImage: UIButton!
    
    @IBOutlet weak var checkBtn: UIButton!
    //imageView
    @IBOutlet weak var mImageView: UIImageView!
     let imagePicker = UIImagePickerController()
    @IBOutlet weak var mProceedBtn: UIButton!
    
    //TextField
    @IBOutlet weak var mMobileNoTF: UITextField!
    @IBOutlet weak var mRePasswordTF: UITextField!
    @IBOutlet weak var mPasswordTF: UITextField!
    @IBOutlet weak var mEmailTF: UITextField!
    
    
    @IBOutlet weak var viewFName: UIView!
    @IBOutlet weak var tfviewFName: UITextField!
    @IBOutlet weak var viewLName: UIView!
    @IBOutlet weak var tfviewLName: UITextField!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var viewMobileNo: UIView!
    @IBOutlet weak var tfviewMobileNo: UITextField!
    @IBOutlet weak var btnC: UIButton!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var termsCondLbl: UILabel!
    @IBOutlet weak var PrivacyPolicyLbl: UILabel!
    @IBOutlet weak var CheckBoxImg: UIImageView!
    
    var imagePath: String?
    var timer = Timer()
    var privacyCheck = true
    var checked = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        //
        //mImageView.backgroundColor = UIColor.blue
        imagePicker.delegate = self
      
        self.viewFName.layer.cornerRadius = 20
        self.viewFName.layer.borderWidth = 1
        self.viewFName.layer.borderColor = UIColor.gray.cgColor
        self.viewLName.layer.cornerRadius = 20
        self.viewLName.layer.borderWidth = 1
        self.viewLName.layer.borderColor = UIColor.gray.cgColor
        self.viewMobileNo.layer.cornerRadius = 20
        self.viewMobileNo.layer.borderWidth = 1
        self.viewMobileNo.layer.borderColor = UIColor.gray.cgColor
        self.viewPassword.layer.cornerRadius = 20
        self.viewPassword.layer.borderWidth = 1
        self.viewPassword.layer.borderColor = UIColor.gray.cgColor
        self.mProceedBtn.layer.cornerRadius = 20
        self.mProceedBtn.layer.borderWidth = 1
        self.mProceedBtn.layer.borderColor = #colorLiteral(red: 1, green: 0.0862745098, blue: 0.0862745098, alpha: 1)
      
        let country = CountryManager.shared.currentCountry
        btnC.setTitle(country?.dialingCode, for: .normal)
        imgFlag.image = country?.flag
 
        tfviewFName.placeholder = "Enter first name"
        tfviewLName.placeholder = "Enter last name"
        tfviewMobileNo.placeholder = "Enter mobile number"
        tfPassword.placeholder = "Enter password"
        tfviewMobileNo.keyboardType = .numberPad
        tfviewFName.autocapitalizationType = .sentences
        tfviewLName.autocapitalizationType = .sentences
        CheckBoxImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(funcCheckbox)))
        PrivacyPolicyLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PrivacyPolicy)))
        termsCondLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TermsAndConditions)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    @objc func funcCheckbox() {
        if privacyCheck{
            CheckBoxImg.image = UIImage(named: "icChecked")
            checked = 1
            privacyCheck = false
        } else{
            CheckBoxImg.image = UIImage(named: "square")
            checked = 0
            privacyCheck = true
        }
   }
    @objc func TermsAndConditions(){
        let appleURL = "https://www.mechuni.com/MECHUNI%20TERMS%20AND%20CONDITIONS.pdf"
        let sfVc = SFSafariViewController(url: URL(string: appleURL)!)
        sfVc.delegate = self
        self.navigationController?.pushViewController(sfVc, animated: false)
    }
    @objc func PrivacyPolicy(){
        let appleURL = "https://mechuni.com/PRIVACY%20POLICY%20MECHUNI.pdf"
        let sfVc = SFSafariViewController(url: URL(string: appleURL)!)
        sfVc.delegate = self
        self.navigationController?.pushViewController(sfVc, animated: false)
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
//        if textField == mPasswordTF{
//            if (mPasswordTF.text?.count)! <= 5
//            {
//
//               self.view.makeToast("Minimum 6 character shuold enter");
//                  return true
//
//            }
//        }

        return true
    }
    @IBAction func backPress(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //Email Validate
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    // Button Actions
    
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkBox(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            
        }else{
            sender.isSelected = true
            
        }
    }
    
    @IBAction func countryBtnClicked(_ sender: Any) {
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { (country: Country) in
            self.imgFlag.image = country.flag
            self.btnC.setTitle(country.dialingCode, for: .normal)
        }
        countryController.detailColor = UIColor.black
    }
    
    @IBAction func btnPrivacyPolicy(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "PrivacyVC") as! PrivacyVC
        self.navigationController?.pushViewController(myVC, animated: true)
    }
    
    @IBAction func registerUSer(_ sender: Any) {
        if(tfviewFName.text == "")
        {
            self.view.makeToast("Please enter your first name!");
            return
        } else if(tfviewLName.text == "")
        {
            self.view.makeToast("Please enter your last name!");
            return
        } else if(tfviewMobileNo.text == "")
        {
            self.view.makeToast("Please enter your mobile number!")
            return
        } else if(tfviewMobileNo.text!.count < 10 || tfviewMobileNo.text!.count > 10)
        {
            self.view.makeToast("Please enter proper mobile number!")
            return
        } else if(tfPassword.text == "")
        {
            self.view.makeToast("Please enter your password!");
            return
        } else if(checked == 0)
        {
            self.view.makeToast("Please Accept terms & conditions and privacy policy")
            return
        } else {
        let cc = self.btnC.currentTitle
        let strCC = cc?.dropFirst()
        var parameters =
        [
            "_id":"",
            "verified":"",
            "email":"",
            "re_enter_password":"",
            "terms_conditions":"",
            "image":"",
            "messagekey":"",
            "mobilenumber": "\(strCC!)\(self.tfviewMobileNo.text!)",
            "firstname": String(format: "%@", self.tfviewFName.text!),
            "lastname": String(format: "%@", self.tfviewLName.text!),
            "password": String(format: "%@", self.tfPassword.text!)
        ]
        print("Param --- \(parameters)")
        
//        if self.imagePath != nil {
//            parameters["image"] = self.imagePath
//        }
        
        if Connectivity.isConnectedToInternet
        {
            print("Param --- \(parameters)")
            SKActivityIndicator.show("Loading...")
            print("Register ---- \(APIEndPoints.BaseURL)\(APIEndPoints.register)")
            Alamofire.request("\(APIEndPoints.BaseURL)\(APIEndPoints.register)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        print("Response: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String

                                if status == "success" {
                                    let contentArr = JSON["result"] as? NSArray
                                    if (contentArr?.count)! != 0
                                    {
                                        let dict = contentArr?.firstObject as! NSDictionary
                                        UserDefaults.standard.setValue(dict["_id"] as Any, forKey: "userID")
                                        UserDefaults.standard.setValue(dict["password"] as Any, forKey: "userPassword")
                                        UserDefaults.standard.setValue(dict["image"] as Any, forKey: "userImage")
//                                            image = "/myImage-1584084903962.jpg";
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = storyboard.instantiateViewController(withIdentifier: "OTPVC") as! OTPVC
                                        vc.otpDetails = (dict["otp"] as? String)!
                                        vc.mob = "\(strCC!)\(self.tfviewMobileNo.text!)"
//                                        self.view.makeToast("Your otp is \(dict["otp"] as? String ?? "0000")")
                                        DispatchQueue.main.async {
                                            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                                                UserDefaults.standard.setValue(true, forKey: "isLoggedin")
                                                SKActivityIndicator.dismiss()
                                                self.navigationController?.pushViewController(vc, animated: true)
                                            }
                                        }
                                    }
                                } else{
                                    SKActivityIndicator.dismiss()
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message)
                                }
                            } else {
                                SKActivityIndicator.dismiss()
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
    @IBAction func btnTermsClicked(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "TermsVC") as! TermsVC
        self.navigationController?.pushViewController(myVC, animated: true)
    }

    @IBAction func passwordLenght(_ sender: Any) {
        if (mPasswordTF.text?.count)! < 6
        {
            self.view.makeToast("Minimum 6 character shuold enter");
        }
    }
    
//    @IBAction func editingChanged(_ sender: Any) {
//    
//    if self.mMobileNoTF.text != "" && self.mEmailTF.text != "" && self.mPasswordTF.text != "" && self.mRePasswordTF.text != "" {
//            self.mProceedBtn.alpha = 1
//            self.mProceedBtn.isUserInteractionEnabled = true
//        }else{
//            self.mProceedBtn.alpha = 0.5
//            self.mProceedBtn.isUserInteractionEnabled = false
//        }
//    }
    
    @IBAction func mUploadImage(_ sender: Any) {
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = (sender as! UIView)
            alert.popoverPresentationController?.sourceRect = (sender as AnyObject).bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
       
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //mImageView.contentMode = .scaleAspectFit
            mImageView.image = pickedImage
            mImageView.layer.cornerRadius = mImageView.frame.size.height/2
            mImageView.layer.masksToBounds = true
            uploadImage()
        }
        
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage()
    {
        
        let imgData = mImageView.image!.jpegData(compressionQuality: 0.2)!
        
        //let parameters = ["name": rname] //Optional for extra parameter
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "myImage",fileName: "file.jpg", mimeType: "image/jpg")
            //        for (key, value) in parameters {
            //            multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            //        } //Optional for extra parameters
        },
                         to:Constants.BASEURL+"uploads/upload_single")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    print(response.result.value)
                    if let json = response.result.value {
                        let JSON = json as! NSDictionary
                        self.imagePath = String(format : "%@",JSON["file"] as!  String)
                        //   UserDefaults.standard.set(self.imagePath, forKey: "userImage")
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
}
extension RegisterVC: SFSafariViewControllerDelegate{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("safariViewControllerDidFinish")
        self.navigationController?.popViewController(animated: true)
    }
}
