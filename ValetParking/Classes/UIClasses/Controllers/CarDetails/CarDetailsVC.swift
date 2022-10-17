//
//  CarDetailsVC.swift
//  ValetParking
//
//  Created by Khushal on 17/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import SKActivityIndicatorView

class CarDetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{

    @IBOutlet weak var mCarMakeView: UIView!
    @IBOutlet weak var mCarModleView: UIView!
    @IBOutlet weak var mPlateNoView: UIView!
    @IBOutlet weak var mCarColorView: UIView!
    
    @IBOutlet weak var mImageView: UIImageView!
     let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var mCarMakeTF: CustomFontTextField!
    @IBOutlet weak var mCarModel: CustomFontTextField!
    @IBOutlet weak var mCarColorTF: CustomFontTextField!
    @IBOutlet weak var mPlateNoTF: UITextField!
  
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var mSkipBtn: UIButton!
    @IBOutlet weak var uploadImage: UIButton!
    //Exit View
     @IBOutlet weak var mExitView: UIView!
      @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mSearchTF: UITextField!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mNoDataFound: UILabel!
    @IBOutlet weak var lblTitle: UILabel!

    
    
    private var data: [String] = []
    var type : String?
    var mCarMakeArray : [NSDictionary] = []
    var mCarModleArray : [NSDictionary] = []
    var mCarColorArray : [NSDictionary] = []
    var filteredArray : [NSDictionary] = []
    let textCellIdentifier = "cell"
    var fileStr : String?
    var carID: Int = 0
     var editCarID: Int = 0
   var saveType : String?
    var listArray:NSArray = []
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self

        self.mCarMakeView.layer.cornerRadius = 20
        self.mCarMakeView.layer.borderWidth = 1
        self.mCarMakeView.layer.borderColor = UIColor.gray.cgColor
        self.mCarModleView.layer.cornerRadius = 20
        self.mCarModleView.layer.borderWidth = 1
        self.mCarModleView.layer.borderColor = UIColor.gray.cgColor
        self.mPlateNoView.layer.cornerRadius = 20
        self.mPlateNoView.layer.borderWidth = 1
        self.mPlateNoView.layer.borderColor = UIColor.gray.cgColor
        self.mCarColorView.layer.cornerRadius = 20
        self.mCarColorView.layer.borderWidth = 1
        self.mCarColorView.layer.borderColor = UIColor.gray.cgColor
        
        self.uploadImage.layer.borderWidth = 2
        self.uploadImage.layer.borderColor = UIColor.gray.cgColor
         self.saveBtn.layer.cornerRadius = 20
        
        if saveType == "addCar" || saveType == "editCar"
        {
            self.mSkipBtn.isHidden = true
        }
        else
        {
             self.mSkipBtn.isHidden = false
        }
        
        if saveType == "editCar"
        {
            getCarById()
        }
        lblTitle.text = saveType == "editCar" ? "Edit Car" : "Add Car"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Button Actions
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func saveActn(_ sender: Any) {
        
        if(mCarMakeTF.text == "")
        {
            self.view.makeToast("Please select the car make.");
            
            return
        }
        else if(mCarModel.text == "")
        {
            self.view.makeToast("Please select the car model.");
            
            return
        }
        else if(mPlateNoTF.text == "")
        {
            self.view.makeToast("Please enter plate number.");
            
            return
        }
        else if(mCarColorTF.text == "")
        {
            self.view.makeToast("Please select car color.");
            
            return
        }
        
    if saveType == "editCar"
    {
        editSaveApi()
        }
        else
    {
        saveApi()
        }
        
    }
    
