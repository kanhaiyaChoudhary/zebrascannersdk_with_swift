//
//  BarCodeCell.swift
//  ScannerSample
//
//  Created by Kanhaiya Chaudhary on 02/01/19.
//  Copyright © 2019 Kanhaiya Chaudhary. All rights reserved.
//

import UIKit

class BarCodeCell: UITableViewCell {

    @IBOutlet weak var lbl_barcode: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
