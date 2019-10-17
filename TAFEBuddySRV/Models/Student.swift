//
//  Student.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 13/9/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import UIKit
import Foundation

protocol StudentProtocol: class {
    func itemsDownloaded(items: NSArray)
}

protocol StudentQualifications: class {
    func itemsDownloaded(items: [[String: Any]])
}

class Student: NSObject, URLSessionDataDelegate {
    
    // Properties
    var StudentId: String
    var GivenName: String
    var LastName: String
    var Email: String

    
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
    
    func getStudentQualifications()
    {
        var qualifications: [[String: Any]] = []
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
                qualifications.append(item)
            }
            
            DispatchQueue.main.async {                self.qualificationsDelegate.itemsDownloaded(items: qualifications)
            }
        }
        
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
    
    func parseJSON(_ data: Data){
        var jsonArray = NSArray()
        let result = NSMutableArray()
        
        do{
            jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
            
            var jsonElement = NSDictionary()
            
            for i in 0 ..< jsonArray.count {
                jsonElement = jsonArray[i] as! NSDictionary
                result.add(jsonElement)
            }
            
        } catch let error as NSError{
            print(error)
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.itemsDownloaded(items: result)
        })
    }

}
