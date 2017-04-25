//
//  CharacterTableViewCell.swift
//  characterSheet
//
//  Created by Rachel Weissman-Hohler on 8/12/16.
//  Copyright © 2016 Rachel Weissman-Hohler. All rights reserved.
//

import UIKit

class CharacterTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var imageViewSm: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
