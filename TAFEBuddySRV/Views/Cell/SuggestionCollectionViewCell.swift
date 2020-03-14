//
//  SuggestionCollectionViewCell.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 12/3/20.
//  Copyright © 2020 Jefferson Gomes. All rights reserved.
//

import UIKit

class SuggestionCollectionViewCell: UICollectionViewCell {
    var subject: Subject! {
        didSet{
            self.updateUI()
        }
    }
    
    @IBOutlet weak var subjectCodeLabel: UILabel!
    @IBOutlet weak var subjectDescriptionLabel: UILabel!
    
    @IBOutlet weak var subjectTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 10.0
    }
    
    func updateUI()
    {
        subjectCodeLabel.text = subject.subjectCode

        subjectDescriptionLabel.text = subject.subjectDescription
        
        subjectTypeLabel.text = subject.subjectUsageType
        
        contentView.backgroundColor = UIColor(red: 0.850, green: 0.850, blue: 0.850, alpha: 1.0)
    }
}
