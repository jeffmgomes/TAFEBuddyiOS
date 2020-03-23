//
//  Student.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 13/9/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

protocol StudentProtocol: class {
    func itemsDownloaded(items: [Student])
}

protocol StudentQualifications: class {
    func itemsDownloaded()
}

struct Result {
    var coreComplete: Int = 0
    var electiveComplete: Int = 0
    var listElectiveComplete: Int = 0
    
    func getTotalUnits() -> Int
    {
        return coreComplete + electiveComplete + listElectiveComplete
    }
    
    func getTotalPercent(totalUnits: Int) -> Double
    {
        return Double(Double(getTotalUnits()) / Double(totalUnits))
    }
    
}

class Student: NSObject, URLSessionDataDelegate {
    
    // Properties
    var StudentId: String
    var GivenName: String
    var LastName: String
    var Email: String
    
    var qualifications: [Qualification]! = []
    
    var competencyList: [String: [Competence]]! = [:]
    
    var results: [String: Result]! = [:]

    
    // Delegate
    var delegate: StudentProtocol!
    var qualificationsDelegate: StudentQualifications!
    
    // Webservice URL
    let baseUrl: String = "https://tafebuddy.azurewebsites.net/students"
    
    // Construtor
    init(studentId: String?, givenName: String?, lastName: String?, email: String?)
    {
        self.StudentId = studentId ?? "00000000"
        self.GivenName = givenName ?? "No Given name"
        self.LastName = lastName ?? "No Last Name"
        self.Email = email ?? "No Email"
    }
    
    override var description: String
    {
        return "\(GivenName) \(LastName)"
    }
    
    func getStudents()
    {
        let url = baseUrl
        var students: [Student] = []
        
        request(url: url, method: "GET", parameters: nil) { (json, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let json = json else {
                print("No Json response")
                return
            }
            
            for item in json {
                guard let student = self.parseStudent(item: item) else {
                    return
                }
                students.append(student)
            }
            
            DispatchQueue.main.async { self.delegate.itemsDownloaded(items: students) }
        }
    }
    
    func getStudentQualifications()
    {
        let url = baseUrl + "/\(StudentId)/qualifications"
        
        request(url: url, method: "GET", parameters: nil) { (json, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let json = json else {
                print("No Json response")
                return
            }
            
            for item in json {
                guard let qual = self.parseQualification(item: item) else {
                    return
                }
                self.qualifications.append(qual)
            }
            
            self.getResults()
            //DispatchQueue.main.async { self.qualificationsDelegate.itemsDownloaded() }
        }
        
    }
    
    func getResults()
    {
        let url = baseUrl + "/\(StudentId)/results"
        
        request(url: url, method: "GET", parameters: nil) { (json, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let json = json else {
                print("No Json response")
                return
            }
            
            for item in json {
                for key in item.keys {
                    self.competencyList[key] = []
                    for comp in item[key] as! [[String: Any]] {
                        self.competencyList[key]?.append(self.parseCompetence(item: comp))
                    }
                }
            }
            
            self.checkResults()
            DispatchQueue.main.async { self.qualificationsDelegate.itemsDownloaded() }
        }
    }
    
    func request(url: String, method: String, parameters: [String: Any]?, completion: @escaping ([[String: Any]]?, Error?) -> Void)
    {
        // Get the token
        var accessToken: String!
        let auth = AuthenticationHelper()
        auth.ObtainToken { (token, error) in
            guard error == nil else {
                completion(nil,error)
                return
            }
            
            accessToken = token
            
            var httpMethod: HTTPMethod
            switch method  {
            case "POST":
                httpMethod = .post
            default:
                httpMethod = .get
            }
            
            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization": accessToken
            ]
            
            AF.request(url,
                       method: httpMethod,
                       parameters: parameters,
                       headers: headers)
            .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        guard let value = response.value as? [[String: Any]] else {
                            print("Error converting JSON")
                            completion(nil, response.error)
                            return
                        }
                        
                        completion(value,nil)
                        
                    case let .failure(error):
                        print("Erro getting token \(error)")
                        completion(nil,error)
                    }
            }
        }
    }
    
    func parseStudent(item: [String: Any]) -> Student?
    {
        guard let studentId = item["StudentID"] as? String,
        let givenName = item["GivenName"] as? String,
        let lastName = item["LastName"] as? String,
        let email = item["EmailAddress"] as? String else {
                return nil
        }
        
        let student = Student(studentId: studentId, givenName: givenName, lastName: lastName, email: email)
        return student
    }
    
    func parseQualification(item: [String: Any]) -> Qualification?
    {
        guard let qualCode = item["QualCode"] as? String,
        let nationalCode = item["NationalQualCode"] as? String,
        let tafeQualCode = item["TafeQualCode"] as? String,
        let qualName = item["QualName"] as? String,
        let totalUnits = item["TotalUnits"] as? Int,
        let coreUnits = item["CoreUnits"] as? Int,
        let electedUnits = item["ElectedUnits"] as? Int,
            let reqListedElectedUnits = item["ReqListedElectedUnits"] as? Int else {
                return nil
        }
        
        let qual = Qualification(qualCode: qualCode, nationalCode: nationalCode, tafeQualCode: tafeQualCode, qualName: qualName, totalUnits: totalUnits, coreUnits: coreUnits, electedUnits: electedUnits, reqListedElectedUnits: reqListedElectedUnits)
        
        return qual
    }
    
    func parseCompetence(item: [String: Any]) -> Competence!
    {
        let crn = item["CRN"] as? String
        let tafeCompCode = item["TafeCompCode"] as? String
        let termCode = item["TermCode"] as? Int
        let termYear = item["TermYear"] as? Int
        let grade = item["Grade"] as? String
        let gradeDate = item["GradeDate"] as? String
        let subjectCode = item["SubjectCode"] as? String
        let nationalCompCode = item["NationalCompCode"] as? String
        let compTypeCode = item["CompTypeCode"] as? String
        let competencyName = item["CompetencyName"] as? String
        
        let comp = Competence(crn: crn, tafeCompCode: tafeCompCode, termCode: termCode, termYear: termYear, grade: grade, gradeDate: gradeDate, subjectCode: subjectCode, nationalCompCode: nationalCompCode, compTypeCode: compTypeCode, competencyName: competencyName)
        
        return comp
    }
    
    func checkResults()
    {
        for qual in self.qualifications {
            var result = Result()
            for comp in self.competencyList[qual.QualCode]! {
                if comp.CompTypeCode == "C" && comp.Grade == "PA" {
                    result.coreComplete += 1
                }
                if comp.CompTypeCode == "E" && comp.Grade == "PA" {
                    result.electiveComplete += 1
                }
                if (comp.CompTypeCode != "C" && comp.CompTypeCode != "E") && comp.Grade == "PA" {
                    result.listElectiveComplete += 1
                }
            }
            
            self.results[qual.QualCode] = result
        }
    }
}