    @IBAction func skipActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func carMakeActn(_ sender: Any) {
        
        self.mExitView.frame = self.view.frame
        self.view.addSubview(self.mExitView)
        self.mTitleLabel.text = "Select Car Make"
        self.mTableView.isHidden = false
        self.mSearchTF.text = ""
        self.type = "carMake"
        ///self.mTableView.reloadData()
        
        
        // self.exitTV.isHidden = true
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            getCarMake()
        }
        else{
            self.view.makeToast(Constants.OFFLINE_MESSAGE)
        }

    }
    
    @IBAction func carModleActn(_ sender: Any) {
        if type == "editCar"
        {
            self.mExitView.frame = self.view.frame
            self.view.addSubview(self.mExitView)
            self.mTableView.isHidden = true
            self.mNoDataFound.isHidden = true
            self.mTitleLabel.text = "Select Car Model"
            self.mSearchTF.text = ""
            self.type = "carModle"
            if Connectivity.isConnectedToInternet {
                
                
                print("Yes! internet is available.")
                getCarModel()
            }
            else{
                self.view.makeToast(Constants.OFFLINE_MESSAGE)
            }
            
        }
        
        else{
        if(mCarMakeTF.text == "")
        {
            self.view.makeToast("Please select Car Make")
            return
        }
        self.mExitView.frame = self.view.frame
        self.view.addSubview(self.mExitView)
        self.mTableView.isHidden = true
        self.mNoDataFound.isHidden = true
        self.mTitleLabel.text = "Select Car Model"
        self.mSearchTF.text = ""
        self.type = "carModle"
        if Connectivity.isConnectedToInternet {
            
            
            print("Yes! internet is available.")
            getCarModel()
        }
        else{
            self.view.makeToast(Constants.OFFLINE_MESSAGE)
        }
            
        }

    }
