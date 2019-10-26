//
//  Competence.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 26/10/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import Foundation

class Competence: NSObject {
    
    //Properties
    var CRN: String
    var TafeCompCode: String
    var TermCode: Int
    var TermYear: Int
    var Grade: String
    var GradeDate: String
    var SubjectCode: String
    var NationalCompCode: String
    var CompTypeCode: String
    var CompetencyName: String
    
    // Constructor
    init(crn: String?, tafeCompCode: String?, termCode: Int? , termYear: Int?, grade: String?, gradeDate: String?, subjectCode: String?, nationalCompCode: String?, compTypeCode: String?, competencyName: String?)
    {
        self.CRN = crn ?? ""
        self.TafeCompCode = tafeCompCode ?? ""
        self.TermCode = termCode ?? 0
        self.TermYear = termYear ?? 0
        self.Grade = grade ?? ""
        self.GradeDate = gradeDate ?? ""
        self.SubjectCode = subjectCode ?? ""
        self.NationalCompCode = nationalCompCode ?? ""
        self.CompTypeCode = compTypeCode ?? ""
        self.CompetencyName = competencyName ?? ""        
    }
    
    
}
