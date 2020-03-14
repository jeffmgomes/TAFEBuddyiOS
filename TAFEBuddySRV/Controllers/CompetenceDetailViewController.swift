//
//  CompetenceDetailViewController.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 28/2/20.
//  Copyright © 2020 Jefferson Gomes. All rights reserved.
//

import UIKit
import MBProgressHUD

class CompetenceDetailViewController: UIViewController {

    @IBOutlet weak var competenceTitleLabel: UILabel!
    @IBOutlet weak var competenceDescriptionLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var suggestionsCollectionView: UICollectionView!
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var subjectTitleLabel: UILabel!
    @IBOutlet weak var subjectSuggestionTitleLabel: UILabel!
    
    var competence: Competence!
    var qualification: Qualification!
    var subjects: [Subject]!
    
    let suggestionCellHeight: CGFloat = 86.0
    let suggestionCellInset: CGFloat = 8.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subjects = [] // Always starts with empty subjects suggestions
        
        // Do any additional setup after loading the view.
        if competence.Grade == "PA" {
                topImageView.image = UIImage(named: "success")
        } else {
                topImageView.image = UIImage(named: "warning")
        }
        
        // Set the delegate for the qualification
        qualification.suggestionsDelegate = self
        
        competenceTitleLabel.text = competence.NationalCompCode
        competenceDescriptionLabel.text = competence.CompetencyName
        
        if competence.SubjectCode == "" {
            resultTitleLabel.removeFromSuperview()
            resultLabel.removeFromSuperview()
            subjectTitleLabel.removeFromSuperview()
            subjectLabel.removeFromSuperview()

            
            commentsLabel.topAnchor.constraint(equalTo: competenceDescriptionLabel.bottomAnchor, constant: 50).isActive = true
            
            commentsLabel.text = "It seems you are not enrolled in a subject that has this competence. See suggestions."
            // Request the API the suggestions
            showLoadingHUD()
            qualification.getSuggetions(tafeCompCode: competence.TafeCompCode)
        } else {
            subjectLabel.text = competence.SubjectCode
            resultLabel.text = competence.Grade
            subjectSuggestionTitleLabel.isHidden = true
            suggestionsCollectionView.isHidden = true
            if competence.Grade != "PA"  && competence.Grade != "" {
                commentsLabel.text = "Sorry, you don't have a pass grade for this competence."
            } else {
                commentsLabel.text = "Well done!"
            }
        }

    }
    
    @IBAction func swipeDownGetures(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    private func showLoadingHUD() {
        MBProgressHUD.showAdded(to: suggestionsCollectionView, animated: true)
    }

    private func hideLoadingHUD() {
        MBProgressHUD.hide(for: suggestionsCollectionView, animated: true)
    }

}

extension CompetenceDetailViewController: SubjectSuggestions {
    func SuggestionsLoaded(items: [Subject]) {
        self.subjects = items
        self.suggestionsCollectionView.reloadData()
        hideLoadingHUD()
    }
    
}

extension CompetenceDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestionCell", for: indexPath) as! SuggestionCollectionViewCell
        
        cell.subject = subjects[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat
        if subjects.count > 1 {
            width = (suggestionsCollectionView.frame.width - 20) - (suggestionCellInset * 2)
        } else {
            width = suggestionsCollectionView.frame.width - (suggestionCellInset * 2)
        }
        let height = suggestionCellHeight
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: suggestionCellInset, left: suggestionCellInset, bottom: suggestionCellInset, right: suggestionCellInset)
    }
    
}
