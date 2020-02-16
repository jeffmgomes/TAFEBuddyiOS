//
//  CompetenceCell.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 25/10/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import UIKit

class CompetenceCell: UITableViewCell {
    
    var competence: Competence! {
        didSet{
            self.updateUI()
        }
    }

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var competenceLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var backgroundCellView: UIView!
    @IBOutlet weak var competenceDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        
        backgroundCellView.backgroundColor = .white
        backgroundCellView.layer.cornerRadius = 4.0
        
        contentView.backgroundColor = .lightGray
    }

}