@IBAction func mCarColorActn(_ sender: Any) {
    if type == "editCar"
    {
        self.mExitView.frame = self.view.frame
        self.view.addSubview(self.mExitView)
        self.mNoDataFound.isHidden = true
        self.mSearchTF.text = ""
        self.mTitleLabel.text = "Select Car Color"
        self.type = "carColor"
        self.mTableView.isHidden = true
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            getCarColor()
        }
        else{
            self.view.makeToast(Constants.OFFLINE_MESSAGE)
        }

    }
    else{
    if(mCarModel.text == "")
    {
        self.view.makeToast("Please select Car Model")
        return
    }
    self.mExitView.frame = self.view.frame
    self.view.addSubview(self.mExitView)
    self.mNoDataFound.isHidden = true
    self.mSearchTF.text = ""
    self.mTitleLabel.text = "Select Car Color"
    self.type = "carColor"
    self.mTableView.isHidden = true
    if Connectivity.isConnectedToInternet {
        print("Yes! internet is available.")
       getCarColor()
    }
    else{
        self.view.makeToast(Constants.OFFLINE_MESSAGE)
    }

    }
    }
    
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
            uploadCarImage()
            
            //strBase64 = convertImageTobase64(format: ImageFormat.jpeg(0.6), image: editedImage)!
            //print(strBase64)
            
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
    
    
    func uploadCarImage()
    {
      
        let imgData = mImageView.image!.jpegData(compressionQuality: 0.2)!
        
        //let parameters = ["name": rname] //Optional for extra parameter
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "myImage",fileName: "file.jpg", mimeType: "image/jpg")
            //        for (key, value) in parameters {
            //            multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            //        } //Optional for extra parameters
         //   "http://54.206.24.194:3000/uploads/upload_single"
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
                       // self.view.makeToast("Image uploaded successfully")
                    }
                    
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
        
    }
    
    @IBAction func mExitBack(_ sender: Any) {
        self.mExitView.removeFromSuperview()
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        var array: [NSDictionary] = []
        
        if(self.type == "carMake") {
            array = self.mCarMakeArray
            array.sort{
              ($0["car_make"] as! String) < ($1["car_make"] as! String)
            }
        } else if(self.type == "carModle") {
            array = self.mCarModleArray
            array.sort{
              ($0["car_model"] as! String) < ($1["car_model"] as! String)
            }
        } else if(self.type == "carColor") {
            array = self.mCarColorArray
            array.sort{
              ($0["car_color"] as! String) < ($1["car_color"] as! String)
            }
        }
        if (mSearchTF.text?.isEmpty)! {
            filteredArray = []
            filteredArray = array
            mTableView.reloadData()
            self.mNoDataFound.isHidden = true
        }
        else
        {
            var predicate : NSPredicate?
            
            if(self.type == "carMake")
            {
                predicate  = NSPredicate(format: "car_make contains[cd] %@", mSearchTF.text!)
            }
            else if(self.type == "carModle")
            {
                predicate  = NSPredicate(format: "car_model contains[cd] %@", mSearchTF.text!)
            }
            else if(self.type == "carColor")
            {
                predicate  = NSPredicate(format: "car_color contains[cd] %@", mSearchTF.text!)
            }
        
            let array = (filteredArray as NSArray).filtered(using: predicate!)
            filteredArray = []
            filteredArray = (array as NSArray) as! [NSDictionary]
            if(filteredArray.count == 0)
            {
                self.mNoDataFound.isHidden = false
                self.mSearchTF.resignFirstResponder()
            }
            else{
                self.mNoDataFound.isHidden = true
                
            }
            mTableView.reloadData()
        }
    }
    
    //API
    func saveApi()
    {
        let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
        let parameters: Parameters =
            [
                "_id_customer_table": idValue as Any,
                "car_make": String(format: "%@", self.mCarMakeTF.text!),
                "car_model": String(format: "%@", self.mCarModel.text!),
                "plate_no": String(format: "%@", self.mPlateNoTF.text!),
                "car_color": String(format: "%@", self.mCarColorTF.text!),
                "car_image": fileStr as Any
        ]
        print(parameters)
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(Constants.BASEURL)car_details/add_car_details", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("Response: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String
                                
                                if status == "failed" {
                                    //ANLoader.hide()
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                }else{
                                    SKActivityIndicator.dismiss()
//                                    let message = JSON["message"] as? String
//                                    self.view.makeToast(message);
                                    //                                UserDefaults.standard.set("1", forKey: "isLoggedin")
                                    //                                let contentArr = JSON["result"] as? NSArray
                                    //
                                    //                                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: contentArr), forKey: "carDetails")
                                    //                                UserDefaults.standard.synchronize()
                                    if self.saveType == "addCar"
                                    {
                                        self.view.makeToast("Car added successfully");
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        self.navigationController?.popViewController(animated: false)
                                        }
                                    }
                                    else{
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                                        self.navigationController?.pushViewController(vc, animated: true)
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
    
    func editSaveApi()
    {
        
   // let idValue =  UserDefaults.standard.string(forKey: "userID")
        let parameters: Parameters =
            [
                "_id": editCarID,
                "car_make": String(format: "%@", self.mCarMakeTF.text!),
                "car_model": String(format: "%@", self.mCarModel.text!),
                "plate_no": String(format: "%@", self.mPlateNoTF.text!),
                "car_color": String(format: "%@", self.mCarColorTF.text!),
                "car_image": fileStr as Any
                
        ]
        print(parameters)
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            //ANLoader.showLoading()
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(Constants.BASEURL)car_details/edit_car_details", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
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
                                    let cmessage = JSON["message"] as? String
                                    self.view.makeToast(cmessage);
                                }else{
                                    SKActivityIndicator.dismiss()
                                    self.view.makeToast("Car detail updated successfully");
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        self.navigationController?.popViewController(animated: false)
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
    func getCarMake()
    {
        //print("Yes! internet is available.")
        SKActivityIndicator.show("Loading...")
        Alamofire.request("\(Constants.BASEURL)car_details/get_all_car_make", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                switch response.result {
                case .success:
                    SKActivityIndicator.dismiss()
                    print("Response: \(response)")
                    if let json = response.result.value {
                        if let JSON = json as? NSDictionary {
                            print(JSON["status"] as? String ?? "")
                            let status = JSON["status"] as? String
                            if status == "success" {
                                self.mCarMakeArray = (JSON["result"] as? [NSDictionary])!
                                print(self.mCarMakeArray)
                                self.filteredArray = (JSON["result"] as? [NSDictionary])!
                                if self.filteredArray.count > 0 {
                                    self.filteredArray.sort{
                                      ($0["car_make"] as! String) < ($1["car_make"] as! String)
                                    }
                                    self.mTableView.isHidden = false
                                    self.mNoDataFound.isHidden = true
                                    self.mTableView.reloadData()
                                }else{
                                    self.mTableView.isHidden = true
                                    self.mNoDataFound.isHidden = false
                                    self.mTableView.reloadData()
                                }
                            } else{
                                let message = JSON["message"] as? String
                                self.view.makeToast(message);
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
    
    func getCarModel()
    {
       
        let parameters: Parameters =
            [
                "_id": carID
            ]
        SKActivityIndicator.show("Loading...")
       Alamofire.request("\(Constants.BASEURL)car_details/get_all_car_model", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
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
                            if status == "success"{
                                self.mCarModleArray = (JSON["result"] as? [NSDictionary])!
                                self.filteredArray = (JSON["result"] as? [NSDictionary])!
                                if self.filteredArray.count > 0 {
                                    self.filteredArray.sort{
                                      ($0["car_model"] as! String) < ($1["car_model"] as! String)
                                    }
                                    self.mTableView.isHidden = false
                                    self.mNoDataFound.isHidden = true
                                    self.mTableView.reloadData()
                                    
                                } else {
                                    self.mTableView.isHidden = true
                                    self.mNoDataFound.isHidden = false
                                    self.mTableView.reloadData()
                                }
                            }
                            else{
                                let message = JSON["message"] as? String
                                self.view.makeToast(message);
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
    
    func getCarColor()
    {
        SKActivityIndicator.show("Loading...")
        Alamofire.request("\(Constants.BASEURL)car_details/get_all_car_color", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
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
                            if status == "success"{
                                self.mCarColorArray = (JSON["result"] as? [NSDictionary])!
                                self.filteredArray = (JSON["result"] as? [NSDictionary])!
                                if self.filteredArray.count > 0 {
                                    self.filteredArray.sort{
                                      ($0["car_color"] as! String) < ($1["car_color"] as! String)
                                    }
                                    self.mTableView.isHidden = false
                                    self.mNoDataFound.isHidden = true
                                    self.mTableView.reloadData()
                                }else{
                                    self.mTableView.isHidden = true
                                    self.mNoDataFound.isHidden = false
                                    self.mTableView.reloadData()
                                }
                            }
                            else{
                                let message = JSON["message"] as? String
                                self.view.makeToast(message);
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
    
   func getCarById()
   {
    
    let parameters: Parameters =
        [
            "_id": editCarID
            
    ]
    print(parameters)
    if Connectivity.isConnectedToInternet
    {
        print("Yes! internet is available.")
        //ANLoader.showLoading()
        SKActivityIndicator.show("Loading...")
        Alamofire.request("\(Constants.BASEURL)car_details/get_car_details_by_id", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                switch response.result {
                case .success:
                    SKActivityIndicator.dismiss()
                    print("Response: \(response)")
                    if let json = response.result.value {
                        if let JSON = json as? NSDictionary {
                            print(JSON["status"] as? String ?? "")
                            let status = JSON["status"] as? String
                            
                            if status == "failed" {
                                //ANLoader.hide()
                                let message = JSON["message"] as? String
                                self.view.makeToast(message);
                            }else{
                                SKActivityIndicator.dismiss()
                                self.listArray = JSON["result"] as! NSArray
                                let dict = self.listArray.firstObject as! NSDictionary
                                self.mCarMakeTF.text = (dict["car_make"] as! String)
                                self.mCarModel.text = (dict["car_model"] as! String)
                                self.mCarColorTF.text = (dict["car_color"] as! String)
                                self.mPlateNoTF.text = (dict["plate_no"] as! String)
                                if let actionString = dict["car_image"] as? NSString {
                                    // action is not nil, is a String type, and is now stored in actionString
                                    let url = String(format: "%@%@",APIEndPoints.BASE_IMAGE_URL ,actionString)
                                    
                                    let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                                    
                                    self.mImageView.sd_setImage(with: URL(string: urlString!), placeholderImage: UIImage(named: "car"))
                                    self.fileStr = actionString as String
                                    print(self.fileStr as Any)
                                } else {
                                    // self.mImageView.image = UIImage(named: "mycars-1")
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
    
   //Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
      
            let dict = self.filteredArray[indexPath.row]
            if(self.type == "carMake")
            {
                
                cell.textLabel?.text = dict["car_make"] as? String
            }
            else if(self.type == "carModle")
            {
                
                cell.textLabel?.text = dict["car_model"] as? String
            }
            else if(self.type == "carColor")
            {
                
                cell.textLabel?.text = dict["car_color"] as? String
            }
        cell.textLabel?.font = UIFont(name: Constants.FONTNAME as String, size: 17)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        //  let dict = self.filteredArray[indexPath.row] as? NSDictionary
        if(self.type == "carMake")
        {
            let dict = self.filteredArray[indexPath.row]

            carID = dict["_id"] as! Int
            self.mCarMakeTF.text = dict["car_make"] as? String
            self.mExitView.removeFromSuperview()
        }
        else if(self.type == "carModle")
        {
            let dict = self.filteredArray[indexPath.row]

            self.mCarModel.text =  dict["car_model"] as? String
            self.mExitView.removeFromSuperview()
        } else if(self.type == "carColor")
        {
            let dict = self.filteredArray[indexPath.row]

            self.mCarColorTF.text = dict["car_color"] as? String
            self.mExitView.removeFromSuperview()
        }
    }
}
