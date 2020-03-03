//
//  Box.swift
//  SmartBox
//
//  Created by Vlada on 08/01/2020.
//  Copyright © 2020 Vlada. All rights reserved.
//

import Foundation

struct Box: Codable {
    var lattitude: Float
    var longtitude: Float
    var locked: Bool
    var name: String
    let id: Int
    let curren_owner: Int?
}
