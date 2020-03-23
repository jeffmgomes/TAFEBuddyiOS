//
//  DetailViewController.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 26/10/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import UIKit
import MBProgressHUD

struct Section {
    var name: String
    var items: [Competence]
}

class DetailViewController: UIViewController {

    @IBOutlet weak var circularProgressBar: CircularProgressBar!
    @IBOutlet weak var coreLabel: UILabel!
    @IBOutlet weak var electivesLabel: UILabel!
    @IBOutlet weak var listedElectiveLabel: UILabel!
    @IBOutlet weak var coreProgress: UIProgressView!
    @IBOutlet weak var electiveProgress: UIProgressView!
    @IBOutlet weak var listedElectiveProgress: UIProgressView!
    @IBOutlet weak var requestParchmentButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var qualification: Qualification!
    var result: Result!
    var competences: [Competence]!
    var student: Student!
    
    var sections: [Section]! = []
    
    let competenceCellHeight: CGFloat = 86.0
    let competenceCellInset: CGFloat = 8.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Initialization code
        // Set navigation bar title
        
        let myTitleNavBar: UILabel = UILabel()
        myTitleNavBar.text = qualification.QualName
        myTitleNavBar.font = UIFont(name: "AvenirNext-DemiBold", size: 17)!
        myTitleNavBar.adjustsFontSizeToFitWidth = true
        
        self.navigationItem.titleView = myTitleNavBar
        
        var showSpareCompentences: Bool = true
        
        // Set up Progress bar
        circularProgressBar.labelSize = 30
        circularProgressBar.lineWidth = 4
        let percentage = result.getTotalPercent(totalUnits: qualification.TotalUnits)
        circularProgressBar.setProgress(to: percentage, withAnimation: true)
        
        coreLabel.text = "Core: \(result.coreComplete) of \(qualification.CoreUnits)"
        coreProgress.setProgress(Float(Float(result.coreComplete) / Float(qualification.CoreUnits)), animated: true)
        
        electivesLabel.text = "Elective: \(result.electiveComplete) of \(qualification.ElectedUnits)"
        electiveProgress.setProgress(Float(Float(result.electiveComplete) / Float(qualification.ElectedUnits)), animated: true)
        
        listedElectiveLabel.text = "Listed Electives: \(result.listElectiveComplete) of \(qualification.ReqListedElectedUnits)"
        listedElectiveProgress.setProgress(Float(Float(result.listElectiveComplete) / Float(qualification.ReqListedElectedUnits)), animated: true)
        
        if (coreProgress.progress + electiveProgress.progress + listedElectiveProgress.progress) == 3.0 {
            showSpareCompentences = false
        }
        
        
        // Map the competences
        let coreComp: [Competence]
        let electivesComp: [Competence]
        let listedElectComp: [Competence]
        
        if showSpareCompentences {
            coreComp = self.competences.filter({$0.CompTypeCode == "C"})
            electivesComp = self.competences.filter({$0.CompTypeCode == "E"})
            listedElectComp = self.competences.filter({$0.CompTypeCode != "C" && $0.CompTypeCode != "E"})
        } else {
            coreComp = self.competences.filter({$0.CompTypeCode == "C" && $0.Grade != ""})
            electivesComp = self.competences.filter({$0.CompTypeCode == "E" && $0.Grade != ""})
            listedElectComp = self.competences.filter({$0.CompTypeCode != "C" && $0.CompTypeCode != "E" && $0.Grade != ""})
        }
        if coreComp.count > 0 {
            self.sections.append(Section.init(name: "Core", items: coreComp))
        }
        
        if electivesComp.count > 0 {
            self.sections.append(Section.init(name: "Elective", items: electivesComp))
        }
        
        if listedElectComp.count > 0 {
            self.sections.append(Section.init(name: "Listed Electives", items: listedElectComp))
        }
        
        requestParchmentButton.layer.cornerRadius = 5
        
        // Enable Request Parchment Button
        if (percentage == 1) {
            requestParchmentButton.isEnabled = true
        } else {
            requestParchmentButton.isEnabled = false
            requestParchmentButton.backgroundColor = .lightGray
        }

    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "competenceDetail" {
            let controller = segue.destination as! CompetenceDetailViewController
            if let cell = sender as? CompCollectionViewCell,
                let indexPath = collectionView.indexPath(for: cell) {
                let competence = sections[indexPath.section].items[indexPath.row]
                controller.competence = competence
                controller.qualification = qualification
            }
        }
        
        if segue.identifier == "parchmentView" {
            let controller = segue.destination as! ParchmentViewController
            controller.student = self.student
            controller.qualification = self.qualification
        }
    }
    
    @IBAction func approveParchmentTapped(_ sender: Any) {
        showToast(title: "Parchment Approved", message: "Parchment successfully approved")
    }
    
    // Toast
    func showToast(title: String, message: String){
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true,completion: nil)
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "competenceCell", for: indexPath) as! CompCollectionViewCell

        let section = self.sections[indexPath.section] // First get the section
        let item = section.items[indexPath.row] // Then get item inside that section
        
        cell.competence = item
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as! HeaderCollectionReusableView

        headerView.headerLabel.text = self.sections[indexPath.section].name

        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - (competenceCellInset * 2)
        let height = competenceCellHeight
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: competenceCellInset, left: competenceCellInset, bottom: competenceCellInset, right: competenceCellInset)
    }
    
}
