//
//  WelcomeViewController.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 6/9/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    var student: Student!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarController = self.tabBarController as? TabBarViewController {
            self.student = tabBarController.student
        }
       
        logoutButton.layer.cornerRadius = 4.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (student != nil) {
            welcomeLabel.text = "\(student.description)"
        }
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
