//
//  OrderSummaryTVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 03/06/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class OrderSummaryTVC: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var TotalCharges: UILabel!
    @IBOutlet weak var Discount: UILabel!
    @IBOutlet weak var PaidAmount: UILabel!
    @IBOutlet weak var DiscountView: UIView!
    @IBOutlet weak var DiscountViewHeight: NSLayoutConstraint!
    @IBOutlet weak var PaymentBtn: UIButton!
    @IBOutlet weak var ShareBtn: UIButton!
    @IBOutlet weak var ServiceTBV: UITableView!
    @IBOutlet weak var ServiceTBVHeight: NSLayoutConstraint!
    @IBOutlet weak var PaymentStack: NSLayoutConstraint!
    
    var OrderServices: [OrderDetailsServiceModel] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        PaymentBtn.layer.borderColor = UIColor.red.cgColor
        ServiceTBV.delegate = self
        ServiceTBV.dataSource = self
        ServiceTBV.register(UINib(nibName: "ServiceListInOrderTVC", bundle: nil), forCellReuseIdentifier: "ServiceListInOrderTVC")
        ServiceTBV.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getData(OrderServices: [OrderDetailsServiceModel]) {
        self.OrderServices = OrderServices
        self.ServiceTBV.reloadData()
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]{
                let newsize = newvalue as! CGSize
                self.ServiceTBVHeight.constant = newsize.height
            }
        }
    }
}
extension OrderSummaryTVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.OrderServices.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceListInOrderTVC") as! ServiceListInOrderTVC
        cell.sizeToFit()
        cell.ServiceName.text = OrderServices[indexPath.row].serviceName
        cell.ServiceCost.text = "Rs.\(OrderServices[indexPath.row].serviceCost).0"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
}
