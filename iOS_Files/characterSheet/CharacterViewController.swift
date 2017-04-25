//
//  CharacterViewController.swift
//  characterSheet
//
//  Created by Rachel Weissman-Hohler on 8/12/16.
//  Copyright © 2016 Rachel Weissman-Hohler. All rights reserved.
//

import UIKit

class CharacterViewController: UIViewController {
    
    // MARK: Properties
    var userToken: String?
    var character: Character?
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var imageViewMed: UIImageView!
    @IBOutlet weak var xpLabel: UILabel!
    @IBOutlet weak var strLabel: UILabel!
    @IBOutlet weak var iqLabel: UILabel!
    @IBOutlet weak var dexLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateLabels()
    }
    
    func updateLabels(){
        if character != nil {
            navigationItem.title = character?.name
            xpLabel.text = String(character!.XP!)
            iqLabel.text = String(character!.IQ!)
            strLabel.text = String(character!.STR!)
            dexLabel.text = String(character!.DEX!)
            if character?.charImage != nil {
                imageViewMed.image = character!.charImage!
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if editButton === sender {
            let navView = segue.destinationViewController as! UINavigationController
            let destinationView = navView.topViewController as! EditCharacterViewController
            destinationView.userToken = self.userToken
            destinationView.character = self.character
        } else if segue.identifier == "inventoryEmbedSegue" {
            //let navViewEmbed = segue.destinationViewController as! UINavigationController
            //let destinationViewEmbed = navViewEmbed.topViewController as! CharacterTableViewController
            //destinationViewEmbed.userToken = userToken
            //destinationViewEmbed.partyID = currParty?.id
        }
    }
 
    @IBAction func unwindToCharacterView(sender: UIStoryboardSegue) {
        if sender.sourceViewController is EditCharacterViewController {
            self.updateLabels()
        }
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
