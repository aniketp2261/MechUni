//
//  VehiclePdfVC.swift
//  ValetParking
//
//  Created by Apple on 14/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import PDFKit


class VehiclePdfVC: UIViewController {
    
    @IBOutlet weak var PdfUiview : UIView!
    @IBOutlet weak var BackImg : UIImageView!
    @IBOutlet weak var downlaodPdfImg: UIImageView!
    @IBOutlet weak var SharePdfImg: UIImageView!
    
    var GeneratedPdfData = Data()
    var ticketModel:TicketDetailModel? = nil
    var OrderModel:OrderDetailsModel? = nil
    var ServicesOrder = false
    var pdfPath = URL(string: "")
    var ticketName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewGeneratedPDF()
        SavePDF()
        BackImg.isUserInteractionEnabled = true
        BackImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BackImgBtnPressed)))
        downlaodPdfImg.isUserInteractionEnabled = true
        downlaodPdfImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DownloadBtnPressed)))
        SharePdfImg.isUserInteractionEnabled = true
        SharePdfImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShareBtnPressed)))
        DispatchQueue.main.async {
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            var pdfNameFromUrl = ""
            if self.ServicesOrder == true{
                pdfNameFromUrl = "MechUni-\(self.OrderModel?.orderId ?? "")\(self.OrderModel?.createdAt ?? "")-receipt.pdf"
            } else{
                pdfNameFromUrl = "MechUni-\(self.ticketModel?.plateNo ?? "")\(self.ticketModel?.carParkedTime ?? "")-receipt.pdf"
            }
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            self.pdfPath = actualPath
        }
    }
    @objc func BackImgBtnPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    @objc func DownloadBtnPressed(){
        SavePDF()
    }
    func SavePDF(){
        if ServicesOrder == true{
            savePdf(pdfData: GeneratedPdfData, fileName: "\(OrderModel?.orderId ?? "")\(OrderModel?.createdAt ?? "")-receipt")
        } else{
            savePdf(pdfData: GeneratedPdfData, fileName: "\(ticketModel?.plateNo ?? "")\(ticketModel?.carParkedTime ?? "")-receipt")
        }
    }
    @objc func ShareBtnPressed(){
        print("PdfPathhh ---- \(self.pdfPath!)")
        loadPDFAndShare()
    }
    func viewGeneratedPDF(){
        let pdfView = PDFView(frame: self.PdfUiview.bounds)
            pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.PdfUiview.addSubview(pdfView)
        
            pdfView.autoScales = true
            pdfView.document = PDFDocument(data: GeneratedPdfData)
    }
    func savePdf(pdfData:Data, fileName:String) {
        DispatchQueue.main.async {
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = "MechUni-\(self.ticketName)-receipt.pdf"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            self.pdfPath = actualPath
            do {
                try? pdfData.write(to: actualPath, options: .atomic)
                print("Pdf successfully saved!")
                print("Path of Pdf Saved ---\(actualPath)")
                self.view.makeToast("Pdf successfully saved!")
        //  file is downloaded in app data container, I can find file from x code > devices > MyApp > download Container >This container has the file
            } catch {
                print("Pdf could not be saved")
                self.view.makeToast("Pdf could not be saved")
            }
        }
    }
    func loadPDFAndShare(){

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
