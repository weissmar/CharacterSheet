//
//  Party.swift
//  characterSheet
//
//  Created by Rachel Weissman-Hohler on 8/12/16.
//  Copyright © 2016 Rachel Weissman-Hohler. All rights reserved.
//

import UIKit

class Party {
    // MARK: Properties
    var name: String
    var id: String
    var startDate: String?
    var meetingDay: String?
    var meetingTime: String?
    
    // Mark: Initializer
    init?(name: String, id: String, startDate: String?, meetingDay: String?, meetingTime: String?) {
        // initialize properties to passed-in values
        self.name = name
        self.id = id
        self.startDate = startDate
        self.meetingDay = meetingDay
        self.meetingTime = meetingTime
        
        // check for empty name and empty id
        if name.isEmpty || id.isEmpty {
            return nil
        }
    }
}