//
//  Qualification.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 4/10/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//
import Foundation
import Alamofire

protocol SubjectSuggestions {
    func SuggestionsLoaded(items: [Subject])
}

class Qualification: NSObject, URLSessionDelegate {
    
    // Properties
    var QualCode: String
    var NationalQualCode: String
    var TafeQualCode: String
    var QualName: String
    var TotalUnits: Int
    var CoreUnits: Int
    var ElectedUnits: Int
    var ReqListedElectedUnits: Int
    
    // Delegate
    var suggestionsDelegate: SubjectSuggestions!
    
    // Webservice URl
    let baseURL: String = "https://tafebuddy.azurewebsites.net/qualifications"
    
    // Constructor
    init(qualCode: String?, nationalCode: String?, tafeQualCode: String?, qualName: String?, totalUnits: Int?, coreUnits: Int?, electedUnits: Int?, reqListedElectedUnits: Int?)
    {
        self.QualCode = qualCode ?? ""
        self.NationalQualCode = nationalCode ?? ""
        self.TafeQualCode = tafeQualCode ?? ""
        self.QualName = qualName ?? ""
        self.TotalUnits = totalUnits ?? 0
        self.CoreUnits = coreUnits ?? 0
        self.ElectedUnits = electedUnits ?? 0
        self.ReqListedElectedUnits = reqListedElectedUnits ?? 0
        
    }
    
    func getAll() -> [Qualification] {
        var qualifications: [Qualification] = []
        let url = baseURL
        request(url: url, method: "GET", parameters: nil) { jsonResponse, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let jsonResponse = jsonResponse else {
                print("No json response")
                return
            }
            
            for items in jsonResponse {
                qualifications.append(Qualification(qualCode: items["QualCode"] as? String, nationalCode: items["NationalQualCode"] as? String, tafeQualCode: items["TafeQualCode"] as? String, qualName: items["QualName"] as? String, totalUnits: items["TotalUnits"] as? Int, coreUnits: items["CoreUnits"] as? Int, electedUnits: items["ElectedUnits"] as? Int, reqListedElectedUnits: items["ReqListedElectedUnits"] as? Int))
            }
        }
        return qualifications
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
    
    func getSuggetions(tafeCompCode: String){
        var subjects: [Subject] = []
        let url = "\(baseURL)/\(QualCode)/subjectsuggestions/\(tafeCompCode)"
        
        request(url: url, method: "GET", parameters: nil) { jsonResponse, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let jsonResponse = jsonResponse else {
                print("No json response")
                return
            }
            
            for items in jsonResponse {
                subjects.append(Subject(subjectCode: items["SubjectCode"] as? String, subjectDescription: items["SubjectDescription"] as? String, tafeCompCode: items["TafeCompCode"] as? String, subjectUsageType: items["UsageType"] as? String, qualCode: items["QualCode"] as? String))
            }
            // Dispatch to the main queue delegate
            DispatchQueue.main.async { self.suggestionsDelegate.SuggestionsLoaded(items: subjects)}
        }
    }

}
