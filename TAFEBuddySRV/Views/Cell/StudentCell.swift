//
//  StudentCell.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 19/3/20.
//  Copyright © 2020 Jefferson Gomes. All rights reserved.
//

import Foundation
import UIKit

class StudentCell: UITableViewCell{
    static let identifier = "studentCell"

    @IBOutlet weak var studentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Set up Progress bar
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
