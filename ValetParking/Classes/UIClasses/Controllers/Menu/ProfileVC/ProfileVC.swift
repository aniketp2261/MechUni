
 //
//  ProfileVC.swift
//  ValetParking
//
//  Created by Khushal on 19/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import Toast_Swift
import SDWebImage
import SKCountryPicker
import DatePicker

@available(iOS 13.0, *)
class ProfileVC: UIViewController, UIAlertViewDelegate  {
    
    @IBOutlet weak var mContentView: UIView!
    @IBOutlet weak var mChangeImageBtn: UIButton!
    @IBOutlet weak var mSaveBtn: UIButton!
    @IBOutlet weak var BackImg: UIImageView!
    
    @IBOutlet weak var mMobileNoView: UIView!
    @IBOutlet weak var mFirstNameView: UIView!
    @IBOutlet weak var mLastNameView: UIView!
    @IBOutlet weak var mEmailView: UIView!
  
    @IBOutlet weak var mDateOfBirthView: UIView!
   
    @IBOutlet weak var mMobileNoTF: CustomFontTextField!
    @IBOutlet weak var mNameTF: CustomFontTextField!
    @IBOutlet weak var mLastNameTF: CustomFontTextField!
    @IBOutlet weak var mEmailTF: CustomFontTextField!
    
    @IBOutlet weak var countryBtn : UIButton!
    @IBOutlet weak var countryFlag : UIImageView!
   
    @IBOutlet weak var mDOBTF: CustomFontTextField!

   
    @IBOutlet weak var mImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    //ExitView
    
    @IBOutlet var mExitView: UIView!
    @IBOutlet weak var mDatePicker: UIDatePicker!
    
    var imagePath: String?
    var imageChange: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
//      let nc = NotificationCenter.default
//      nc.post(name: Notification.Name("load"), object: nil)
//      sideMenuController?.isLeftViewSwipeGestureEnabled = true
//      imagePicker.delegate = self
//      self.mLastNameLabel.isHidden = true
        self.mMobileNoTF.isEnabled = true
        self.mNameTF.isEnabled = true
        self.mLastNameTF.isEnabled = true
        self.mMobileNoView.layer.cornerRadius = 20
        self.mMobileNoView.layer.borderWidth = 1
        self.mMobileNoView.layer.borderColor = UIColor.gray.cgColor
        self.mFirstNameView.layer.cornerRadius = 20
        self.mFirstNameView.layer.borderWidth = 1
        self.mFirstNameView.layer.borderColor = UIColor.gray.cgColor
        self.mLastNameView.layer.cornerRadius = 20
        self.mLastNameView.layer.borderWidth = 1
        self.mLastNameView.layer.borderColor = UIColor.gray.cgColor
        self.mEmailView.layer.cornerRadius = 20
        self.mEmailView.layer.borderWidth = 1
        self.mEmailView.layer.borderColor = UIColor.gray.cgColor
        self.mDateOfBirthView.layer.cornerRadius = 20
        self.mDateOfBirthView.layer.borderWidth = 1
        self.mDateOfBirthView.layer.borderColor = UIColor.gray.cgColor
        self.mChangeImageBtn.layer.borderWidth = 1
        self.mChangeImageBtn.layer.borderColor = UIColor.red.cgColor
        self.mChangeImageBtn.layer.cornerRadius = mChangeImageBtn.bounds.height/2

        self.mSaveBtn.layer.borderWidth = 1
        self.mSaveBtn.layer.borderColor = UIColor.red.cgColor
        self.mSaveBtn.layer.cornerRadius = mSaveBtn.bounds.height/2
        
