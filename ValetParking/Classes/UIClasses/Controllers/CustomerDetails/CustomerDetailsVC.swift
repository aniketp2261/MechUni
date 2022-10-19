//
//  CustomerDetailsVC.swift
//  ValetParking
//
//  Created by Khushal on 17/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import SKActivityIndicatorView

class CustomerDetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var mobileNoView: UIView!
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var dateOfBirthView: UIView!
    
    @IBOutlet weak var mContinueBtn: UIButton!
    @IBOutlet weak var mImageBtn: UIButton!
    
    
    
    @IBOutlet weak var mImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var mobileNoTF: CustomFontTextField!
    @IBOutlet weak var firstNameTF: CustomFontTextField!
    @IBOutlet weak var lastNameTF: CustomFontTextField!
    @IBOutlet weak var emailTF: CustomFontTextField!
    
    @IBOutlet weak var dateOfBirthTF: CustomFontTextField!
    //ExitView
    @IBOutlet var mDateView: UIView!
    @IBOutlet weak var mDatePicker: UIDatePicker!
    
    var userMobile : String?
    var userEmail : String?
   
    var fileStr : String?
    override func viewDidLoad() {
        super.viewDidLoad()
       imagePicker.delegate = self
      
        self.mobileNoView.layer.cornerRadius = 20
        self.mobileNoView.layer.borderWidth = 1
        self.mobileNoView.layer.borderColor = UIColor.gray.cgColor
        self.firstNameView.layer.cornerRadius = 20
        self.firstNameView.layer.borderWidth = 1
        self.firstNameView.layer.borderColor = UIColor.gray.cgColor
        self.lastNameView.layer.cornerRadius = 20
        self.lastNameView.layer.borderWidth = 1
        self.lastNameView.layer.borderColor = UIColor.gray.cgColor
        self.emailView.layer.cornerRadius = 20
        self.emailView.layer.borderWidth = 1
        self.emailView.layer.borderColor = UIColor.gray.cgColor
        self.dateOfBirthView.layer.cornerRadius = 20
        self.dateOfBirthView.layer.borderWidth = 1
        self.dateOfBirthView.layer.borderColor = UIColor.gray.cgColor
        
        self.mContinueBtn.layer.cornerRadius = 20
        self.mImageBtn.layer.borderWidth = 2
        self.mImageBtn.layer.borderColor = UIColor.gray.cgColor
        
//        self.mContinueBtn.alpha = 0.5
//        self.mContinueBtn.isUserInteractionEnabled = false
        //
        self.mobileNoTF.text = "+ " + userMobile!
        self.emailTF.text = userEmail
        
        if let actionString = UserDefaults.standard.value(forKey: "userImage") as? NSString {
            // action is not nil, is a String type, and is now stored in actionString
            let url = String(format: "%@%@",APIEndPoints.BASE_IMAGE_URL ,actionString)
            self.fileStr = String(format: "%@",actionString)
            let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            self.mImageView.sd_setImage(with: URL(string: urlString!), placeholderImage: UIImage(named: "userImage"))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Button Actions
    
    @IBAction func mContinueActn(_ sender: Any) {
        if(firstNameTF.text == "")
        {
            self.view.makeToast("Enter First Name")
            return
        }
            
//        else if(lastNameTF.text == "")
//        {
//            self.view.makeToast("Enter Last Name")
//
//            return
//        }
        else if(dateOfBirthTF.text == "")
        {
            self.view.makeToast("Enter Date of Birth")
            
            return
        }
     
        
        let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
        
        
        let parameters: Parameters =
            [
                "firstname": String(format: "%@", self.firstNameTF.text!),
                "lastname":  String(format: "%@", self.lastNameTF.text!),
                "dob":  String(format: "%@", self.dateOfBirthTF.text!),
                "_id": idValue as Any,
                "image": fileStr as Any

                ]
        print(fileStr)
        print(parameters)
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            //ANLoader.showLoading()
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(Constants.BASEURL)customer_table/addDetails", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
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
                                    SKActivityIndicator.dismiss()
                                    self.view.makeToast("Information saved successfully");
                                    UserDefaults.standard.setValue(true, forKey: "isLoggedin")
                                    let contentArr = JSON["result"] as? NSArray
                                    let dict = contentArr?.firstObject as! NSDictionary
                                    //
                                    //                                let myDate = (dict["dob"] as? String)!
                                    //                                let dateFormatter = DateFormatter()
                                    //                                let tempLocale = dateFormatter.locale // save locale temporarily
                                    //                                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                    //                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                    //                                let date = dateFormatter.date(from: myDate)!
                                    //                                dateFormatter.dateFormat = "dd MMM yyyy" ; //"dd-MM-yyyy HH:mm:ss"
                                    //                                dateFormatter.locale = tempLocale // reset the locale --> but no need here
                                    //                                let dateString = dateFormatter.string(from: date)
                                    //                                print("EXACT_DATE : \(dateString)")
                                    //                                UserDefaults.standard.set(dateString, forKey: "date")
                                    
                                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: contentArr), forKey: "userDetails")
                                    UserDefaults.standard.setValue(dict["firstname"] as Any, forKey: "userName")
                                    UserDefaults.standard.synchronize()
                                    
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = storyboard.instantiateViewController(withIdentifier: "CarDetailsVC") as! CarDetailsVC
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
      }
    }
    
   
    
    @IBAction func setDOB(_ sender: Any)
    {
        
    self.mDateView.frame = self.view.frame
        self.view.addSubview(self.mDateView)
        showDatePicker()
    }

