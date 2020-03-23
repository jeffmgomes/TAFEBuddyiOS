//
//  TabBarViewController.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 5/10/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    var student: Student!
    var lecturer: Lecturer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("I passed through the prepare in the Tab")
    }

}
