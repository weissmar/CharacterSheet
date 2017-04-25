//
//  Character.swift
//  characterSheet
//
//  Created by Rachel Weissman-Hohler on 8/12/16.
//  Copyright © 2016 Rachel Weissman-Hohler. All rights reserved.
//

import UIKit

class Character {
    // MARK: Properties
    var name: String
    var id: String
    var XP: Int?
    var IQ: Int?
    var STR: Int?
    var DEX: Int?
    var charImage: UIImage?
    var inventory: [Item]?
    
    // Mark: Initializer
    init?(name: String, id: String, XP: Int?, IQ: Int?, STR: Int?, DEX: Int?) {
        // initialize properties to passed-in values
        self.name = name
        self.id = id
        self.XP = XP
        self.IQ = IQ
        self.STR = STR
        self.DEX = DEX
        
        // check for empty name and empty id
        if name.isEmpty || id.isEmpty {
            return nil
        }
    }
}
