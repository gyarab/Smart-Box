//
//  Box.swift
//  SmartBox
//
//  Created by Vlada on 08/01/2020.
//  Copyright © 2020 Vlada. All rights reserved.
//

import Foundation

struct Box: Codable {
    let id: Int
    let lattitude: Double
    let longtitude: Double
    var locked: Bool
    var name: String
    let current_owner: Int?
}

struct Stav: Codable {
    let uspesne: String
}
