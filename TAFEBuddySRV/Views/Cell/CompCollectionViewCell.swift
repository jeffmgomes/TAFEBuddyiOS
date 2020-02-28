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
    @IBOutlet weak var gradeLabel: UILabel!
    //@IBOutlet weak var backgroundCellView: UIView!
    @IBOutlet weak var competenceDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 10.0

    }
    
    func updateUI()
    {
        competenceLabel.text = competence.NationalCompCode
        gradeLabel.text = competence.Grade
        subjectLabel.text = "Subject: \(competence.SubjectCode)"
        competenceDescription.text = competence.CompetencyName
        
        if competence.Grade == "PA" {
                iconImageView.image = UIImage(named: "success")
        } else {
                iconImageView.image = UIImage(named: "error")
        }
        
        //backgroundCellView.backgroundColor = .white
        //backgroundCellView.layer.cornerRadius = 4.0
        
        contentView.backgroundColor = .lightGray
    }
}
