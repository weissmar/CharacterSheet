//
//  CharacterImage.swift
//  characterSheet
//
//  Created by Rachel Weissman-Hohler on 8/12/16.
//  Copyright © 2016 Rachel Weissman-Hohler. All rights reserved.
//

import UIKit

class CharacterImage: NSObject, NSCoding {
    // MARK: Properties
    var id: String
    var charImage: UIImage?
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("characterImages")
    
    // MARK: Types
    struct PropertyKey {
        static let idKey = "id"
        static let imageKey = "charImage"
    }
    
    // Mark: Initializer
    init?(id: String, charImage: UIImage?) {
        // initialize properties to passed-in values
        self.id = id
        self.charImage = charImage
        
        super.init()
        
        // check for empty name and empty id
        if id.isEmpty {
            return nil
        }
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: PropertyKey.idKey)
        aCoder.encodeObject(charImage, forKey: PropertyKey.imageKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObjectForKey(PropertyKey.idKey) as! String
        let charImage = aDecoder.decodeObjectForKey(PropertyKey.imageKey) as? UIImage
        
        self.init(id: id, charImage: charImage)
    }
}
