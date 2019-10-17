//
//  Qualification.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 4/10/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//
import Foundation

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
        //Create the session object
        let session = URLSession(configuration: .default)
        //Now create the URLRequest object using the url object
        var request = URLRequest(url: URL(string: url)!)
        //Set http method
        request.httpMethod = method
        
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
                return
            }
            
            // Add the headers
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let task = session.dataTask(with: request) { data, res, error in
            guard let data = data,
                let res = res as? HTTPURLResponse,
                error == nil else {
                    completion(nil,error)
                    return
            }
            
            guard 200 ... 299 ~= res.statusCode else {
                completion(nil,error)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                    completion(json,nil)
                }
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    func parseJSON(json: [String: Any])
    {
        
    }

}
