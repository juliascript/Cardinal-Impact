//
//  UserModel.swift
//  Cardinal-Wizards
//
//  Created by Julia Geist on 10/3/17.
//  Copyright © 2017 Julia Geist. All rights reserved.
//

import Foundation

enum StudentType: String {
    case wizard = "wizard"
    case newcomer = "student"
}

struct User: Codable {
    var name: String
    let uid: String
    var email: String
    var type: String
    var state: String 
    var latitude: Double 
    var longitude: Double
    var profile: Data
    
//    let image: Data?
//    let major: String?
//    let year: Int?
//    let interests: [String]?
}
