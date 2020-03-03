//
//  User.swift
//  SmartBox
//
//  Created by Vlada on 08/01/2020.
//  Copyright © 2020 Vlada. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: Int
    var name: String
    var email: String
    var password: String?
    var Boxes: [Box]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case password
        case Boxes
    }
}

struct RegisterUser: Codable {
    let name: String
    let email: String
    let id: Int
}

struct Token: Codable {
    let auth_token: String
}
