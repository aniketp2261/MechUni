//
//  AddVehicleVC.swift
//  ValetParking
//
//  Created by Apple on 08/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
// dot.circle

@available(iOS 13.0, *)
class AddVehicleVC: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var vehicleImg:UIImageView!
    @IBOutlet weak var uploadImageBtn:UIButton!
    @IBOutlet weak var twoWheelerBtn:UIButton!
    @IBOutlet weak var fourWheelerBtn:UIButton!
    @IBOutlet weak var twoWheelerImg: UIImageView!
    @IBOutlet weak var fourWheelerImg: UIImageView!
    @IBOutlet weak var tfPlateNo:UITextField!
    @IBOutlet weak var tf2ndNo: UITextField!
    @IBOutlet weak var tf3Rd: UITextField!
    @IBOutlet weak var tf4Th: UITextField!
    @IBOutlet weak var saveBtn:UIButton!
    @IBOutlet weak var backBtnImg:UIImageView!
    @IBOutlet weak var navTitleLbl : UILabel!
    
    let radioButtonInactiveImg : UIImage = #imageLiteral(resourceName: "ic_red_radio_circle")
    let radioButtonActiveImg : UIImage = #imageLiteral(resourceName: "ic_red_radio_circleFill")
    var fileStr : String?
    var selectedVehicleType = -1
    var vehiclePlateNo = ""
    var shouldEditVehicle = false
    var selectedCarId:String = ""
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        if shouldEditVehicle {
            navTitleLbl.text = "Edit Vehicle"
            let PlateNo = vehiclePlateNo
            let words = PlateNo.components(separatedBy: [" "])
            if words.count > 1 && words.count == 4{
                tfPlateNo.text = words[0]
                tf2ndNo.text = words[1]
                tf3Rd.text = words[2]
                tf4Th.text = words[3]
            } else{
                tfPlateNo.text = words.first
            }
            print("selectedVehicleType0000------ \(selectedVehicleType)")
            if selectedVehicleType != -1 {
                let imgUrl = "\(APIEndPoints.BASE_IMAGE_URL)\(fileStr!)"
                vehicleImg.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "car"), options: [], context: nil)
                if selectedVehicleType == 1 {
                    fourWheelerImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
                    twoWheelerImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
                }
                else {
                    twoWheelerImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
                    fourWheelerImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
                }
            }
        } else {
            navTitleLbl.text = "Add Vehicle"
        }
        vehicleImg.layer.cornerRadius = vehicleImg.bounds.height/2
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backAction))
        backBtnImg.addGestureRecognizer(backTap)
        tfPlateNo.delegate = self
        tf2ndNo.delegate = self
        tf3Rd.delegate = self
        tf4Th.delegate = self
        tf2ndNo.keyboardType = .numberPad
        tf4Th.keyboardType = .numberPad
        initViews()
    }
    func initViews(){
        uploadImageBtn.addBorder(color: .red)
        saveBtn.addBorder(color: .red)
        tfPlateNo.addBorder(color: .darkGray)
        tfPlateNo.layer.cornerRadius = 16
        tf2ndNo.addBorder(color: .darkGray)
        tf2ndNo.layer.cornerRadius = 16
        tf3Rd.addBorder(color: .darkGray)
        tf3Rd.layer.cornerRadius = 16
        tf4Th.addBorder(color: .darkGray)
        tf4Th.layer.cornerRadius = 16
        uploadImageBtn.layer.cornerRadius = uploadImageBtn.bounds.height/2
        saveBtn.layer.cornerRadius = saveBtn.bounds.height/2
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backAction))
        backBtnImg.addGestureRecognizer(backTap)
    }
    func openImagePicker() {
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
        self.present(alert, animated: true, completion: nil)
    }
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
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
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    @objc func backAction(){
        navigationController?.popViewController(animated: true)
    }
    @IBAction func uploadImageAction(){
        openImagePicker()
    }
    @IBAction func twoWheelerAction(){
        selectedVehicleType = 1
        fourWheelerImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
        twoWheelerImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
    }
    @IBAction func fourWheelerAction(){
        selectedVehicleType = 2
        twoWheelerImg.image = #imageLiteral(resourceName: "ic_red_radio_circle")
        fourWheelerImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill")
    }
    @IBAction func saveVehicleAction(){
            if tf4Th.text == nil || tf4Th.text == ""{
                AlertFunctions.showAlert(message: "",title: "Please Enter Plate Number")
            }
            else{
                if selectedVehicleType == -1{
                    AlertFunctions.showAlert(message: "",title: "Please Select Vehicle Type")
                }
                else{
                    if shouldEditVehicle{
                        editApi()
                    } else{
                        if fileStr != nil{
                            saveApi()
                        }
                        else{
                            AlertFunctions.showAlert(message: "",title: "Please Select Vehicle Image")
                        }
                    }
                }
            }
        }
        func editApi(){
            let idValue =  UserDefaults.standard.string(forKey: "userID") ?? ""
            let CarNumber = "\(tfPlateNo.text!) \(tf2ndNo.text!) \(tf3Rd.text!) \(tf4Th.text!)"
            let parameters: Parameters =
            [
                "_id_customer_table":idValue,
                "car_make":"nil",
                "car_model":"nil",
                "car_color":"nil",
                "plate_no":CarNumber,
                "car_image":fileStr!,
                "vehicle_type":String(selectedVehicleType),
                "_id_car_details":"nil",
                "_id":selectedCarId
            ]
            print("params000000------- \(parameters)")
            if Connectivity.isConnectedToInternet
            {
                print("Yes! internet is available.")
                SKActivityIndicator.show("Loading...")
                let removeCharacters: Set<Character> = ["/"]
                fileStr!.removeAll(where: { removeCharacters.contains($0) })
                print("fileStr0000 ---- \(fileStr!)")
                Alamofire.request("\(APIEndPoints.BaseURL)car_details/edit_car_details", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .responseJSON { response in
                        switch response.result {
                        case .success:
                            SKActivityIndicator.dismiss()
                            print("Response: \(response)")
                            if let json = response.result.value {
                                if let JSON = json as? NSDictionary {
                                    print(JSON["status"] as? String ?? "")
                                    let status = JSON["status"] as? String
                                    print("ediStatus0000---- \(status!)")
                                    let message = JSON["message"] as? String
                                    if status == "failed" {
                                        self.view.makeToast(message)
                                    }else{
                                        self.view.makeToast(message)
                                        DispatchQueue.main.async {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                        SKActivityIndicator.dismiss()
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
    func saveApi()
    {
        let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
        let CarNumber = "\(tfPlateNo.text!) \(tf2ndNo.text!) \(tf3Rd.text!) \(tf4Th.text!)"
        let parameters: Parameters =
        [
            "_id_customer_table":idValue,
            "plate_no":CarNumber,
            "car_image":fileStr! as Any,
            "vehicle_type":selectedVehicleType
        ]
        print("params000000------- \(parameters)")
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)car_details/add_car_details", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("Response: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String ?? ""
                                let message = JSON["message"] as? String ?? ""
                                let result = JSON["result"] as? [[String: Any]]
                                print("AddVehicleResult---\(result)")
                                if status == "failed" {
                                    self.view.makeToast(message)
                                } else{
                                    SKActivityIndicator.dismiss()
                                    if result != nil{
                                        self.view.makeToast(message)
                                        DispatchQueue.main.async {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    } else{
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
            let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NetworkPopUpVC") as! NetworkPopUpVC
            self.addChild(popvc)
            popvc.view.frame = self.view.frame
            self.view.addSubview(popvc.view)
            popvc.didMove(toParent: self)
        }
    }
    func uploadCarImage()
    {
      
        let imgData = vehicleImg.image!.jpegData(compressionQuality: 0.2)!
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "myImage",fileName: "file.jpg", mimeType: "image/jpg")
            //        for (key, value) in parameters {
            //            multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            //        } //Optional for extra parameters
         //   "http://54.206.24.194:3000/uploads/upload_single"
        },
        to:APIEndPoints.BaseURL+"uploads/upload_single")
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == tfPlateNo || textField == tf3Rd {
            print("SSS--\(textField.text!.count)")
            if textField.text!.count < 2 {
                    let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
                    let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
                    let typedCharacterSet = CharacterSet(charactersIn: string)
                    let alphabet = allowedCharacterSet.isSuperset(of: typedCharacterSet)
                    return alphabet
                 } else if textField.text!.count == 2 {
                     textField.text = ""
                     return true
                  }
            return false
        } else if textField == tf2ndNo {
            let maxLength = 2
                let currentString: NSString = tf2ndNo.text! as NSString
                let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
        } else if textField == tf4Th{
            let maxLength = 4
                let currentString: NSString = tf4Th.text! as NSString
                let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
        } else {
            return false
        }
    }
}
extension UIView{
    func addBorder(color:UIColor){
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1.0
    }
}

@available(iOS 13.0, *)
extension AddVehicleVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /*
         Get the image from the info dictionary.
         If no need to edit the photo, use `UIImagePickerControllerOriginalImage`
         instead of `UIImagePickerControllerEditedImage`
         */
        print("imagePickerController00000 ------")
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            print("imagePickerController00000 ------\(editedImage)")
            self.vehicleImg.image = editedImage
            vehicleImg.layer.cornerRadius = vehicleImg.frame.size.height/2
            vehicleImg.layer.masksToBounds = true
            picker.dismiss(animated: true, completion: nil)
            uploadCarImage()
            
        }
        //Dismiss the UIImagePicker after selection
        
    }
}
