
 //
//  TicketsVC.swift
//  ValetParking
//
//  Created by Khushal on 19/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import GoogleMobileAds


class TicketsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIAlertViewDelegate  {
    

    var interstitial: GADInterstitial!

    
    @IBOutlet weak var mTicketsView: UIView!
    @IBOutlet weak var mTicketsTV: UITableView!
    
    @IBOutlet weak var mLineLabel1: UILabel!
    @IBOutlet weak var mProgressButton: UIButton!
    
    @IBOutlet weak var mCompletedButton: UIButton!
    @IBOutlet weak var mLineLabel2: UILabel!
    // Exit View 1
    @IBOutlet var mComplaintView: UIView!
    
    @IBOutlet weak var mTypeYourTextView: UIView!
    
    @IBOutlet weak var mTextView: UITextView!
    @IBOutlet weak var mUploadImageBtn: UIButton!
    
    @IBOutlet weak var mSubmitBtn: UIButton!
     
    @IBOutlet weak var vwSuccess: UIView!

    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblTrans: UILabel!
   
    let imagePicker = UIImagePickerController()
    var imageFile: String?
    var selectedImage : UIImage?
    var mTicketsArray : NSMutableArray = []
    var completedTicketsArr : NSMutableArray = []
    var mSelectedType:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let nc = NotificationCenter.default
//        nc.post(name: Notification.Name("load"), object: nil)
//        sideMenuController?.isLeftViewSwipeGestureEnabled = true
         imagePicker.delegate = self
        //Exit View
        self.mTypeYourTextView.layer.cornerRadius = 35
            self.mTypeYourTextView.layer.borderWidth = 1
        self.mTypeYourTextView.layer.borderColor = UIColor.gray.cgColor
        self.mUploadImageBtn.layer.cornerRadius = 20
        self.mUploadImageBtn.layer.borderWidth = 1
        self.mUploadImageBtn.layer.borderColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0).cgColor
        self.mSubmitBtn.layer.cornerRadius = 20
        if mSelectedType == nil {
            mSelectedType = "progress"
        }
        
        self.mTicketsTV.register(UINib(nibName: "TicketTVCell", bundle: nil), forCellReuseIdentifier: "TicketTVCell")
        self.mTicketsTV.register(UINib(nibName: "CompleteTicketCell", bundle: nil), forCellReuseIdentifier: "CompleteTicketCell")
