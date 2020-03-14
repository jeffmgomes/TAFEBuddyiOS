//
//  Subject.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 12/3/20.
//  Copyright © 2020 Jefferson Gomes. All rights reserved.
//

import Foundation

class Subject: NSObject {
    
    // Properties
    var subjectCode: String
    var subjectDescription: String
    var tafeCompCode: String
    var subjectUsageType: String
    var qualCode: String
    
    // Constructor
    init(subjectCode: String?, subjectDescription: String?, tafeCompCode: String?, subjectUsageType: String?, qualCode: String?)
    {
        self.subjectCode = subjectCode ?? ""
        self.subjectDescription = subjectDescription ?? ""
        self.tafeCompCode = tafeCompCode ?? ""
        self.subjectUsageType = subjectUsageType ?? ""
        self.qualCode = qualCode ?? ""
    }
}
