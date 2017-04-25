//
//  Item.swift
//  characterSheet
//
//  Created by Rachel Weissman-Hohler on 8/12/16.
//  Copyright © 2016 Rachel Weissman-Hohler. All rights reserved.
//

import UIKit

class Item {
    // MARK: Properties
    var name: String
    var id: String
    var weight: Double?
    var value: Double?
    
    // Mark: Initializer
    init?(name: String, id: String, weight: Double?, value: Double?) {
        // initialize properties to passed-in values
        self.name = name
        self.id = id
        self.weight = weight
        self.value = value
        
        // check for empty name and empty id
        if name.isEmpty || id.isEmpty {
            return nil
        }
    }
}