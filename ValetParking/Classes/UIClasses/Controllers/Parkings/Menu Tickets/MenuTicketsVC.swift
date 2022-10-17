//
//  MenuTicketsVC.swift
//  ValetParking
//
//  Created by admin on 21/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import SKActivityIndicatorView
import SDWebImageWebPCoder

class MenuTicketsVC: UIViewController {

    @IBOutlet weak var TicketListView: UIView!
    @IBOutlet weak var BackImg: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var MenuTicketsTableView: UITableView!
    
    var ticketArray:[GetTicketDataModel] = []
    var delegate:DefaultDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        let webPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(webPCoder)
        TicketListView.layer.cornerRadius = 16
        MenuTicketsTableView.delegate = self
        MenuTicketsTableView.dataSource = self
        MenuTicketsTableView.separatorStyle = .none
        MenuTicketsTableView.rowHeight = 180
        MenuTicketsTableView.estimatedRowHeight = UITableView.automaticDimension
        MenuTicketsTableView.register(UINib(nibName: "MenuTicketsTVC", bundle: nil), forCellReuseIdentifier: "MenuTicketsTVC")
        BackImg.isUserInteractionEnabled = true
        BackImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnPressed)))
        getUserTickets()
    }
    @objc func backBtnPressed(){
        navigationController?.popViewController(animated: false)
    }
    @objc func dismissVC(){
        dismiss(animated: true) {
            self.delegate?.shouldNavBack()
        }
    }
    @IBAction func MenuAction(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    func getUserTickets() {
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let ticketParams:[String:Any] = ["_id_customer_table":Int(userId)]
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.getTicketList,method: .post,parameters: ticketParams,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("getTicketListApiResponse1234 ---- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any] {
                        let status = apiDict["status"] as? Bool ?? false
                        if status {
                            let results = apiDict["result"] as? [[String:Any]] ?? []
                            self.ticketArray.removeAll()
                            for result in results{
                                let id = result["_id"] as? String ?? ""
                                let carPickUpStatus = result["car_pick_up_status"] as? Bool ?? false
                                let paymentDoneStatus = result["payment_done_status"] as? Bool ?? false
                                let idParkingManagement = result["id_parking_management"] as? Int ?? 0
                                let ticketId = result["ticket_id"] as? String ?? ""
                                let generatedOn = result["generated_on"] as? String ?? ""
                                let parkingName = result["parking_name"] as? String ?? ""
                                let generatedDate = result["generated_date"] as? String ?? ""
                                let address = result["address"] as? String ?? ""
                                let plateNo = result["plate_no"] as? String ?? ""
                                let parkingImg = result["parking_image"] as? String ?? ""
                                let generatedTime = result["generated_time"] as? String ?? ""
                                let model = GetTicketDataModel(id: id, carPickUpStatus: carPickUpStatus, paymentDoneStatus: paymentDoneStatus, idParkingManagement: idParkingManagement, ticketID: ticketId, generatedOn: generatedOn, parkingName: parkingName, parkingImage: parkingImg, generatedDate: generatedDate, address: address, plateNo: plateNo, generatedTime: generatedTime)
                                print("getParkingData000012 ---- \(model)")
                                UserDefaults.standard.setValue(ticketId, forKey: "TicketId")
                                self.ticketArray.append(model)
                            }
                            DispatchQueue.main.async {
                                self.MenuTicketsTableView.reloadData()
                                if self.ticketArray.count > 0{
                                    self.NoDataLbl.isHidden = true
                                } else{
                                    self.NoDataLbl.isHidden = false
                                }
                            }
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    print("getTicketsApiError ---- \(apiResponse.error?.localizedDescription ?? "")")
                }
            }
        } else{
            NetworkPopUpVC.sharedInstance.Popup(vc: self)
        }
    }

}
extension MenuTicketsVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTicketsTVC") as? MenuTicketsTVC {
            cell.selectionStyle = .none
            cell.ParkingAddress.text = ticketArray[indexPath.row].address
            cell.ParkingImg.sd_setImage(with: URL(string: APIEndPoints.BASE_PARKING_URL + ticketArray[indexPath.row].parkingImage), placeholderImage: #imageLiteral(resourceName: "parkingPlaceholderImg"), options: [], context: nil)
            cell.ParkingNameLbl.text = ticketArray[indexPath.row].parkingName
            cell.PlateNoLbl.text = ticketArray[indexPath.row].plateNo
            if ticketArray[indexPath.row].paymentDoneStatus == true{
                cell.StatusImg.image = #imageLiteral(resourceName: "done")
            }else{
                cell.StatusImg.image = #imageLiteral(resourceName: "pending")
            }
            cell.TicketIdLbl.text = "Ticket ID:\(ticketArray[indexPath.row].ticketID)"
            cell.DateLbl.text = ticketArray[indexPath.row].generatedDate
            cell.TimeLbl.text = ticketArray[indexPath.row].generatedTime
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ticket = ticketArray[indexPath.row].ticketID
        UserDefaults.standard.setValue(ticket, forKey: "TicketId")
        print("TicketId---- \(ticket)")
        let VC = storyboard?.instantiateViewController(withIdentifier: "TicketDetailsVC") as! TicketDetailsVC
        self.navigationController?.pushViewController(VC, animated: false)
    }
}