func showDatePicker()
{
        mDatePicker.datePickerMode = .date
       //sender.inputView = mDatePicker
        mDatePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }

    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateOfBirthTF.text = dateFormatter.string(from: sender.date)
//        var DatePickerView  : UIDatePicker = UIDatePicker()
//        var dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd MMM yyyy"
//        dateOfBirthTF.text = dateFormatter.string(from: DatePickerView.date)
    }
    
 
    
//ExitView
    
    @IBAction func cancel(_ sender: Any) {
         self.mDateView.removeFromSuperview()
    }
    
    @IBAction func done(_ sender: Any) {
        self.mDateView.removeFromSuperview()
    }
    
    @IBAction func changeImage(_ sender: Any) {

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
        
        //        self.imageViewPicker.frame = self.view.frame
        //        self.view.addSubview(self.imageViewPicker)
    }
    //MARK: - UIImagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /*
         Get the image from the info dictionary.
         If no need to edit the photo, use `UIImagePickerControllerOriginalImage`
         instead of `UIImagePickerControllerEditedImage`
         */
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.mImageView.image = editedImage
            
            mImageView.layer.cornerRadius = mImageView.frame.size.height/2
            mImageView.layer.masksToBounds = true
            picker.dismiss(animated: true, completion: nil)
            uploadImage()
            
          //strBase64 = convertImageTobase64(format: ImageFormat.jpeg(0.6), image: editedImage)!
            //print(strBase64)
            
//            self.mImageView.frame = self.view.frame
//            self.view.addSubview(self.mImageView)
            
            
        }
        
        //Dismiss the UIImagePicker after selection
        
    }
    public enum ImageFormat {
        case png
        case jpeg(CGFloat)
    }
    
//    func convertImageTobase64(format: ImageFormat, image:UIImage) -> String? {
//        var imageData: Data?
//        switch format {
//        case .png: imageData = UIImagePNGRepresentation(image)
//        case .jpeg(let compression): imageData = UIImageJPEGRepresentation(image, compression)
//        }
//        return imageData?.base64EncodedString()
//    }
    
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
    
        
   func uploadImage()
   {

    
    let imgData = mImageView.image!.jpegData(compressionQuality: 0.2)!
    
    //let parameters = ["name": rname] //Optional for extra parameter
    
    Alamofire.upload(multipartFormData: { multipartFormData in
        multipartFormData.append(imgData, withName: "myImage",fileName: "file.jpg", mimeType: "image/jpg")
//        for (key, value) in parameters {
//            multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
//        } //Optional for extra parameters
       // "http://54.206.24.194:3000/uploads/upload_single"
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
                    self.fileStr = String(format : "%@",JSON["file"] as!  String)
                    self.view.makeToast("Image uploaded successfully")
                }
            }
            
        case .failure(let encodingError):
            print(encodingError)
        }
    }

    }
    
    
    
    
}
