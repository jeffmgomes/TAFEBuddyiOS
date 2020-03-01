//
//  CompetenceDetailViewController.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 28/2/20.
//  Copyright © 2020 Jefferson Gomes. All rights reserved.
//

import UIKit

class CompetenceDetailViewController: UIViewController {

    @IBOutlet weak var competenceTitleLabel: UILabel!
    @IBOutlet weak var competenceDescriptionLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!

    
    var competenceTitle: String!
    var competenceDescription: String!
    var result: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        competenceTitleLabel.text = competenceTitle
        competenceDescriptionLabel.text = competenceDescription
        resultLabel.text = result
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
