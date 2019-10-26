//
//  DetailViewController.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 26/10/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var circularProgressBar: CircularProgressBar!
    @IBOutlet weak var coreLabel: UILabel!
    @IBOutlet weak var electivesLabel: UILabel!
    @IBOutlet weak var listedElectiveLabel: UILabel!
    @IBOutlet weak var coreProgress: UIProgressView!
    @IBOutlet weak var electiveProgress: UIProgressView!
    @IBOutlet weak var listedElectiveProgress: UIProgressView!
    
    var qualification: Qualification!
    var result: Result!
    var competences: [Competence]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Initialization code
        // Set up Progress bar
        circularProgressBar.labelSize = 30
        circularProgressBar.lineWidth = 4
        circularProgressBar.setProgress(to: result.getTotalPercent(totalUnits: qualification.TotalUnits), withAnimation: true)
        
        coreLabel.text = "Core: \(result.coreComplete) of \(qualification.CoreUnits)"
        coreProgress.setProgress(Float(Float(result.coreComplete) / Float(qualification.CoreUnits)), animated: true)
        
        electivesLabel.text = "Elective: \(result.electiveComplete) of \(qualification.ElectedUnits)"
        electiveProgress.setProgress(Float(Float(result.electiveComplete) / Float(qualification.ElectedUnits)), animated: true)
        
        listedElectiveLabel.text = "Listed Electives: \(result.listElectiveComplete) of \(qualification.ReqListedElectedUnits)"
        listedElectiveProgress.setProgress(Float(Float(result.listElectiveComplete) / Float(qualification.ReqListedElectedUnits)), animated: true)
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
