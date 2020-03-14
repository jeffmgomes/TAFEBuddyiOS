//
//  QualificationCell.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 6/9/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import UIKit

class QualificationCell : UITableViewCell{
    static let identifier = "QualCell"
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var progressBar: CircularProgressBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Set up Progress bar
        progressBar.labelSize = 15
        progressBar.lineWidth = 4
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
