
import UIKit

class BarCodeListShow: UIViewController,UITableViewDelegate,UITableViewDataSource,ISbtSdkApiDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate  = self
        // Do any additional setup after loading the view.
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
    
    
    
    func sbtEventScannerAppeared(_ availableScanner: SbtScannerInfo!) {
        
    }
    
    func sbtEventScannerDisappeared(_ scannerID: Int32) {
        
    }
    
    func sbtEventCommunicationSessionEstablished(_ activeScanner: SbtScannerInfo!) {
        
    }
    
    func sbtEventCommunicationSessionTerminated(_ scannerID: Int32) {
        
    }
    
    func sbtEventBarcode(_ barcodeData: String!, barcodeType: Int32, fromScanner scannerID: Int32) {
        
    }
    
    func sbtEventBarcodeData(_ barcodeData: Data!, barcodeType: Int32, fromScanner scannerID: Int32) {
        
    }
    
    func sbtEventFirmwareUpdate(_ fwUpdateEventObj: FirmwareUpdateEvent!) {
        
    }
    
    func sbtEventImage(_ imageData: Data!, fromScanner scannerID: Int32) {
        
    }
    
    func sbtEventVideo(_ videoFrame: Data!, fromScanner scannerID: Int32) {
        
    }
    

    
}
