//
//  Box.swift
//  SmartBox
//
//  Created by Vlada on 08/01/2020.
//  Copyright © 2020 Vlada. All rights reserved.
//

import Foundation

struct Box: Codable {
    var possition: Possition
    var locked: Bool
    var name: String
    let id: Int
}

struct Possition: Codable {
    var lattitude: Float
    var longtitude: Float
}
