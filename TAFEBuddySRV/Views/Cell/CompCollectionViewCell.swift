//
//  CompCollectionViewCell.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 21/2/20.
//  Copyright © 2020 Jefferson Gomes. All rights reserved.
//

import UIKit

class CompCollectionViewCell: UICollectionViewCell {
    var competence: Competence! {
        didSet{
            self.updateUI()
        }
    }

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var competenceLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 10.0
    }
    
    func updateUI()
    {
        competenceLabel.text = competence.NationalCompCode
        subjectLabel.text = "Subject: \(competence.SubjectCode)"
        
        if competence.Grade == "PA" {
                iconImageView.image = UIImage(named: "success")
        } else {
                iconImageView.image = UIImage(named: "error")
        }
        
        contentView.backgroundColor = UIColor(red: 0.850, green: 0.850, blue: 0.850, alpha: 1.0)
    }
}
