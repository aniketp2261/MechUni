//
//  TicketDetailsVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 10/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import SimplePDF
import SKActivityIndicatorView


struct TicketDetailModel{
    let carPickUpStatus, paymentDoneStatus: Bool
    let carPickUpTime, ID: String
    let paymentDoneTime: String
    let ticketID, generatedOn, parkingName, parkingAddress: String
    let contact, carImage: String
    let plateNo, carParkedDate, vehicleType: String
    let twoWpCost, fourWpCost: String
    let carPickUpDate: String
    let miniChargeTwo,minChargeFour,fromHour,toHour,minimumCharges: String
    let paymentDoneDate, ticketOrderId: String
    let totalCharges, carParkedTime, hours, availablePaymentType: String
    let status,promocode,discount,totalAfterDiscount:String
}

class TicketDetailsVC: UIViewController {

    @IBOutlet weak var TicketIdLbl: UILabel!
    @IBOutlet weak var HelpBtn: UIButton!
    @IBOutlet weak var BackImg: UIImageView!
    @IBOutlet weak var TicketDetailsTableView: UITableView!
    
    var ticketDelegate: DefaultDelegate? = nil
    var parkingBackDelegate: ParkingBackDelegate? = nil
    var ticketDetailModel: GetTicketDataModel? = nil
    var ticketModel: TicketDetailModel? = nil
    var GeneratedPdfData = Data()
    var pdfPath = URL(string: "")
    var ticketId = String()
    var paidAmount = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        HelpBtn.addTarget(self, action: #selector(helpBtnPressed), for: .touchUpInside)
        TicketDetailsTableView.delegate = self
        TicketDetailsTableView.dataSource = self
        TicketDetailsTableView.separatorStyle = .none
        TicketDetailsTableView.register(UINib(nibName: "TicketNameAddTVC", bundle: nil), forCellReuseIdentifier: "TicketNameAddTVC")
        TicketDetailsTableView.register(UINib(nibName: "ParkingDetailsTVC", bundle: nil), forCellReuseIdentifier: "ParkingDetailsTVC")
        TicketDetailsTableView.register(UINib(nibName: "TrackingDetailsTVC", bundle: nil), forCellReuseIdentifier: "TrackingDetailsTVC")
        TicketDetailsTableView.register(UINib(nibName: "CarPickedUpTVC", bundle: nil), forCellReuseIdentifier: "CarPickedUpTVC")
        TicketDetailsTableView.register(UINib(nibName: "TicketDownloadBtnTVC", bundle: nil), forCellReuseIdentifier: "TicketDownloadBtnTVC")
        BackImg.isUserInteractionEnabled = true
        BackImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnPressed)))
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentSuccess(_:)), name: NSNotification.Name(rawValue: "PaymentSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(QRScanner(_:)), name: NSNotification.Name(rawValue: "CarPickUp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(paymentDetails(_:)), name: NSNotification.Name(rawValue: "PaymentDetails"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name("AppEnterForeground"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DisplayView()
    }
    @objc func appMovedToForeground() {
        DisplayView()
    }
    func DisplayView(){
        let tickketId = UserDefaults.standard.string(forKey: "TicketId") ?? ""
        getTicketDetails(ticketId: tickketId)
    }
    @objc func backBtnPressed(){
        navigationController?.popViewController(animated: true)
        ticketDelegate?.shouldNavBack()
        parkingBackDelegate?.ParkingNavigationBack()
    }
    @objc func helpBtnPressed(){
        let Vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ComplaintVC") as! ComplaintVC
        Vc.TicketID = self.TicketIdLbl.text
        present(Vc, animated: true,completion: nil)
//      self.navigationController?.pushViewController(Vc, animated: false)
    }
    @objc func callAction(){
        self.dialNumber(number: self.ticketModel?.contact ?? "")
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
    @objc func PaymentSuccess(_ not: Notification){
        print("Payment Successfully....\(UserDefaults.standard.string(forKey: "TicketId") ?? "")")
        getTicketDetails(ticketId: UserDefaults.standard.string(forKey: "TicketId") ?? "")
        self.TicketDetailsTableView.reloadData()
    }
    @objc func QRScanner(_ not: Notification){
        print("PickUp Successfully....\(UserDefaults.standard.string(forKey: "TicketId") ?? "")")
    }
    @objc func paymentDetails(_ not: Notification){
        guard let obj = not.object as? [String:Any?] else {return}
        print("paymentDetails---\(obj)")
        self.paidAmount = obj["amount"] as? String ?? ""
    }
}
//MARK:API Calls
extension TicketDetailsVC {

    func getTicketDetails(ticketId: String){
        let params = ["ticket_id":ticketId]
        print("detialParams-0000---- \(params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.BaseURL + "ticket_management/get_details_by_ticket_id", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("detialResponse000 -- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? Bool ?? false
                        if status {
                            let msg = apiDict["message"] as? String
                            let results = apiDict["result"] as? [[String:Any]] ?? []
                            for result in results{
                                let parkingStatus = result["status"] as? String ?? ""
                                let carPicketUpStatus = result["car_pick_up_status"] as? Bool ?? false
                                let paymentDoneStatus = result["payment_done_status"] as? Bool ?? false
                                let carPickUpTime = result["car_pick_up_time"] as? String ?? ""
                                let paymentDoneTime = result["payment_done_time"] as? String ?? ""
                                let parkingid = String(result["parking_id"] as? Int ?? 0)
                                let ticketId = result["ticket_id"] as? String ?? ""
                                let generatedOn = result["generated_on"] as? String ?? ""
                                let parkingName = result["parking_name"] as? String ?? ""
                                let parkingAddress = result["parking_address"] as? String ?? ""
                                let contact = result["contact"] as? String ?? ""
                                let carImage = result["car_image"] as? String ?? ""
                                let plateNo = result["plate_no"] as? String ?? ""
                                let vehicleType = result["vehicle_type"] as? String ?? ""
                                let orderID = result["ticket_order_id"] as? String ?? ""
                                let minimumChargeTwo = String(result["minimum_charge_two"] as? Int ?? 0)
                                let minimumChargeFour = String(result["minimum_charge_four"] as? Int ?? 0)
                                let fromHour = String(result["fromHour"] as? Int ?? 0)
                                let toHour = String(result["toHour"] as? Int ?? 0)
                                let minimumCharges = String(result["minimum_charges"] as? Int ?? 0)
                                let carParkedDate = result["car_parked_date"] as? String ?? ""
                                let twoWheelerCost = String(result["two_wp_cost"] as? Int ?? 0)
                                let fourWheelerCost = String(result["four_wp_cost"] as? Int ?? 0)
                                let carPickUpDate = result["car_pick_up_date"] as? String ?? ""
                                let paymentDoneDate = result["payment_done_date"] as? String ?? ""
                                let totalCharges = String(result["total_charges"] as? Int ?? 0)
                                let carparkedTime = result["car_parked_time"] as? String ?? ""
                                let availablePaymentType = result["available_payment_type"] as? String ?? ""
                                let hours = result["hours"] as? String ?? ""
                                let discount = String(result["discount"] as? Int ?? 0)
                                let totalAfterDiscount = String(result["total_after_discount"] as? Int ?? 0)
                                let promoCode = result["promo_code"] as? String ?? ""
                                
                                let model = TicketDetailModel(carPickUpStatus: carPicketUpStatus, paymentDoneStatus: paymentDoneStatus, carPickUpTime: carPickUpTime, ID: parkingid, paymentDoneTime: paymentDoneTime, ticketID: ticketId, generatedOn: generatedOn, parkingName: parkingName, parkingAddress: parkingAddress, contact: contact, carImage: carImage, plateNo: plateNo, carParkedDate: carParkedDate, vehicleType: vehicleType, twoWpCost: twoWheelerCost, fourWpCost: fourWheelerCost, carPickUpDate: carPickUpDate,miniChargeTwo: minimumChargeTwo,minChargeFour: minimumChargeFour,fromHour: fromHour,toHour: toHour,minimumCharges: minimumCharges, paymentDoneDate: paymentDoneDate, ticketOrderId: orderID, totalCharges: totalCharges, carParkedTime: carparkedTime, hours: hours, availablePaymentType: availablePaymentType,status: parkingStatus,promocode: promoCode,discount: discount,totalAfterDiscount: totalAfterDiscount)
                                self.ticketModel = model
                                print("TicketMaodelll--- \(self.ticketModel)")
                            }
                            DispatchQueue.main.async {
                                self.TicketIdLbl.text = self.ticketModel?.ticketID ?? ""
                                self.TicketDetailsTableView.reloadData()
                            }
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    AlertFunctions.showAlert(message: "",title: apiResponse.error?.localizedDescription ?? "")
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
}
extension TicketDetailsVC : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TicketNameAddTVC") as? TicketNameAddTVC {
                cell.selectionStyle = .none
                cell.AddressLbl.text = ticketModel?.parkingAddress
                cell.ParkingNameLbl.text = ticketModel?.parkingName
                let CallTap = UITapGestureRecognizer(target: self, action: #selector(callAction))
                cell.CallImgView.isUserInteractionEnabled = true
                cell.CallImgView.addGestureRecognizer(CallTap)
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingDetailsTVC") as? ParkingDetailsTVC {
                cell.selectionStyle = .none
                cell.DateLbl.text = ticketModel?.carParkedDate
                cell.platnoLbl.text = ticketModel?.plateNo
                cell.ParkingImgView.contentMode = .scaleAspectFill
                cell.ParkingImgView.layer.cornerRadius = 10
                cell.ParkingImgView.sd_setImage(with: URL(string: APIEndPoints.BASE_IMAGE_URL + (ticketModel?.carImage ?? "")), placeholderImage: #imageLiteral(resourceName: "mycars-1"), options: [], context: nil)
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TrackingDetailsTVC") as? TrackingDetailsTVC {
                cell.selectionStyle = .none
                if ticketModel?.carParkedDate != "" && ticketModel?.carParkedDate != nil {
                    cell.CarParkedImg.image = #imageLiteral(resourceName: "Completed")
                }
                if ticketModel?.carPickUpStatus == true {
                    cell.CarPickedImg.image = #imageLiteral(resourceName: "Completed")
                } else{
                    cell.CarPickedImg.image = #imageLiteral(resourceName: "Empty")
                }
                if ticketModel?.paymentDoneStatus == true {
                    cell.PaymentSuccImg.image = #imageLiteral(resourceName: "Completed")
                    cell.PaymentSuccView.backgroundColor = .red
                } else{
                    cell.PaymentSuccImg.image = #imageLiteral(resourceName: "Empty")
                    if #available(iOS 13.0, *) {
                        cell.PaymentSuccView.backgroundColor = UIColor.systemGray2
                    } else {
                    }
                }
                cell.CarParkedDateLbl.text = "\(ticketModel?.carParkedDate ?? "") \(ticketModel?.carParkedTime ?? "")"
                cell.CarPickedUpLbl.text = "\(ticketModel?.carPickUpDate ?? "") \(ticketModel?.carPickUpTime ?? "")"
                cell.PaymentSuccLbl.text = "\(ticketModel?.paymentDoneDate ?? "") \(ticketModel?.paymentDoneTime ?? "")"
                return cell
            }
        case 3:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CarPickedUpTVC") as? CarPickedUpTVC {
                cell.selectionStyle = .none
                if ticketModel?.vehicleType == "2"{
                    cell.ParkingChargesLbl.text = "Rs.\(ticketModel?.fourWpCost ?? "")/Hr"
                }
                else if ticketModel?.vehicleType == "1"{
                    cell.ParkingChargesLbl.text = "Rs.\(ticketModel?.twoWpCost ?? "")/Hr"
                }
                cell.TotalParkingCharges.text = "Rs.\(ticketModel?.totalCharges ?? "")"
                cell.TotalParkingHours.text = ticketModel?.hours ?? ""
                cell.MinimumParkingChargesLbl.text = "Rs.\(ticketModel?.minimumCharges ?? "")"
                cell.backView.layer.shadowColor = UIColor.black.cgColor
                cell.backView.layer.shadowOffset = CGSize(width: 0, height: 3)
                cell.backView.layer.shadowOpacity = 0.3
                cell.backView.layer.shadowRadius = 3.0
                cell.backView.layer.cornerRadius = 15
                if ticketModel?.paymentDoneStatus == true{
                    cell.lineView.isHidden = false
                    cell.DiscountStackView.isHidden = false
                    cell.PaidAmountStackView.isHidden = false
                    cell.DiscountLbl.text = "Rs.\(ticketModel?.discount ?? "")"
                    cell.PaidAmountLbl.text = "Rs.\(ticketModel?.totalAfterDiscount ?? "")"
                } else{
                    cell.DiscountStackView.isHidden = true
                    cell.PaidAmountStackView.isHidden = true
                    cell.lineView.isHidden = true
                    cell.DiscountLbl.text = ""
                    cell.PaidAmountLbl.text = ""
                }
                return cell
            }
        case 4:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TicketDownloadBtnTVC") as? TicketDownloadBtnTVC {
                cell.selectionStyle = .none
                print("carPickUpStatus0000 ---- \(ticketModel?.carPickUpStatus)")
                print("carPickUpStatus00001 ---- \(ticketModel?.paymentDoneStatus)")
                print("carPickUpStatus000011 ---- \(ticketModel?.carParkedDate)")

                if ticketModel?.carPickUpStatus == true{
                    cell.ScanQrBtn.setTitle("Proceed to Payment", for: .normal)
                    cell.ShareBtnWidth.constant = 0
                    cell.ScanQrBtn.tag = 0
                    cell.ScanQrBtn.addTarget(self, action: #selector(ticketDownloadAction(_:)), for: .touchUpInside)
                } else if ticketModel?.paymentDoneStatus == true{
                    cell.ScanQrBtn.setTitle("Download Receipt", for: .normal)
                    cell.ShareBtnWidth.constant = 50
                    cell.ScanQrBtn.tag = 1
                    cell.ShareBtn.tag = 1
                    cell.ScanQrBtn.addTarget(self, action: #selector(ticketDownloadAction(_:)), for: .touchUpInside)
                    cell.ShareBtn.addTarget(self, action: #selector(shareBtnAction(_:)), for: .touchUpInside)
                } else if ticketModel?.carParkedDate != nil && ticketModel?.carParkedDate != "" {
                    cell.ScanQrBtn.setTitle("Scan QR Code", for: .normal)
                    print("Scan QR Code-----")
                    cell.ShareBtnWidth.constant = 0
                    cell.ScanQrBtn.tag = 2
                    cell.ScanQrBtn.addTarget(self, action: #selector(ticketDownloadAction(_:)), for: .touchUpInside)
                }
                if ticketModel?.paymentDoneStatus == true {
                    cell.ScanQrBtn.setTitle("Download Receipt", for: .normal)
                    cell.ShareBtnWidth.constant = 50
                    cell.ScanQrBtn.tag = 1
                    cell.ShareBtn.tag = 1
                    cell.ScanQrBtn.addTarget(self, action: #selector(ticketDownloadAction(_:)), for: .touchUpInside)
                    cell.ShareBtn.addTarget(self, action: #selector(shareBtnAction(_:)), for: .touchUpInside)
                }
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }
    @objc func shareBtnAction(_ sender:UIButton!){
        print("PdfSSSSS ---- \(self.pdfPath)")
        if self.pdfPath == nil{
            self.view.makeToast("Download Receipt First")
            print("Download Receipt First")
        }else{
            let fileManager = FileManager.default
            let urlString = self.pdfPath!
            let pathURL = urlString.path

            if fileManager.fileExists(atPath: pathURL){
                let documento = NSData(contentsOfFile: pathURL)
                let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [documento!], applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
                present(activityViewController, animated: true, completion: nil)
            }
            else {
                print("document was not found")
                self.view.makeToast("Document was not found")
            }
        }
    }
    @objc func ticketDownloadAction(_ sender:UIButton!){
        if sender.tag == 0 {
            // make payment action
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentSummaryVC") as! PaymentSummaryVC
            vc.ticketModel = self.ticketModel
            self.navigationController?.pushViewController(vc, animated: true)
        } else if sender.tag == 1 {
            // download reciept action
            generatePDF()
        } else {
            // scan qr code action
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScannerViewController") as! ScannerViewController
            vc.ticketId = self.TicketIdLbl.text
            vc.id = self.ticketModel?.ID
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    func generatePDF(){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd '&' h:mm a"
        print("Current Date ---- \(dateFormatter.string(from: date))")
        print("TickeModelData ---- \(ticketModel)")
        let userName = UserDefaults.standard.string(forKey: "userName")
        var DataArray = [["   Customer Name", "   \(userName ?? "")"],["   Vehicle Plate No", "   \((ticketModel?.plateNo ?? "").uppercased())"],["   Ticket ID","   \(ticketModel?.ticketID ?? "")"],["   Created Date", "   \(dateFormatter.string(from: date))"],["   Parked Date & Time", "   \(ticketModel?.carParkedDate ?? "") & \(ticketModel?.carParkedTime ?? "")"],["   Pick up Date & Time", "   \(ticketModel?.carPickUpDate ?? "") & \(ticketModel?.carPickUpTime ?? "")"],["   Total Payable Amount", "   Rs. \(ticketModel?.totalCharges ?? "")/-"],["   Discount", "   Rs. \(ticketModel?.discount ?? "")/-"],["   Paid Amount", "   Rs. \(ticketModel?.totalAfterDiscount ?? "")/-"]]
        let path = NSTemporaryDirectory().appending("sample1.pdf")
        let A4paperSize = CGSize(width: 595, height: 842)
        let pdf = SimplePDF(pageSize: A4paperSize, pageMarginLeft: 35, pageMarginTop: 50, pageMarginBottom: 40, pageMarginRight: 35)
        let tableDef = TableDefinition(alignments: [.left, .left],
                                       columnWidths: [220, 270],
                                       fonts: [UIFont.systemFont(ofSize: 15),
                                               UIFont.systemFont(ofSize: 16)],
                                       textColors: [UIColor.black,
                                                    UIColor.black])

        pdf.setContentAlignment(.right)
        pdf.addText("MechUni",font: UIFont.systemFont(ofSize: 18,weight: .semibold))
        pdf.addText("Email : techrequirements@mechuni.com")
        pdf.addVerticalSpace(30)
        pdf.setContentAlignment(.center)
        pdf.addText(ticketModel?.parkingName ?? "", font: UIFont.systemFont(ofSize: 22))
        pdf.addText(ticketModel?.parkingAddress ?? "",font: UIFont.systemFont(ofSize: 16))
        pdf.addVerticalSpace(40)
        pdf.setContentAlignment(.left)
        pdf.addText("Parking Receipt",font: UIFont.systemFont(ofSize: 17))
        pdf.addVerticalSpace(20)
        pdf.beginHorizontalArrangement()
        pdf.addHorizontalSpace(60)
        pdf.endHorizontalArrangement()
        pdf.addTable(DataArray.count,
                     columnCount: 2,
                     rowHeight: 45,
                     tableLineWidth: 1.0,
                     tableDefinition: tableDef,
                     dataArray: DataArray)
        pdf.addVerticalSpace(50)
        let pdfData = pdf.generatePDFdata()
        try? pdfData.write(to: URL(fileURLWithPath: path), options: .atomicWrite)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "VehiclePdfVC") as! VehiclePdfVC
        let ticketName = "\(self.ticketModel?.plateNo ?? "")\(self.ticketModel?.carParkedTime ?? "")"
        vc.ticketModel = self.ticketModel
        vc.ticketName = ticketName
        self.navigationController?.pushViewController(vc, animated: true)
        vc.GeneratedPdfData = pdfData
        print("GeneratedPDF---- \(pdfData)")
    
        DispatchQueue.main.async {
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = "MechUni-\(ticketName)-receipt.pdf"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            self.pdfPath = actualPath
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch  indexPath.section {
        case 0:
            return 120
        case 1:
            return 120
        case 2:
            return 315
        case 3:
            if ticketModel?.paymentDoneStatus == true{
//              tableView.reloadData()
                print("should Return 160")
                return 220
            } else if ticketModel?.carPickUpStatus == true{
                return 160
            }
            return 0
        case 4:
            return 80
        default:
            return 100
        }
    }
    
}
