//
//  ParkingPlaceVC.swift
//  ValetParking
//
//  Created by Khushal on 22/11/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import AARatingBar
import MTSlideToOpen
import CoreLocation
import SafariServices
import SDWebImage

/// Delegate to send events to the parent or the view controller that will be presenting this viewcontroller
protocol ParkingPlaceVCDelegate{
    /// function will be called when the user drags the parking slider to the end
    func sliderReachedToEnd(model:NearbyPlaceModel?)
}


/// this class is presented as a bottom sheet
class ParkingPlaceVC: UIViewController{
    @IBOutlet weak var twoWheelerAvailableSlotsLbl: UILabel!
    @IBOutlet weak var fourWheelerAvailableSlotsLbl: UILabel!
    @IBOutlet weak var TwoWorkingHoursLbl: UILabel!
    @IBOutlet weak var CarWorkingHoursLbl: UILabel!
    @IBOutlet weak var twoWheelerChargesLbl: UILabel!
    @IBOutlet weak var fourWheelerChargesLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var slideToParkView: MTSlideToOpenView!
    @IBOutlet weak var parkingPlaceAddressLbl: UILabel!
    @IBOutlet weak var ratingCollectionView: UICollectionView!
    @IBOutlet weak var ratingCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var parkingNameLbl: UILabel!
    @IBOutlet weak var parkingImage: UIImageView!
    @IBOutlet weak var DistanceLbl: UILabel!
    @IBOutlet weak var NavigationImg: UIImageView!
    
    var nearbyPlaceModel: NearbyPlaceModel? = nil
    
