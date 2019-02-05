

import UIKit

class PairDeviceVC: UIViewController {

    @IBOutlet weak var img_reset: UIImageView!
    @IBOutlet weak var img_pair: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        img_reset.image =  Barcode.fromString(string: "Reset Factory Defaults")
        img_pair.image =  Barcode.fromString(string: "SSI BT LE")



    }
    



}


class Barcode {
    class func fromString(string : String) -> UIImage? {
        let data = string.data(using: .ascii)
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            if let outputCIImage = filter.outputImage {
                return UIImage(ciImage: outputCIImage)
            }
        }
        return nil
    }
}
