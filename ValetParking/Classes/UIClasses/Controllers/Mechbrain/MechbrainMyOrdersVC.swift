//
//  MechbrainMyOrdersVC.swift
//  ValetParking
//
//  Created by Aniket Patil on 02/09/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import SDWebImageWebPCoder

class MechbrainMyOrdersVC: UIViewController {
    
    @IBOutlet weak var BackImg: UIImageView!
    @IBOutlet weak var OrderTableView: UITableView!
    
    var OrderList: [OrderListModel] = []
    var OrderItms: [OrderItemsModel] = []
    
    var delegate: DefaultDelegate? = nil
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        let webPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(webPCoder)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'"
        OrderTableView.delegate = self
        OrderTableView.dataSource = self
        OrderTableView.separatorStyle = .none
        OrderTableView.register(UINib(nibName: "MyOrdersTV", bundle: nil), forCellReuseIdentifier: "MyOrdersTV")
        OrderTableView.estimatedRowHeight = 120
        OrderTableView.rowHeight = UITableView.automaticDimension
        BackImg.isUserInteractionEnabled = true
        BackImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnPressed)))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APICALLS()
    }
    func APICALLS(){
        getOrderList()
    }
    @objc func backBtnPressed(){
        self.navigationController?.popViewController(animated: false)
    }
    func getOrderList() {
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let ticketParams: [String:Any] = ["customer_id": Int(userId) ?? 0]
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.mechbrainOrderList, method: .post, parameters: ticketParams, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("OrderListApiResponse ---- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String: Any] {
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["order_list"] as? [[String: Any]] ?? []
                            self.OrderList.removeAll()
                            self.OrderItms.removeAll()
                            for result in results{
                                let id = result["_id"] as? String ?? ""
                                let orderConfirm = result["order_confirm"] as? Bool ?? false
                                let orderPickup = result["order_pickup"] as? Bool ?? false
                                let inprogress = result["inprogress"] as? Bool ?? false
                                let completed = result["completed"] as? Bool ?? false
                                let payment = result["payment"] as? Bool ?? false
                                let orderId = result["order_id"] as? String ?? ""
                                let customerId = String(result["customer_id"] as? Int ?? 0)
                                let providerId = result["provider_id"] as? String ?? ""
                                let orderStatus = result["order_status"] as? String ?? ""
                                let orderAmount = String(result["order_amount"] as? Int ?? 0)
                                let createdAt = result["created_at"] as? String ?? ""
                                let providerAddress = result["provider_address"] as? String ?? " "
                                let providerName = result["provider_name"] as? String ?? " "
                                let providerImage = result["provider_image"] as? String ?? ""
                                let vehicleNo = result["vehicle_no"] as? String ?? ""
                                let vehicleId = String(result["vehicle_id"] as? Int ?? 0)
                                let vehicleType = result["vehicle_type"] as? String ?? ""
                                let orderItems = result["order_items"] as? [[String:Any]] ?? []
                                for orderData in orderItems{
                                    let id = orderData["_id"] as? String ?? ""
                                    let providerServiceId = orderData["provider_service_id"] as? String ?? ""
                                    let providerId = orderData["provider_id"] as? String ?? ""
                                    let customerId = String(orderData["customer_id"] as? Int ?? 0)
                                    let serviceId = orderData["service_id"] as? String ?? ""
                                    let serviceName = orderData["service_name"] as? String ?? ""
                                    let serviceDescription = orderData["service_description"] as? String ?? ""
                                    let serviceCost = String(orderData["service_cost"] as? Int ?? 0)
                                    let requiredTime = String(orderData["required_time"] as? Int ?? 0)
                                    let serviceImage = orderData["service_images"] as? [String] ?? []
                                    let serviceStatus = orderData["service_status"] as? String ?? ""
                                    let model = OrderItemsModel(id: id, providerServiceId: providerServiceId, providerId: providerId, customerId: customerId, serviceId: serviceId, serviceName: serviceName, serviceDescription: serviceDescription, serviceCost: serviceCost, requiredTime: requiredTime, serviceStatus: serviceStatus, serviceImages: serviceImage)
                                    print("OrderItems---\(model)")
                                    self.OrderItms.append(model)
                                }
                                let model = OrderListModel(id: id, orderID: orderId, customerId: customerId, providerId: providerId, orderStatus: orderStatus, orderAmount: orderAmount, createdAt: createdAt, providerAddr: providerAddress, providerName: providerName, providerImage: providerImage, vehicleId: vehicleId, vehicleNo: vehicleNo, vehicleType: vehicleType, orderConfirm: orderConfirm, orderPickup: orderPickup, inprogress: inprogress, completed: completed, payment: payment)
                                print("OrderList---\(model)")
                                self.OrderList.append(model)
                            }
                            DispatchQueue.main.async {
                                self.OrderTableView.reloadData()
                            }
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    print("ApiError ---- \(apiResponse.error?.localizedDescription ?? "")")
                }
            }
        } else{
            NetworkPopUpVC.sharedInstance.Popup(vc: self)
        }
    }

}
extension MechbrainMyOrdersVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OrderList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MyOrdersTV") as? MyOrdersTV {
            cell.selectionStyle = .none
            cell.ProviderAddress.text = OrderList[indexPath.row].providerAddr
            cell.ProviderImg.sd_setImage(with: URL(string: APIEndPoints.BaseURL + OrderList[indexPath.row].providerImage), placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], context: nil)
            cell.ProviderNameLbl.text = OrderList[indexPath.row].providerName
            cell.PlateNoLbl.text = OrderList[indexPath.row].vehicleNo
            if OrderList[indexPath.row].payment == true{
                cell.StatusImg.image = #imageLiteral(resourceName: "done")
            } else{
                cell.StatusImg.image = #imageLiteral(resourceName: "pending")
            }
            cell.OrderIdLbl.text = "Order ID: \(OrderList[indexPath.row].orderID)"
            cell.DateLbl.text = String(OrderList[indexPath.row].createdAt.convertToDate().dropLast(9))
            cell.TimeLbl.text = String(OrderList[indexPath.row].createdAt.convertToDate().dropFirst(11))
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderId = OrderList[indexPath.row].orderID
        UserDefaults.standard.setValue(orderId, forKey: "MBOrderID")
        let storyboard = UIStoryboard(name: "Mechbrain", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "MechbrainOrderDatailsVC") as! MechbrainOrderDatailsVC
        self.navigationController?.pushViewController(VC, animated: false)
    }
}