    var parkingPlaceDelegate: ParkingPlaceVCDelegate? = nil
    var parkingLat = String()
    var parkingLong = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        ratingCollectionView.register(UINib(nibName: "FeedbackCVC", bundle: nil), forCellWithReuseIdentifier: "FeedbackCVC")
        //        ratingCollectionView.delegate = self
        //        ratingCollectionView.dataSource = self
        ratingCollectionViewHeight.constant = 20
        slideToParkView.thumnailImageView.image = #imageLiteral(resourceName: "icSwipeThumb")
        slideToParkView.labelText = "Swipe To Park"
        slideToParkView.draggedView.backgroundColor = .white
        slideToParkView.layer.cornerRadius = slideToParkView.bounds.height/2
        slideToParkView.thumbnailColor = .red
        slideToParkView.textLabel.textAlignment = .right
        slideToParkView.thumbnailViewStartingDistance = 20
        slideToParkView.textLabel.font = UIFont(name: "Poppins-Bold", size: 16)
        slideToParkView.textLabel.textColor = .red
        slideToParkView.thumbnailViewTopDistance = 5
        slideToParkView.sliderHolderView.backgroundColor = .white
        slideToParkView.addBorder(color: .red)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        slideToParkView.resetStateWithAnimation(true)
        slideToParkView.delegate = self
        if let nearby = nearbyPlaceModel{
            parkingNameLbl.text = nearby.parkingName
            parkingPlaceAddressLbl.text = nearby.address
//            topRatingBar.isHidden = true
            print("Slots --- \(nearby.fourWheelerAvailableParking)\n\(nearby.twoWheelerAvailableParking)")
            if nearby.twoWheelerAvailableParking == ""{
                twoWheelerAvailableSlotsLbl.text = "--"
            }else{
                twoWheelerAvailableSlotsLbl.text = nearby.twoWheelerAvailableParking
            }
            if nearby.fourWheelerAvailableParking == ""{
                fourWheelerAvailableSlotsLbl.text = "--"
            }else{
                fourWheelerAvailableSlotsLbl.text = nearby.fourWheelerAvailableParking
            }
            DistanceLbl.text = nearby.distance
            TwoWorkingHoursLbl.text = nearby.startOpeningHours
            CarWorkingHoursLbl.text = nearby.endOpeningHours
            twoWheelerChargesLbl.text = nearby.twoWheelerCost
            fourWheelerChargesLbl.text = nearby.fourWheelerCost
            parkingImage.sd_setImage(with: URL(string: APIEndPoints.BASE_PARKING_URL + nearby.image), placeholderImage: #imageLiteral(resourceName: "parkingPlaceholderImg"), options: [], context: nil)
            print("ParkingPageURL --- \(APIEndPoints.BaseURL + nearby.image)")
            
            self.parkingLat = nearby.lat
            self.parkingLong = nearby.long
            NavigationImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(findParkingRoute)))
        }
        print("ParkingPlaceVC will Appear-------")
    }
    @objc func findParkingRoute(){
        print("Lat: \(parkingLat ?? "")\nLong: \(parkingLong ?? "")")
        let appleURL = "http://maps.apple.com/?daddr=\(parkingLat ?? ""),\(parkingLong ?? "")"
        let sfVc = SFSafariViewController(url: URL(string: appleURL)!)
        sfVc.delegate = self
        present(sfVc, animated: true, completion: nil)
    }
    @objc func CallAction(){
        self.dialNumber(number: self.nearbyPlaceModel?.mobileNumber ?? "")
    }
    func dialNumber(number : String) {
     if let url = URL(string: "tel://\(number)"),
       UIApplication.shared.canOpenURL(url) {
          if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler:nil)
           } else {
               UIApplication.shared.openURL(url)
           }
       } else {
        // add error message here
        print("Error open the Calling..")
       }
    }
}
extension ParkingPlaceVC: MTSlideToOpenDelegate{
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
        parkingPlaceDelegate?.sliderReachedToEnd(model: nearbyPlaceModel)
    }
}
extension ParkingPlaceVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedbackCVC", for: indexPath) as! FeedbackCVC
        let attr = NSMutableAttributedString(string: "Ram Patil\n",attributes: [.font:UIFont(name: "Poppins-Bold", size: 15) as Any])
        attr.append(NSAttributedString(string: "May 22",attributes: [.font:UIFont(name: "Poppins-Regular", size: 12) as Any]))
        cell.usernameLbl.numberOfLines = 0
        cell.usernameLbl.attributedText = attr
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 130)
    }
    
}
extension ParkingPlaceVC: SFSafariViewControllerDelegate{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
//class ParkingPlaceVC: UIViewController {
//
//    @IBOutlet weak var mView: UIView!
//    @IBOutlet weak var mParkCarBtn: UIButton!
//
//    @IBOutlet weak var mParkingName: UILabel!
//    @IBOutlet weak var mParkingAddress: UILabel!
//    @IBOutlet weak var mNoOfParking: UILabel!
//    @IBOutlet weak var mParkingCost: UILabel!
//
//    @IBOutlet weak var mPlaceName: UILabel!
//    @IBOutlet weak var mEndTime: UILabel!
//    @IBOutlet weak var mOpenTime: UILabel!
//    @IBOutlet weak var aboutParking: UILabel!
//
//    @IBOutlet weak var mParkingPrice: UILabel!
//
//    @IBOutlet weak var parkingImage: UIImageView!
//
//    var placeDetails : NSDictionary = NSDictionary()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.mView.layer.cornerRadius = 1
//        self.mView.layer.borderWidth = 1
//        self.mView.layer.borderColor = UIColor.gray.cgColor
//        self.mParkCarBtn.layer.cornerRadius = 1
//        self.mParkCarBtn.layer.borderWidth = 1.3
//        self.mParkCarBtn.layer.borderColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0).cgColor
//        refeshUI()
//    }
//
//    func refeshUI()
//    {
//            var currentDefaults = UserDefaults.standard
//            var savedArray = currentDefaults.object(forKey: "parkDetails") as? Data
//            if savedArray != nil {
//                var oldArray: [Any]? = nil
//                if let anArray = savedArray {
//                    oldArray = NSKeyedUnarchiver.unarchiveObject(with: anArray) as? [Any]
//                    let dict = oldArray?.first as? NSDictionary
//                    print(dict)
//                    if let val = dict?["parking_name"]
//                    {
//                    self.mParkingName.text = (val as? String)!
//                    }
//                    if let val = dict?["capacity"]
//                    {
//                    self.mNoOfParking.text =  String(format: "%d", (val as? Int)!)
//                    }
//                    if let val = dict?["address"]
//                    {
//                    self.mParkingAddress.text = (val as? String)!
//                    }
//                    if let val = dict?["parking_cost"]
//                    {
//                        self.mParkingCost.text = "\(val as? Int ?? 0)"
//                    }
//                   if let val = dict?["start_opening_hours"]
//                   {
//                     self.mOpenTime.text = (val as? String)!
//                    }
//                   if let val = dict?["end_opening_hours"]
//                   {
//                    self.mEndTime.text = (val as? String)!
//                    }
//                      if let val = dict?["parking_name"]
//                      {
//                         self.mPlaceName.text = (val as? String)!
//                    }
//                   if let val = dict?["parking_cost"]
//                   {
//
//                   self.mParkingPrice.text = "\(val as? Int ?? 0)"
//                    }
//                    if let val = dict?["description"]
//                    {
//                     self.aboutParking.text = (val as? String)!
//                    }
//                    let url1 = String(format: "%@%@",Constants.IMGBASEURL, (dict!["image"] as? NSString)!)
//                    let urlString1 = url1.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//                    self.parkingImage.sd_setImage(with: URL(string: urlString1!))
//
//                }
//        }
//
//    }
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    //MARK:- Button Actions
//
//    @IBAction func mCancel(_ sender: Any) {
//        self.navigationController?.popViewController(animated: false)
//
//    }
//
//    @IBAction func parkMyCar(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "MyCarsVC") as! MyCarsVC
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    @IBAction func mCallActn(_ sender: Any) {
//
//        let number = (placeDetails["mobilenumber"] as? String)!
//        let url:NSURL = NSURL(string: "tel://\(number)")!
//            // UIApplication.shared.canOpenURL(url as URL)
//            UIApplication.shared.canOpenURL(url as URL)
//        if #available(iOS 12, *) {
//                UIApplication.shared.open(url as URL, options: [:], completionHandler:nil)
//        } else {
//                UIApplication.shared.openURL(url as URL)
//        }
//    }
//}
