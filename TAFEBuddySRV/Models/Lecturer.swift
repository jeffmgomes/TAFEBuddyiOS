//
//  Lecturer.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 17/3/20.
//  Copyright © 2020 Jefferson Gomes. All rights reserved.
//

import Foundation

class Lecturer: NSObject {
    
    // Properties
    var LecturerId: String
    var GivenName: String
    var LastName: String
    var Email: String
    
    
    // Construtor
    init(lecturerId: String?, givenName: String?, lastName: String?, email: String?)
    {
        self.LecturerId = lecturerId ?? "00000000"
        self.GivenName = givenName ?? "No Given name"
        self.LastName = lastName ?? "No Last Name"
        self.Email = email ?? "No Email"
    }
    
    override var description: String
    {
        return "\(GivenName) \(LastName)"
    }
}
