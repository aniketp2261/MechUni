//
//  OrderDetailsVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 03/06/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SimplePDF
import SKActivityIndicatorView

struct OrderDetailsModel {
    var id, orderId, customerId, providerId, orderStatus, orderAmount, vehicleId, createdAt, orderConfirmDateTime, orderPickupDateTime, inProgressDateTime, completedDateTime, paymentDateTime, providerAddress, providerName, providerImage, vehicleNo, vehicleType, totalAfterDiscount, discount, totalAmount, promoCode: String
    let orderConfirm, orderPickup, inprogress, completed, payment, isPickup: Bool
    let orderItems: [[String : Any]]
}
struct OrderDetailsServiceModel {
    let id, providerServiceId, providerId, customerId, serviceId, serviceName, serviceDescription, serviceCost, requiredTime, serviceStatus: String
    let serviceImages: [String]
}

class OrderDetailsVC: UIViewController {
    
    @IBOutlet weak var BackImg: UIImageView!
    @IBOutlet weak var OrderIDLbl: UILabel!
    @IBOutlet weak var Refresh: UIImageView!
    @IBOutlet weak var HelpBtn: UIButton!
    @IBOutlet weak var OrderDetailsTableView: UITableView!
    
    var OrderDetails: OrderDetailsModel? = nil
    var OrderServices: [OrderDetailsServiceModel] = []
    var ServicesBackDelegate: ServicesCatVCDelegate? = nil
    var OrderDetailsVCDelegate: DefaultDelegate? = nil
    let Currentdate = Date()
    let dateFormatter = DateFormatter()
    let dateFormatter2 = DateFormatter()
    var pdfPath = URL(string: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        HelpBtn.addTarget(self, action: #selector(helpBtnPressed), for: .touchUpInside)
        OrderDetailsTableView.delegate = self
        OrderDetailsTableView.dataSource = self
        OrderDetailsTableView.separatorStyle = .none
        OrderDetailsTableView.rowHeight = 30
        OrderDetailsTableView.estimatedRowHeight = UITableView.automaticDimension
        OrderDetailsTableView.register(UINib(nibName: "OrderNameAddTVC", bundle: nil), forCellReuseIdentifier: "OrderNameAddTVC")
        OrderDetailsTableView.register(UINib(nibName: "VehicleDetailsTVC", bundle: nil), forCellReuseIdentifier: "VehicleDetailsTVC")
        OrderDetailsTableView.register(UINib(nibName: "OrderTrackingDetailsTVC", bundle: nil), forCellReuseIdentifier: "OrderTrackingDetailsTVC")
        OrderDetailsTableView.register(UINib(nibName: "OrderSummaryTVC", bundle: nil), forCellReuseIdentifier: "OrderSummaryTVC")
        BackImg.isUserInteractionEnabled = true
        BackImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnPressed)))
        Refresh.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RefreshAction)))
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name("AppEnterForeground"), object: nil)
    }
    @objc func appMovedToForeground() {
        APICALLS()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APICALLS()
    }
    func APICALLS(){
        let OrderId = UserDefaults.standard.string(forKey: "OrderID") ?? ""
        getOrderDetails(orderId: OrderId)
    }
    @objc func RefreshAction(){
        APICALLS()
    }
    @objc func backBtnPressed(){
        navigationController?.popViewController(animated: true)
        ServicesBackDelegate?.ServicesNavigationBack()
        OrderDetailsVCDelegate?.shouldNavBack()
    }
    @objc func helpBtnPressed(){
        let Vc = storyboard?.instantiateViewController(withIdentifier: "ComplaintVC") as! ComplaintVC
        Vc.TicketID = self.OrderIDLbl.text
        present(Vc, animated: true,completion: nil)
    }
    @objc func ProceedToPayment(){
        let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ServicesPaymentSummaryVC") as! ServicesPaymentSummaryVC
        vc.OrderDetails = self.OrderDetails
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func callAction(){
        self.dialNumber(number: "")
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
    @objc func shareBtnAction(_ sender:UIButton!){
        print("PdfSSSSS ---- \(self.pdfPath)")
        if self.pdfPath == nil{
            self.view.makeToast("Download Receipt First")
            print("Download Receipt First")
        } else{
            let fileManager = FileManager.default
            let urlString = self.pdfPath!
            let pathURL = urlString.path
            if fileManager.fileExists(atPath: pathURL){
                let documento = NSData(contentsOfFile: pathURL)
                let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [documento!], applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
                present(activityViewController, animated: true, completion: nil)
            } else {
                print("document was not found")
                self.view.makeToast("Document was not found")
            }
        }
    }
    @objc func generatePDF(){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"
        print("Current Date ---- \(dateFormatter.string(from: date))")
        let userName = UserDefaults.standard.string(forKey: "userName")
        var PaidAmt = ""
        if OrderDetails?.discount ?? "" == "0"{
            PaidAmt = OrderDetails?.orderAmount ?? ""
        } else{
            PaidAmt = OrderDetails?.totalAfterDiscount ?? ""
        }
        let DataArray = [["   Customer Name", "   \(userName ?? "")"],["   Vehicle Plate No", "   \((OrderDetails?.vehicleNo ?? "").uppercased())"],["   Order ID","   \(OrderDetails?.orderId ?? "")"],["   Created Date", "   \(dateFormatter.string(from: date))"],["   Order Confirmed Date & Time", "   \(OrderDetails?.orderConfirmDateTime.convertToDate() ?? "")"],["   Order Completed Date & Time", "   \(OrderDetails?.completedDateTime.convertToDate() ?? "")"],["   Total Payable Amount", "   Rs. \(OrderDetails?.orderAmount ?? "")/-"],["   Discount", "   Rs. \(OrderDetails?.discount ?? "")/-"],["   Paid Amount", "   Rs. \(PaidAmt)/-"]]
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
        pdf.addText("MechUni",font: UIFont.systemFont(ofSize: 18 ,weight: .semibold))
        pdf.addText("Email : techrequirements@mechuni.com")
        pdf.addVerticalSpace(30)
        pdf.setContentAlignment(.center)
        pdf.addText(OrderDetails?.providerName ?? "", font: UIFont.systemFont(ofSize: 22))
        pdf.addText(OrderDetails?.providerAddress ?? "",font: UIFont.systemFont(ofSize: 16))
        pdf.addVerticalSpace(40)
        pdf.setContentAlignment(.left)
        pdf.addText("Order Receipt",font: UIFont.systemFont(ofSize: 17))
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
        let ticketName = "\(self.OrderDetails?.orderId ?? "")\(self.OrderDetails?.createdAt ?? "")"
        vc.OrderModel = self.OrderDetails
        vc.ticketName = ticketName
        vc.ServicesOrder = true
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
}
extension OrderDetailsVC : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "OrderNameAddTVC") as? OrderNameAddTVC {
                cell.selectionStyle = .none
                cell.ProviderNameLbl.text = OrderDetails?.providerName ?? ""
                cell.ProviderAddressLbl.text = OrderDetails?.providerAddress ?? ""
                cell.CallImgView.isUserInteractionEnabled = true
                cell.CallImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(callAction)))
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleDetailsTVC") as? VehicleDetailsTVC{
                cell.selectionStyle = .none
                cell.VehicleNoLbl.text = OrderDetails?.vehicleNo ?? ""
                cell.DateLbl.text = String("\(OrderDetails?.createdAt ?? "")".dropLast(14))
                cell.VehicleImgView.sd_setImage(with: URL(string: ""), placeholderImage: #imageLiteral(resourceName: "mycars-1"), options: [], context: nil)
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTrackingDetailsTVC") as? OrderTrackingDetailsTVC {
                cell.selectionStyle = .none
                cell.OrderArrivedLbl.text = "Order Pickup"
                if OrderDetails?.orderConfirm == true{
                    cell.OrderConfirmedImg.image = #imageLiteral(resourceName: "Completed")
                    if OrderDetails?.orderConfirmDateTime != nil{
                        let date: Date? = dateFormatter.date(from: OrderDetails?.orderConfirmDateTime ?? "")
                        if date != nil{
                            dateFormatter2.dateFormat = "dd MMM yyyy hh:mm a"
                            dateFormatter2.locale = dateFormatter2.locale
                            let dateString = dateFormatter2.string(from: date!)
                            cell.OrderConfirmedDate.text = dateString
                        } else{
                            cell.OrderConfirmedDate.text = ""
                        }
                    } else{
                        cell.OrderConfirmedDate.text = ""
                    }
                    cell.OrderConfirmedDate.isHidden = false
                } else{
                    cell.OrderConfirmedImg.image = #imageLiteral(resourceName: "Empty")
                    cell.OrderConfirmedDate.isHidden = true
                }
                if OrderDetails?.isPickup == true{
                    cell.PickUpView.isHidden = false
                    cell.PickUpHeight.constant = 40
                    cell.OrderPickUpImg.isHidden = false
                    if OrderDetails?.orderPickup == true{
                        cell.OrderPickUpImg.image = #imageLiteral(resourceName: "Completed")
                        if OrderDetails?.orderPickupDateTime != nil{
                            let date: Date? = dateFormatter.date(from: OrderDetails?.orderPickupDateTime ?? "")
                            if date != nil{
                                dateFormatter2.dateFormat = "dd MMM yyyy hh:mm a"
                                dateFormatter2.locale = dateFormatter2.locale
                                let dateString = dateFormatter2.string(from: date!)
                                cell.OrderPickupDate.text = dateString
                            } else{
                                cell.OrderPickupDate.text = ""
                            }
                        }
                        cell.OrderPickupDate.isHidden = false
                    } else{
                        cell.OrderPickUpImg.image = #imageLiteral(resourceName: "Empty")
                        cell.OrderPickupDate.isHidden = true
                    }
                } else{
                    cell.OrderPickUpImg.isHidden = true
                    cell.PickUpView.isHidden = true
                    cell.PickUpHeight.constant = 0
                }
                if OrderDetails?.inprogress == true{
                    cell.OrderInprogressImg.image = #imageLiteral(resourceName: "Completed")
                    if OrderDetails?.inProgressDateTime != nil{
                        let date: Date? = dateFormatter.date(from: OrderDetails?.inProgressDateTime ?? "")
                        print("InprogressDate---\(date)")
                        if date != nil{
                            dateFormatter2.dateFormat = "dd MMM yyyy hh:mm a"
                            dateFormatter2.locale = dateFormatter2.locale
                            let dateString = dateFormatter2.string(from: date!)
                            cell.OrderInProgressDate.text = dateString
                        } else{
                            cell.OrderInProgressDate.text = ""
                        }
                    }
                    cell.OrderInProgressDate.isHidden = false
                } else{
                    cell.OrderInprogressImg.image = #imageLiteral(resourceName: "Empty")
                    cell.OrderInProgressDate.isHidden = true
                }
                if OrderDetails?.completed == true{
                    cell.OrderCompletedImg.image = #imageLiteral(resourceName: "Completed")
                    if OrderDetails?.completedDateTime != nil{
                        let date: Date? = dateFormatter.date(from: OrderDetails?.completedDateTime ?? "")
                        if date != nil{
                            dateFormatter2.dateFormat = "dd MMM yyyy hh:mm a"
                            dateFormatter2.locale = dateFormatter2.locale
                            let dateString = dateFormatter2.string(from: date!)
                            cell.OrderCompletedDate.text = dateString
                        } else{
                            cell.OrderCompletedDate.text = ""
                        }
                    }
                    cell.OrderCompletedDate.isHidden = false
                } else{
                    cell.OrderCompletedImg.image = #imageLiteral(resourceName: "Empty")
                    cell.OrderCompletedDate.isHidden = true
                }
                if OrderDetails?.payment == true{
                    cell.OrderSuccessfulImg.image = #imageLiteral(resourceName: "Completed")
                    cell.PaymentView.backgroundColor = UIColor.red
                    if OrderDetails?.paymentDateTime != nil{
                        let date: Date? = dateFormatter.date(from: OrderDetails?.paymentDateTime ?? "")
                        if date != nil{
                            dateFormatter2.dateFormat = "dd MMM yyyy hh:mm a"
                            dateFormatter2.locale = dateFormatter2.locale
                            let dateString = dateFormatter2.string(from: date!)
                            cell.OrderSucessfullyDate.text = dateString
                        } else{
                            cell.OrderSucessfullyDate.text = ""
                        }
                    }
                    cell.OrderSucessfullyDate.isHidden = false
                } else{
                    if #available(iOS 13.0, *) {
                        cell.PaymentView.backgroundColor = UIColor.systemGray2
                    } else {
                    }
                    cell.OrderSuccessfulImg.image = #imageLiteral(resourceName: "Empty")
                    cell.OrderSucessfullyDate.isHidden = true
                }
                return cell
            }
        case 3:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "OrderSummaryTVC") as? OrderSummaryTVC {
                if self.OrderServices.count > 0 {
                    print("OrderServices---\(OrderServices)")
                    cell.selectionStyle = .none
                    cell.getData(OrderServices: self.OrderServices)
//                  cell.OrderServices = OrderServices
                    cell.TotalCharges.text = "Rs.\(OrderDetails?.orderAmount ?? "").0"
                    cell.backView.layer.shadowColor = UIColor.black.cgColor
                    cell.backView.layer.shadowOffset = CGSize(width: 0, height: 3)
                    cell.backView.layer.shadowOpacity = 0.3
                    cell.backView.layer.shadowRadius = 3.0
                    cell.backView.layer.cornerRadius = 15
                    if OrderDetails?.completed == true{
                        cell.PaymentBtn.isUserInteractionEnabled = true
                        cell.PaymentBtn.isHidden = false
                        cell.PaymentBtn.setTitle("Proceed to Payment", for: .normal)
                        cell.PaymentBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProceedToPayment)))
                        cell.ShareBtn.isHidden = true
                        cell.PaymentStack.constant = 50
                        cell.DiscountView.isHidden = true
                    } else{
                        cell.PaymentBtn.isHidden = true
                        cell.DiscountView.isHidden = true
                        cell.PaymentStack.constant = 0
                    }
                    if OrderDetails?.payment == true{
                        cell.DiscountView.isHidden = false
                        cell.Discount.text = "Rs.\(self.OrderDetails?.discount ?? "").0"
                        if self.OrderDetails?.discount == "0"{
                            cell.PaidAmount.text = "Rs.\(self.OrderDetails?.orderAmount ?? "").0"
                        } else{
                            cell.PaidAmount.text = "Rs.\(self.OrderDetails?.totalAfterDiscount ?? "").0"
                        }
                        cell.PaymentBtn.isHidden = false
                        cell.PaymentStack.constant = 50
                        cell.PaymentBtn.setTitle("Download Receipt", for: .normal)
                        cell.PaymentBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(generatePDF)))
                        cell.ShareBtn.isHidden = false
                        cell.ShareBtn.layer.borderWidth = 1
                        cell.ShareBtn.layer.borderColor = UIColor.lightGray.cgColor
                        cell.ShareBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareBtnAction(_:))))
                    }
                }
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return UITableView.automaticDimension
        case 1:
            return 105
        case 2:
            if OrderDetails?.isPickup == true{
                return 400
            } else{
                return 350
            }
        case 3:
            if OrderDetails?.completed == true{
                return UITableView.automaticDimension
            } else if OrderDetails?.payment == true{
                return UITableView.automaticDimension
            } else{
                return UITableView.automaticDimension
            }
        default:
            return 0
        }
    }
}
extension OrderDetailsVC{
    func getOrderDetails(orderId: String){
        let params = ["order_id":orderId]
        print("OrderDetailsParams--- \(params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.OrderDetails, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("OrderDetailsResponse--- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        let msg = apiDict["message"] as? String ?? ""
                        self.OrderServices.removeAll()
                        if status == "success" {
                            let results = apiDict["order_details"] as? [[String:Any]] ?? []
                            for result in results{
                                let id = result["_id"] as? String ?? ""
                                let orderConfirm = result["order_confirm"] as? Bool ?? false
                                let orderPickup = result["order_pickup"] as? Bool ?? false
                                let inprogress = result["inprogress"] as? Bool ?? false
                                let completed = result["completed"] as? Bool ?? false
                                let payment = result["payment"] as? Bool ?? false
                                let isPickup = result["is_pickup"] as? Bool ?? false
                                let orderId = result["order_id"] as? String ?? ""
                                let customerId = String(result["customer_id"] as? Int ?? 0)
                                let providerId = result["provider_id"] as? String ?? ""
                                let orderStatus = result["order_status"] as? String ?? ""
                                let orderAmount = String(result["order_amount"] as? Int ?? 0)
                                let vehicleId = String(result["vehicle_id"] as? Int ?? 0)
                                let createdAt = result["created_at"] as? String ?? ""
                                let orderConfirmDateTime = result["order_confirm_date_time"] as? String ?? ""
                                let orderPickupDateTime = result["order_pickup_date_time"] as? String ?? ""
                                let inProgressDateTime = result["inprogress_date_time"] as? String ?? ""
                                let completedDateTime = result["completed_date_time"] as? String ?? ""
                                let paymentDateTime = result["payment_date_time"] as? String ?? ""
                                let providerAddress = result["provider_address"] as? String ?? ""
                                let providerName = result["provider_name"] as? String ?? ""
                                let providerImage = result["provider_image"] as? String ?? ""
                                let vehicleNo = result["vehicle_no"] as? String ?? ""
                                let vehicleType = result["vehicle_type"] as? String ?? ""
                                let totalAmountAfterDiscount = String(result["total_amount_after_discount"] as? Int ?? 0)
                                let discount = String(result["discount"] as? Int ?? 0)
                                let totalAmount = String(result["total_amount"] as? Int ?? 0)
                                let promoCode = result["promo_code"] as? String ?? ""
                                let orderItems = result["order_items"] as? [[String : Any]] ?? []
                                for items in orderItems{
                                    let id = items["_id"] as? String ?? ""
                                    let providerServiceId = items["provider_service_id"] as? String ?? ""
                                    let providerId = items["provider_id"] as? String ?? ""
                                    let customerId = String(items["customer_id"] as? Int ?? 0)
                                    let serviceId = items["service_id"] as? String ?? ""
                                    let serviceName = items["service_name"] as? String ?? ""
                                    let serviceDescription = items["service_description"] as? String ?? ""
                                    let serviceCost = String(items["service_cost"] as? Int ?? 0)
                                    let requiredTime = String(items["required_time"] as? Int ?? 0)
                                    let serviceImages = items["service_images"] as? [String] ?? []
                                    let serviceStatus = items["service_status"] as? String ?? ""
                                    let model = OrderDetailsServiceModel(id: id, providerServiceId: providerServiceId, providerId: providerId, customerId: customerId, serviceId: serviceId, serviceName: serviceName, serviceDescription: serviceDescription, serviceCost: serviceCost, requiredTime: requiredTime, serviceStatus: serviceStatus, serviceImages: serviceImages)
                                    self.OrderServices.append(model)
                                    print("OrderServices---\(model)")
                                }
                                let model = OrderDetailsModel(id: id, orderId: orderId, customerId: customerId, providerId: providerId, orderStatus: orderStatus, orderAmount: orderAmount, vehicleId: vehicleId, createdAt: createdAt, orderConfirmDateTime: orderConfirmDateTime, orderPickupDateTime: orderPickupDateTime, inProgressDateTime: inProgressDateTime, completedDateTime: completedDateTime, paymentDateTime: paymentDateTime, providerAddress: providerAddress, providerName: providerName, providerImage: providerImage, vehicleNo: vehicleNo, vehicleType: vehicleType,totalAfterDiscount: totalAmountAfterDiscount,discount: discount,totalAmount: totalAmount,promoCode: promoCode, orderConfirm: orderConfirm, orderPickup: orderPickup, inprogress: inprogress, completed: completed, payment: payment, isPickup: isPickup, orderItems: orderItems)
                                print("OrderDetails---\(model)")
                                self.OrderDetails = model
                                DispatchQueue.main.async {
                                    self.OrderIDLbl.text = self.OrderDetails?.orderId ?? ""
                                    self.OrderDetailsTableView.reloadData()
                                }
                            }
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    AlertFunctions.showAlert(message: "",title: apiResponse.error?.localizedDescription ?? "")
                }
            }
        } else{
            NetworkPopUpVC.sharedInstance.Popup(vc: self)
        }
    }
}
