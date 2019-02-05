//
//  BarCodeList.swift
//  ScannerSample
//
//  Created by Kanhaiya Chaudhary on 02/01/19.
//  Copyright © 2019 Kanhaiya Chaudhary. All rights reserved.
//

import UIKit

class BarCodeList: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var isbt: ISbtSdkApiDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
       // baecode_Arr.append("100")
        //baecode_Arr.append("100")
       // baecode_Arr.append("100")


        
        tableView.dataSource = self
        tableView.delegate  = self
        // Do any additional setup after loading the view.
        
        //loadTable()
    }

    
    override func viewWillAppear(_ animated: Bool) {
       
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.BarcodeDetected),
            name: NSNotification.Name(rawValue: "BarcodeDetected"),
            object: nil)
        

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarcodeDetected"), object: nil)
    }
    
    @objc func BarcodeDetected(notification: NSNotification){
        
       // baecode_Arr.append("4545454")
        self.tableView.reloadData()


    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baecode_Arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BarCodeCell", for: indexPath) as! BarCodeCell
        
        cell.lbl_barcode.text = baecode_Arr[indexPath.row]
        
        return cell
    }
    
    @IBAction func back(_ sender: UIButton) {
        
      dismiss(animated: false, completion: nil)
        
    }
    
    
    @objc func dataUpdated(barcode:String){
        
        print(barcode)
        
        baecode_Arr.append(barcode)
        
//        DispatchQueue.main.async {
//            self.loadTable()
//
//        }
        
    }
    
//    func loadTable(){
//
//
//
//    }
    
    
//    func loadTable(){
//        var y = 60
//        let x = 10
//        for index in 0..<baecode_Arr.count{
//
//
//            let customView = UILabel()
//            customView.frame = CGRect.init(x: x, y: y, width: 100, height: 140)
//            customView.backgroundColor = UIColor.black
//            customView.text = baecode_Arr[index]
//            customView.center = self.view.center
//            self.view.addSubview(customView)
//            y = y + 40
//
//        }
//    }
    
    
    
    
}