        BackImg.isUserInteractionEnabled = true
        let backTap = UITapGestureRecognizer(target: self, action: #selector(back))
        BackImg.addGestureRecognizer(backTap)
        
        let country = CountryManager.shared.currentCountry
        countryBtn.setTitle(country?.dialingCode, for: .normal)
        countryFlag.image = country?.flag
        mImageView.layer.cornerRadius = mImageView.frame.size.height/2
        mImageView.layer.masksToBounds = true
        refeshUI()
        ProfileData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        refeshUI()
    }
    func ProfileData(){
        self.mNameTF.text = UserDefaults.standard.string(forKey: "firstname")
        self.mLastNameTF.text = UserDefaults.standard.string(forKey: "lastname")
        self.mEmailTF.text = UserDefaults.standard.string(forKey: "email")
        self.mDOBTF.text = UserDefaults.standard.string(forKey: "dob")
        let isLoggedin = UserDefaults.standard.string(forKey: "isLoggedin") ?? "0"
        let url = UserDefaults.standard.string(forKey: "userImage") ?? ""
        if url == "" {
            print("IFUrlll---\(url)")
            self.mImageView.image = #imageLiteral(resourceName: "UserImage")
        } else{
            print("ELSEUrlll---\(url)")
            self.mImageView.sd_setImage(with: URL(string: APIEndPoints.BASE_IMAGE_URL + url), placeholderImage: #imageLiteral(resourceName: "UserImage"), options: [], context: nil)
        }
        if(isLoggedin == "1")
        {
            self.mContentView.isHidden = false
        }
        else{
            self.mContentView.isHidden = true
            let alert = UIAlertView(title: "", message: "Login is required to access this feature", delegate: self, cancelButtonTitle: "CANCEL", otherButtonTitles: "GO TO LOGIN")
            alert.tag = 100
            alert.show()
        }
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == 100 {
            if buttonIndex == 1 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                
            }
        }
    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func refeshUI(){
        var isLoggedin = UserDefaults.standard.string(forKey: "isLoggedin") ?? "0"
        if(isLoggedin == "1")
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            let currentDefaults = UserDefaults.standard
            let savedArray = currentDefaults.object(forKey: "userDetails") as? Data
            if savedArray != nil {
                var oldArray: [Any]? = nil
                if let anArray = savedArray {
                    oldArray = NSKeyedUnarchiver.unarchiveObject(with: anArray) as? [Any]
                    if let dict = oldArray?.first as? NSDictionary {
            
                        let MoNumber = dict["mobilenumber"] as? String ?? ""
                        self.mMobileNoTF.text = String(MoNumber.dropFirst(2))
                        self.mNameTF.text = dict["firstname"] as? String ?? ""
                        self.mLastNameTF.text = dict["lastname"] as? String ?? ""
                        self.mEmailTF.text = dict["email"] as? String ?? ""
                        self.mDOBTF.text = dict["dob"] as? String ?? ""
                        if dict["email"] as? String ?? "" == ""{
                            self.mEmailTF.isEnabled = true
                        } else{
                            self.mEmailTF.isEnabled = true
                        }
                        if let actionString =  dict["image"] as? String as NSString? {
                        // action is not nil, is a String type, and is now stored in actionString
                            let url = String(format: "%@%@",APIEndPoints.BASE_IMAGE_URL ,actionString)
                            self.imagePath = String(format: "%@",(dict["image"] as? String)!)
                        let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                            print("URLLLL--\(urlString)")
                            if url == "" || url == "https://apis.mechuni.com/" || url == "https://apis.mechuni.com/dev_apis/"{
                                self.mImageView.image = #imageLiteral(resourceName: "UserImage")
                            } else{
                                self.mImageView.sd_setImage(with: URL(string: urlString ?? ""), placeholderImage: #imageLiteral(resourceName: "UserImage"), options: [], context: nil)
                            }
                    } else {
                        // action was either nil, or not a String type
                    }
                    self.mImageView.layer.cornerRadius = mImageView.frame.size.height/2
                    self.mImageView.layer.masksToBounds = true
                }
            }
        }
        } else{
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    @IBAction func countryBtnClicked(_ sender: Any){
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { (country: Country) in
            self.countryFlag.image = country.flag
            self.countryBtn.setTitle(country.dialingCode, for: .normal)
        }
        countryController.detailColor = UIColor.black
    }
   
    @objc func back() {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func changeImage(_ sender: Any) {
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            DispatchQueue.main.async {
                self.openCamera()
            }
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            DispatchQueue.main.async {
                self.openGallary()
            }
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
        
        //        self.imageViewPicker.frame = self.view.frame
        //        self.view.addSubview(self.imageViewPicker)
    }
    public enum ImageFormat {
        case png
        case jpeg(CGFloat)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled")
        picker.dismiss(animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        } else
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
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func mSelectDOB(_ sender: Any) {
        let datePicker = DatePicker()
//      self.mExitView.frame = self.view.frame
//      self.view.addSubview(self.mExitView)
        let date = Date()
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.day, .month, .year], from: date)
        let minDate = DatePickerHelper.shared.dateFrom(day: components1.day!, month: components1.month!, year: 1960)!
        let maxDate = DatePickerHelper.shared.dateFrom(day: components1.day!, month: components1.month!, year: components1.year!)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let date1 = dateFormatter.date(from: self.mDOBTF.text!)
        datePicker.setup(beginWith: date1, min: minDate, max: maxDate) { selected, Date in
            if selected, let selectedDate = Date{
                print("SelectedDate --- \(selectedDate.string())")
                self.mDOBTF.text = dateFormatter.string(from: selectedDate)
            } else{
                print("Cancelled")
            }
        }
//        datePicker.setColors(main: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), background: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), inactive: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
        datePicker.show(in: self)
    }
    
    @IBAction func mSave(_ sender: Any) {
        let Emailbool = self.isValidEmail(testStr: mEmailTF.text!)
        print(Emailbool)
        if(mNameTF.text == "")
        {
            self.view.makeToast("Please enter your first name.")
            return
        }
        else if(mLastNameTF.text == "")
        {
            self.view.makeToast("Please enter your last name.")
            return
        }
        else if(mDOBTF.text == "")
        {
            self.view.makeToast("Please enter your DOB.")
            return
        }
        else if(Emailbool == false)
        {
            self.view.makeToast("Please enter a valid email");
            return
        }
        let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
        let parameters: Parameters =
        [
            "_id": idValue as Any,
            "firstname": String(format: "%@", self.mNameTF.text!),
            "lastname":  String(format: "%@", self.mLastNameTF.text!),
            "image": imagePath as Any,
            "dob":  String(format: "%@", self.mDOBTF.text!),
            "email": String(format: "%@", self.mEmailTF.text!)
        ]
        print(parameters)
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)customer_table/update_profile", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("UpdateProfileResponse: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                let message = JSON["message"] as? String
                                self.view.makeToast(message)
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String
                                
                                if status != "success" {
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                }else{
                                    SKActivityIndicator.dismiss()
                                    let contentArr = JSON["result"] as? NSArray
                                    if contentArr?.count != 0{
                                        let dict = contentArr?.firstObject as! NSDictionary
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshUI"), object: nil)
                                        UserDefaults.standard.setValue(dict["dob"] as! String, forKey: "dob")
                                        UserDefaults.standard.setValue(dict["email"] as! String, forKey: "email")
                                        let firstname = dict["firstname"] as! String
                                        let lastname = dict["lastname"] as! String
                                        UserDefaults.standard.setValue(firstname, forKey: "firstname")
                                        UserDefaults.standard.setValue(lastname, forKey: "lastname")
                                        UserDefaults.standard.setValue("\(firstname) \(lastname)", forKey: "userName")
                                        UserDefaults.standard.setValue(dict["mobilenumber"] as! String, forKey: "mobileNo")
                                        UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: contentArr), forKey: "userDetails")
                                        UserDefaults.standard.synchronize()
                                    }
                                    DispatchQueue.main.async {
                                        self.navigationController?.popViewController(animated: true)
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
    //ExitView Buttons
    @IBAction func mExitBack(_ sender: Any) {
        let btn = sender as? UIButton
        if btn?.tag == 101 || btn?.tag == 102
        {
            self.mExitView.removeFromSuperview()
        }
    }
    
    func uploadImage()
    {
        let imgData = mImageView.image!.jpegData(compressionQuality: 0.2)!
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "myImage",fileName: "file.jpg", mimeType: "image/jpg")
            //        for (key, value) in parameters {
            //            multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            //        } //Optional for extra parameters
         //             "http://54.206.24.194:3000/uploads/upload_single"
        },
            to: APIEndPoints.BaseURL+"uploads/upload_single")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.completedUnitCount)")
                })
                upload.responseJSON { response in
                    print(response.result.value)
                    if let json = response.result.value {
                        let JSON = json as! NSDictionary
                        let msg = JSON["message"] as? String ?? ""
                        self.imagePath = String(format : "%@",JSON["file"] as? String ?? "")
                        UserDefaults.standard.setValue(self.imagePath ?? "", forKey: "userImage")
                        self.view.makeToast(msg)
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
}
@available(iOS 13.0, *)
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //MARK: - UIImagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /*
         Get the image from the info dictionary.
         If no need to edit the photo, use `UIImagePickerControllerOriginalImage`
         instead of `UIImagePickerControllerEditedImage`
         */
        print("imagePickerController00000 ------")
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            print("imagePickerController00000 ------\(editedImage)")
            DispatchQueue.main.async {
                self.mImageView.image = editedImage
                self.mImageView.layer.cornerRadius = self.mImageView.frame.size.height/2
                self.mImageView.layer.masksToBounds = true
                picker.dismiss(animated: true, completion: nil)
                self.uploadImage()
            }
        }
        //Dismiss the UIImagePicker after selection
    }
}
