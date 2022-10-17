//
//  ValetProvider.swift
//  ValetParking
//
//  Created by Khushal on 16/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire
import SKActivityIndicatorView
import GoogleMaps
import GooglePlaces
import SKCountryPicker

class ValetProvider: UIViewController, UITextFieldDelegate, GMSAutocompleteViewControllerDelegate, GMSAutocompleteResultsViewControllerDelegate, UIAlertViewDelegate{
   
    @IBOutlet weak var mCompanyNameView: UIView!
    @IBOutlet weak var mOwnerNameView: UIView!
    @IBOutlet weak var mMobileNoView: UIView!
    @IBOutlet weak var mEmailIdView: UIView!
    @IBOutlet weak var mLocationView: UIView!
    @IBOutlet weak var mNoOfParkingsView: UIView!
    
    @IBOutlet weak var countryBtn: UIButton!
    @IBOutlet weak var imgFlag: UIImageView!
    
    @IBOutlet weak var mAnyCommentsView: UIView!
    
    @IBOutlet weak var mCompanyNameTF: UITextField!
    
    @IBOutlet weak var mOwnerNameTF: UITextField!
    
    @IBOutlet weak var mMobileNoTF: UITextField!
    
    @IBOutlet weak var mEmailIdTF: UITextField!
    
    @IBOutlet weak var mLocationTF: UITextField!
    
    @IBOutlet weak var mNoOfParkingsTF: CustomFontTextField!
  
    @IBOutlet weak var commentTF: UITextField!
    
    
    @IBOutlet weak var mSubmitBtn: UIButton!
    
    //Exit View
    
    @IBOutlet var mExitView: UIView!
    @IBOutlet weak var mTableView: UITableView!
    
    //
   // var filterArray : NSArray = ["1","2"]
    var userLat: Any?
    var userLong: Any?
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mCompanyNameView.layer.cornerRadius = 20
        self.mCompanyNameView.layer.borderWidth = 1
        self.mCompanyNameView.layer.borderColor = UIColor.gray.cgColor
        self.mOwnerNameView.layer.cornerRadius = 20
        self.mOwnerNameView.layer.borderWidth = 1
        self.mOwnerNameView.layer.borderColor = UIColor.gray.cgColor
        self.mMobileNoView.layer.cornerRadius = 20
        self.mMobileNoView.layer.borderWidth = 1
        self.mMobileNoView.layer.borderColor = UIColor.gray.cgColor
        self.mLocationView.layer.cornerRadius = 20
        self.mLocationView.layer.borderWidth = 1
        self.mLocationView.layer.borderColor = UIColor.gray.cgColor
        self.mEmailIdView.layer.cornerRadius = 20
        self.mEmailIdView.layer.borderWidth = 1
        self.mEmailIdView.layer.borderColor = UIColor.gray.cgColor
        self.mNoOfParkingsView.layer.cornerRadius = 20
        self.mNoOfParkingsView.layer.borderWidth = 1
        self.mNoOfParkingsView.layer.borderColor = UIColor.gray.cgColor
        self.mAnyCommentsView.layer.cornerRadius = 25
        self.mAnyCommentsView.layer.borderWidth = 1
        self.mAnyCommentsView.layer.borderColor = UIColor.gray.cgColor
        self.mSubmitBtn.layer.cornerRadius = 20

        //placeholder color
        mCompanyNameTF.attributedPlaceholder = NSAttributedString(string:"Company Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        mMobileNoTF.attributedPlaceholder = NSAttributedString(string:"Phone number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        mEmailIdTF.attributedPlaceholder = NSAttributedString(string:"Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        mLocationTF.attributedPlaceholder = NSAttributedString(string:"Company location", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        mOwnerNameTF.attributedPlaceholder = NSAttributedString(string:"Owner Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        mNoOfParkingsTF.attributedPlaceholder = NSAttributedString(string:"Number of parking", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        commentTF.attributedPlaceholder = NSAttributedString(string:"Any comments", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        
        let country = CountryManager.shared.currentCountry
        countryBtn.setTitle(country?.dialingCode, for: .normal)
        imgFlag.image = country?.flag
        
//        self.mSubmitBtn.alpha = 0.5
//        self.mSubmitBtn.isUserInteractionEnabled = false
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        
        return true
    }
    //Email Validate
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    // Button Actions
  
    @IBAction func mSubmitActn(_ sender: Any) {
        
//        Please enter your company name.
//        Please enter company owner name.
//        Please enter your phone number.
//        Please enter your email.
//        Please enter your company location.
//        Please enter number of parking.
//        Please enter your comment.
   //     In case if invalid email id, the message sghould be: "Please enter valid email id."
        if(mCompanyNameTF.text == "")
        {
            self.view.makeToast("Please enter your company name.");
            
            return
        }
        else if(mOwnerNameTF.text == "")
        {
            self.view.makeToast("Please enter company owner name.");
            
            return
        }else if(mMobileNoTF.text == "")
        {
            self.view.makeToast("Please enter your phone number.");
            
            return
        }
        if(mEmailIdTF.text == "")
        {
            self.view.makeToast("Please enter your email.");
            
            return
        }
        else
        {
            var bool = self.isValidEmail(testStr: mEmailIdTF.text!)
            if bool == false{
                self.view.makeToast("Please enter a valid email id.");
                return
            }
            print(bool)
        }
         if(mLocationTF.text == "")
        {
            self.view.makeToast("Please enter your company location.");
            
            return
        }
       
        else if(mNoOfParkingsTF.text == "")
        {
            self.view.makeToast("Please enter number of parking.");
            return
         }
         else if (commentTF.text == "")
         {
            
            self.view.makeToast("Please enter your comment.");
            return
        }
        
        let cc = self.countryBtn.currentTitle
        let strCC = cc?.dropFirst()
    
        let parameters: Parameters =
            [
                "company_name": String(format: "%@", self.mCompanyNameTF.text!),
                "owner_name": String(format: "%@", self.mOwnerNameTF.text!),
                "mobilenumber": "\(strCC!)\(self.mMobileNoTF.text!)",
                "email": String(format: "%@", self.mEmailIdTF.text!),
                "lat" : userLat! as Any,
                "long" : userLong! as Any,
                "no_of_parking": String(format: "%@", self.mNoOfParkingsTF.text!),
                "any_comment": String(format: "%@", self.commentTF.text!),
                "address" :  String(format: "%@", self.mLocationTF.text!)

                ]
        print(parameters)
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            //ANLoader.showLoading()
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(Constants.BASEURL)admin_valet_provider/be_a_valet_provider_create", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
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
                                    // self.view.makeToast("Successfully Become Valet Provider!!");
                                    let alert = UIAlertView(title: "", message: "Your business request has been submitted succesfully.", delegate: self, cancelButtonTitle: "OK")
                                    alert.tag = 100
                                    alert.show()
                                }else{
                                    //ANLoader.hide()
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
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == 100 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    

    @IBAction func countryBtnClicked(_ sender: Any) {
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { (country: Country) in
            self.imgFlag.image = country.flag
            self.countryBtn.setTitle(country.dialingCode, for: .normal)
        }
        countryController.detailColor = UIColor.black
    }

    
    @IBAction func setLocation(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress!)")
       // print("Place attributions: \(place.attributions!)")
        self.mLocationTF.text = place.name
       // let address = place.name
    
        let address = mLocationTF.text
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                coordinates.latitude
                coordinates.longitude
                print("lat", coordinates.latitude)
                print("long", coordinates.longitude)
                self.userLat = coordinates.latitude
                self.userLong = coordinates.longitude
                
            }
        })
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // Handle the user's selection.
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    
    
}
