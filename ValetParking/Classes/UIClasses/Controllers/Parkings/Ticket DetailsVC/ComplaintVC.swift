//
//  ComplaintVC.swift
//  ValetParking
//
//  Created by Apple on 23/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import MultilineTextField
import Alamofire
import SKActivityIndicatorView

class ComplaintVC: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var ComplaintView: UIView!
    @IBOutlet weak var CloseImg: UIImageView!
    @IBOutlet weak var ComplaintBox: MultilineTextField!
    @IBOutlet weak var SubmitBtn: UIButton!
    let imagePicker = UIImagePickerController()
    var selectedImage: UIImage?
    var imagePath: String?
    var TicketID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ComplaintVC ----\(TicketID)")
        imagePicker.delegate = self
        ComplaintView.layer.cornerRadius = 16
        SubmitBtn.layer.cornerRadius = SubmitBtn.bounds.height/2
        SubmitBtn.layer.borderWidth = 1
        SubmitBtn.layer.borderColor = UIColor.red.cgColor
        ComplaintBox.isPlaceholderScrollEnabled = true
        ComplaintBox.layer.cornerRadius = 16
        ComplaintBox.layer.borderWidth = 1
        ComplaintBox.layer.borderColor = UIColor.gray.cgColor
        CloseImg.isUserInteractionEnabled = true
        CloseImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CrossBtnAction)))
    }
    @objc func CrossBtnAction(){
        self.dismiss(animated: true, completion: nil)
//       navigationController?.popViewController(animated: false)
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
       
    @IBAction func UploadImgAction(_ sender: UIButton) {
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
    
    @IBAction func SubmitBtnAction(_ sender: Any) {
        let parameters: Parameters =
            [
                "ticket_id": TicketID ?? "",
                "firstname": UserDefaults.standard.string(forKey: "firstname") as? String ?? "",
                "image": imagePath as? String ?? "",
                "email": UserDefaults.standard.string(forKey: "email") as? String ?? "",
                "compliant_description": String(format: "%@", self.ComplaintBox.text!)
        ]
        print("ComplaintParam --- \(parameters)")
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)transaction/customer_raise_complaints", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("ComplaintResponse: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                let message = JSON["message"] as? String
                                self.view.makeToast(message)
                                self.navigationController?.popViewController(animated: false)
                            } else {
                                self.view.makeToast("Json Error...!!!")
                            }
                        }
                        break
                    case .failure(let error):
                        SKActivityIndicator.dismiss()
                        self.view.makeToast("\(error)")
                        print(error)
                        
                        break
                }
            }
            
        } else{
            NetworkPopUpVC.sharedInstance.Popup(vc: self)
        }
    }
    func uploadImage()
    {
        SKActivityIndicator.show("Loading...")
        let imgData = selectedImage!.jpegData(compressionQuality: 0.2)!
        //let parameters = ["name": rname] //Optional for extra parameter
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "myImage",fileName: "file.jpg", mimeType: "image/jpg")
            //        for (key, value) in parameters {
            //            multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            //        } //Optional for extra parameters
        },
            to:APIEndPoints.BaseURL+"uploads/upload_single")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                upload.responseJSON { response in
                    SKActivityIndicator.dismiss()
                    print(response.result.value)
                    if let json = response.result.value {
                        let JSON = json as! NSDictionary
                        let msg = JSON["message"] as! String
                        self.view.makeToast(msg)
                        self.imagePath = String(format : "%@",JSON["file"] as! String)
//                        UserDefaults.standard.set(self.imagePath, forKey: "userImage")
                    }
                }
            case .failure(let encodingError):
                SKActivityIndicator.dismiss()
                self.view.makeToast("\(encodingError)")
                print(encodingError)
            }
        }
    }
}
extension ComplaintVC: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /*
         Get the image from the info dictionary.
         If no need to edit the photo, use `UIImagePickerControllerOriginalImage`
         instead of `UIImagePickerControllerEditedImage`
         */
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.selectedImage = editedImage
            picker.dismiss(animated: true, completion: nil)
            uploadImage()
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled")
        picker.dismiss(animated: true, completion: nil)
    }
}
