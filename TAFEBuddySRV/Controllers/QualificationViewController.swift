//
//  QualificationViewController.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 6/9/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import UIKit
import MBProgressHUD

class QualificationViewController: UITableViewController {
    
    var student: Student!
    
    @IBOutlet weak var progress: CircularProgressBar!
    @IBOutlet weak var contentView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarController = self.tabBarController as? TabBarViewController {
            if self.student == nil {
                self.student = tabBarController.student
            } else {
                let myTitleNavBar: UILabel = UILabel()
                myTitleNavBar.text = "\(self.student.GivenName) \(self.student.LastName)"
                myTitleNavBar.font = UIFont(name: "AvenirNext-DemiBold", size: 17)!
                myTitleNavBar.adjustsFontSizeToFitWidth = true
                
                self.navigationItem.titleView = myTitleNavBar
            }
        }
        
        if self.student.qualifications.count == 0 {
            student.qualificationsDelegate = self
            showLoadingHUD()
            student.getStudentQualifications()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return student.qualifications.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QualificationCell.identifier, for: indexPath) as! QualificationCell

        // Configure the cell...
        let qualification: Qualification = student.qualifications[indexPath.row]
        cell.titleLabel.text = qualification.QualName
        let progress = student.results[qualification.QualCode]?.getTotalPercent(totalUnits: qualification.TotalUnits)
        cell.progressBar.setProgress(to: progress ?? 0.0, withAnimation: true)

        return cell
    }
 
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "qualDetail" {
            let controller = segue.destination as! DetailViewController
            if let cell = sender as? QualificationCell,
                let indexPath = tableView.indexPath(for: cell) {
                let qualification = student.qualifications[indexPath.row]
                controller.qualification = qualification
                controller.result = student.results[qualification.QualCode]
                controller.competences = student.competencyList[qualification.QualCode]
                controller.student = student
            }
        }
    }
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showAdded(to: contentView, animated: true)
      hud.label.text = "Loading..."
    }

    private func hideLoadingHUD() {
      MBProgressHUD.hide(for: contentView, animated: true)
    }

}

extension QualificationViewController: StudentQualifications{
    func itemsDownloaded() {
        self.hideLoadingHUD()
        self.tableView.reloadData()
    }
}