//        let isLoggedin =  UserDefaults.standard.string(forKey: "isLoggedin")
//        if(isLoggedin == "1")
//        {
//           displayTickets()
//        }
//        else
//        {
//            let alert = UIAlertView(title: "", message: "Login is required to access this feature", delegate: self, cancelButtonTitle: "GO TO LOGIN",  otherButtonTitles: "CANCEL")
//            alert.tag = 100
//            alert.show()
//        }
//
        self.vwSuccess.isHidden = true

        mTextView.text = "Type your text"
        mTextView.textColor = UIColor.lightGray
        mTextView.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getToken),
                                               name: Notification.Name("FCMToken"), object: nil)
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
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        mTextView.text = ""
        mTextView.textColor = UIColor.black
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if mTextView.text.count == 0 {
            mTextView.textColor = UIColor.lightGray
            mTextView.text = "Type your text"
            mTextView.resignFirstResponder()
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        if mTextView.text.count == 0 {
           mTextView.textColor = UIColor.lightGray
            mTextView.text = "Type your text"
            mTextView.resignFirstResponder()
        }
         return true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isLoggedin = UserDefaults.standard.string(forKey: "isLoggedin") ?? "0"
        if(isLoggedin == "1")
        {
            if mSelectedType == "progress" {
                self.mProgressActn(nil)
            } else {
                self.mCompletedActn(nil)
            }
            self.mTicketsTV.isHidden = false
            self.mTicketsView.isHidden = false
        }
        else{
            let alert = UIAlertView(title: "", message: "Login is required to access this feature", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
            alert.tag = 100
            alert.show()
            self.mTicketsTV.isHidden = true
            self.mTicketsView.isHidden = true
        }
    }

    //Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mSelectedType == "progress"
        {
            return mTicketsArray.count
        }
        else {
            return completedTicketsArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if mSelectedType == "progress"
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TicketTVCell", for: indexPath) as! TicketTVCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            let maindict = self.mTicketsArray[indexPath.row] as! NSDictionary
            if maindict.count > 0 {
                
            if let val = maindict["plate_no"]
            {
                cell.mCarNoLabel.text = (val as? String)!
            }
            if let val = maindict["ticket_id"]
            {
                cell.mTicketNo.text = (val as? String)!
            }
            if let val = (maindict["parking_name"] as? String)
            {
                cell.mallLabel.text = val
            }
            cell.mDateLabel.text = SingletonClass.sharedInstances.GetDateTime(mDate: (maindict["generated_on"] as? String)!, type: "date")
            cell.mTimeLabel.text = SingletonClass.sharedInstances.GetDateTime(mDate: (maindict["generated_on"] as? String)!, type: "time")
            if let val = maindict["status"]
            {
                cell.mRequestCarBtn.setTitle((val as! String), for: .normal)
                
            }
            cell.mRequestCarBtn.isEnabled = true

            if let amo = maindict["ticket_amount"] as? Int {
                cell.lblAmount.text = "\(amo) AED"
            }
            
            cell.mRequestCarBtn.tag = indexPath.row
            if let val = maindict["status"]
            {
                if ( val as! String) == "Request Car"
                {
                    // cell.mRequestCarBtn.removeTarget(nil, action: nil, for: .allEvents)
                    cell.mRequestCarBtn.addTarget(self, action:#selector(RequestCarActn(_:)
                                                    ), for: UIControl.Event.touchUpInside)
                }
                else if (val as! String) == "Car Requested"
                {
                    //cell.mRequestCarBtn.removeTarget(nil, action: nil, for: .allEvents)
                    cell.mRequestCarBtn.addTarget(self, action:#selector(RequestCarActn(_:)
                                                    ), for: UIControl.Event.touchUpInside)
                }
                else if (val as! String) == "Request Accepted"
                {
                    //cell.mRequestCarBtn.removeTarget(nil, action: nil, for: .allEvents)
                    cell.mRequestCarBtn.addTarget(self, action:#selector(RequestCarActn(_:)), for: UIControl.Event.touchUpInside)
                    cell.mRequestCarBtn.isHidden = false
                }
                else if (val as! String) == "Online Paid"
                {
                //    cell.mRequestCarBtn.isEnabled = false
                    cell.mRequestCarBtn.addTarget(self, action:#selector(RequestCarActn(_:)
                                                    ), for: UIControl.Event.touchUpInside)
                    cell.mRequestCarBtn.isHidden = false

                    
                }
                else if (val as! String) == "Car Parked" {
                    cell.mRequestCarBtn.addTarget(self, action:#selector(RequestCarActn(_:)
                                                    ), for: UIControl.Event.touchUpInside)
                }
            }
                cell.mTicketView.isHidden = false

            } else {
                cell.mTicketView.isHidden = true
            }
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompleteTicketCell", for: indexPath) as! CompleteTicketCell
            let maindict = self.completedTicketsArr[indexPath.row] as! NSDictionary
            if let val = maindict["plate_no"]
            {
            cell.mCarNo.text = (val as? String)!
            }
            if let val = maindict["ticket_id"]
            {
                cell.mTicketID.text = (val as? String)!
            }
            if let val = maindict["parking_name"]
            {
            cell.parkingName.text = (val as? String)!
            }
            cell.mDate.text = SingletonClass.sharedInstances.GetDateTime(mDate: (maindict["generated_on"] as? String)!, type: "date")
            cell.mTime.text = SingletonClass.sharedInstances.GetDateTime(mDate: (maindict["generated_on"] as? String)!, type: "time")
            if let value = (maindict["payment_type"])
            {
            cell.paymentMode.text = value as? String ?? ""
            }
            cell.parkingAmount.text = String(format: "%d  %@", (maindict["ticket_amount"] as! Int),(maindict["aed"] as? String)!)
            cell.RaiseComplaint.setTitle("    Raise a Complaint    ", for: .normal)
            cell.RaiseComplaint.tag = indexPath.row
            cell.RaiseComplaint.addTarget(self, action:#selector(RaiseAction(_:)
                                            ), for: UIControl.Event.touchUpInside)
             return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if mSelectedType == "progress"
        {
            let maindict = self.mTicketsArray[indexPath.row] as! NSDictionary
            if maindict.count > 0 {
            if (maindict["status"] as? String) == "Paid"
            {
                return 0
            }
            else
            {
            return 168
            }
            } else {
                return 0
            }
        }
        else
        {
            return 205
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       // let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let maindict = self.mTicketsArray[indexPath.row] as! NSDictionary
        let val = maindict["status"] as? String ?? ""
        if val == "Online Paid" {
            self.lblDesc.text = "Your payment \(maindict["ticket_amount"] as? Int ?? 0) AED has been processed successfully"
            self.lblTrans.text = maindict["tracking_id"] as? String ?? "0000"
            self.vwSuccess.isHidden = false
        }
        
    }
    
    
    @objc func RaiseAction (_ sender: UIButton){
        self.mComplaintView.frame = self.view.frame
        self.view.addSubview(self.mComplaintView)
    }
    
    @objc func RequestCarActn (_ sender: UIButton){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let maindict = self.mTicketsArray[sender.tag] as! NSDictionary
        let val = maindict["status"] as? String ?? ""
        if val == "Request Accepted" {
            let vc = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
            vc.ticketDetails = maindict
            self.navigationController?.pushViewController(vc, animated: true)
        } else if val == "Online Paid" {
            //
            self.lblDesc.text = "Your payment \(maindict["ticket_amount"] as? Int ?? 0) AED has been processed successfully"
            self.lblTrans.text = maindict["tracking_id"] as? String ?? "0000"
            self.vwSuccess.isHidden = false
        } else {
            let vc = storyboard.instantiateViewController(withIdentifier: "ParkedCarVC") as! ParkedCarVC
            vc.isBack = true
            let val = maindict["status"] as? String ?? ""
            if val == "Car Requested" {
                vc.mType = "carRequested"
            } else {
                vc.mType = "requestCar"
            }
            vc.carDetails = maindict
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func CarRequestedActn (_ sender: UIButton)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ParkedCarVC") as! ParkedCarVC
        vc.mType = "carRequested"
        vc.isBack = true
        let maindict = self.mTicketsArray[sender.tag] as! NSDictionary
        vc.carDetails = maindict
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func makePayment (_ sender: UIButton)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        let maindict = self.mTicketsArray[sender.tag] as! NSDictionary
        vc.ticketDetails = maindict
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   //Button Actions
    
    @IBAction func mNotification(_ sender: Any) {
        
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
//        //        let maindict = self.mTicketsArray[sender.tag] as! NSDictionary
//        //        vc.ticketDetails = maindict
//                self.navigationController?.pushViewController(vc, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //Exit View
    @IBAction func mExit(_ sender: Any) {
        self.mComplaintView.removeFromSuperview()
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
      
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
    //MARK: - UIImagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /*
         Get the image from the info dictionary.
         If no need to edit the photo, use `UIImagePickerControllerOriginalImage`
         instead of `UIImagePickerControllerEditedImage`
         */
        selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
           
            
            picker.dismiss(animated: true, completion: nil)
            uploadImage()
//        if let localUrl = (info[UIImagePickerControllerMediaURL] ?? info[UIImagePickerControllerReferenceURL]) as? NSURL {
//
//            print (localUrl)
//
//            self.imageFile = (localUrl.path)!
//            picker.dismiss(animated: true, completion: nil)
            
    
        
        //Dismiss the UIImagePicker after selection
        
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
        
        let imgData = selectedImage!.jpegData(compressionQuality: 0.2)!
        
        //let parameters = ["name": rname] //Optional for extra parameter
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "myImage",fileName: "file.jpg", mimeType: "image/jpg")
            //        for (key, value) in parameters {
            //            multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            //        } //Optional for extra parameters
            //"http://54.206.24.194:3000/uploads/upload_single"
        },
                         to: Constants.BASEURL+"uploads/upload_single" )
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
                        self.imageFile = String(format : "%@",JSON["file"] as!  String)
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
        
    }
    
    @IBAction func submit(_ sender: Any) {
        let textStr = mTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if textStr.count == 0 || (textStr.count > 0 && textStr == "Type your text") {
            self.view.makeToast("Please write your issue");
        } else {
            submitComplaint()
        }
    }
    
    @IBAction func okBtnClicked(_ sender: Any) {
        displayTickets()
        self.vwSuccess.isHidden = true
    }
    
    @IBAction func mProgressActn(_ sender: UIButton?) {
        mSelectedType = "progress"
        self.mProgressButton.setTitleColor(UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0), for: .normal)
        self.mLineLabel1.backgroundColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0)

        self.mCompletedButton.setTitleColor(UIColor(red:0.55, green:0.55, blue:0.55, alpha:1.0), for: .normal)
        self.mLineLabel2.backgroundColor = UIColor(red:0.55, green:0.55, blue:0.55, alpha:1.0)
        displayTickets()
    }
    
    @IBAction func mCompletedActn(_ sender: UIButton?) {
         mSelectedType = "completed"
        self.mCompletedButton.setTitleColor(UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0), for: .normal)
        self.mLineLabel2.backgroundColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0)
        
        self.mProgressButton.setTitleColor(UIColor(red:0.55, green:0.55, blue:0.55, alpha:1.0), for: .normal)
        self.mLineLabel1.backgroundColor = UIColor(red:0.55, green:0.55, blue:0.55, alpha:1.0)
        completedTickets()
        
    }
    
    @IBAction func goToLogin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- APICALL
    func displayTickets()
    {
        let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
        let parameters: Parameters =
            [
                 "_id_customer_table": idValue as Any

        ]
        print("Params: -- \(parameters)")
        if Connectivity.isConnectedToInternet
        {
            print("Url =-- \(Constants.BASEURL)ticket_management/ticket_details_by_id1")
            SKActivityIndicator.show("Loading...")
            self.mTicketsArray.removeAllObjects()
            Alamofire.request("\(Constants.BASEURL)ticket_management/ticket_details_by_id1", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("Response ticket : \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                let message = JSON["message"] as? String
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String
                                
                                if status == "success" {
                                    SKActivityIndicator.dismiss()
                                    self.mTicketsArray = ((JSON["result"] as! NSArray).mutableCopy()) as! NSMutableArray
                                }else
                                {
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                }
                            } else {
                                self.view.makeToast("Json Error...!!!")
                            }
                            self.mTicketsTV.reloadData()
                        }
                        break
                    case .failure(let error):
                        SKActivityIndicator.dismiss()
                        print(error)
                        self.mTicketsTV.reloadData()

                        break
                    }
            }
        }
    }
    
    func completedTickets()
    {
        let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
        let parameters: Parameters =
            [
                "_id_customer_table": idValue as Any
            ]
        print(parameters)
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            self.completedTicketsArr.removeAllObjects()
            Alamofire.request("\(Constants.BASEURL)ticket_management/getcomplete_tickets", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
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
                                
                                if status == "success" {
                                    SKActivityIndicator.dismiss()
                                    self.completedTicketsArr = ((JSON["result"] as! NSArray).mutableCopy()) as! NSMutableArray
                                    
                                }else
                                {
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                }
                            } else {
                                self.view.makeToast("Json Error...!!!")
                            }
                            self.mTicketsTV.reloadData()
                        }
                        break
                    case .failure(let error):
                        SKActivityIndicator.dismiss()
                        print(error)
                        self.mTicketsTV.reloadData()
                        break
                    }
            }
        }
    }
    
    func submitComplaint()
    {
            
        let dict = self.completedTicketsArr.firstObject as! NSDictionary
        let ticketID = (dict["ticket_id"] as! String)
        
        var email = ""
        var name = ""

        let currentDefaults = UserDefaults.standard
            let savedArray = currentDefaults.object(forKey: "userDetails") as? Data
        if savedArray != nil {
            var oldArray: [Any]? = nil
            if let anArray = savedArray {
                oldArray = NSKeyedUnarchiver.unarchiveObject(with: anArray) as? [Any]
                if let dict = oldArray?.first as? NSDictionary {
                    email = dict["email"] as? String ?? ""
                    name = (dict["firstname"] as? String ?? "") + " " + (dict["lastname"] as? String ?? "")
                }
            }
        }
        
        let parameters: Parameters =
            [
                "ticket_id": ticketID as Any,
                "image": imageFile != nil ? imageFile! as Any : "",
                "compliant_description": self.mTextView.text!,
                "firstname": name,
                "email" : email
        ]
        print(parameters)
        
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            print("Param: --- \(parameters)")
            let headers = [
                "cache-control": "no-cache",
                "Postman-Token": "06d85934-5ea1-40b1-aa47-8b2e5ca4c8e0"
            ]
            // let postData = NSData(data: "\(param)".data(using: String.Encoding.utf8)!)
            let postData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            
            let request = NSMutableURLRequest(url: NSURL(string: "\(Constants.BASEURL)transaction/customer_raise_complaints")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            let session = URLSession.shared
                        
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    SKActivityIndicator.dismiss()
                    AlertFunctions.showAlert(message: (error?.localizedDescription)!)
                } else {
                    SKActivityIndicator.dismiss()
                    guard let dataResponse = data, error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return }
                    if let stringData = String(data: dataResponse, encoding: String.Encoding.utf8) {
                        print("Response -- \(stringData)")
                        let data = stringData.data(using: .utf8)!
                        if let JSON = try? JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any] {
                            print(JSON["status"] as? String ?? "")
                            let status = JSON["status"] as? String
                            
                            if status == "success" {
                                SKActivityIndicator.dismiss()
                                self.view.makeToast("Your complaint has been sent successfully.")
                                self.mComplaintView.removeFromSuperview()
                                
                            }else
                            {
                                let message = JSON["message"] as? String
                                self.view.makeToast(message);
                            }
                        } else {
                            DispatchQueue.main.async {
                                AlertFunctions.showAlert(message: "Json Error !!!")
                            }
                        }
                    }
                }
            })
            dataTask.resume()
        } else {
            SKActivityIndicator.dismiss()
            AlertFunctions.showAlert(message: "No Internet Connection")
        }
        
        
        
        if Connectivity.isConnectedToInternet
        {
            //ANLoader.showLoading()
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(Constants.BASEURL)transaction/customer_raise_complaints", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        DispatchQueue.main.async {
                        SKActivityIndicator.dismiss()
                        }
                        print("Response: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String
                                
                                if status == "success" {
                                    DispatchQueue.main.async {
                                        SKActivityIndicator.dismiss()
                                        self.view.makeToast("Your complaint has been sent successfully.")
                                        self.mComplaintView.removeFromSuperview()
                                    }
                                }else
                                {
                                    let message = JSON["message"] as? String
                                    DispatchQueue.main.async {
                                        self.view.makeToast(message);
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.view.makeToast("Json Error...!!!")
                                }
                            }
                        }
                        break
                    case .failure(let error):
                        DispatchQueue.main.async {
                            SKActivityIndicator.dismiss()
                        }
                        print(error)
                        break
                    }
            }
        }
    }
    
    @objc func getToken()
    {
        let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
        let tokenID =  UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        let parameters: Parameters =
            [
                "_id": idValue as Any,
                "token_id": tokenID
        ]
        print("Noty token -- \(parameters)")
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            //ANLoader.showLoading()
            Alamofire.request("\(Constants.BASEURL)customer_table/customer_update_token", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
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
                                }
                            }
                        }
                        break
                    case .failure(let error):
                        print(error)
                        break
                    }
            }
        }
    }
}


