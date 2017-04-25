//
//  PartyViewController.swift
//  characterSheet
//
//  Created by Rachel Weissman-Hohler on 8/12/16.
//  Copyright © 2016 Rachel Weissman-Hohler. All rights reserved.
//

import UIKit

class PartyViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var meetingDayLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    var currParty: Party?
    var userToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateLabels()
    }

    func updateLabels(){
        if currParty != nil {
            navigationItem.title = currParty?.name
            meetingDayLabel.text = currParty?.meetingDay
            meetingTimeLabel.text = currParty?.meetingTime
            startDateLabel.text = currParty?.startDate
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
            let destinationView = navView.topViewController as! EditPartyViewController
            destinationView.userToken = self.userToken
            destinationView.party = self.currParty
        } else if segue.identifier == "embedPartyMembersSegue" {
            let navViewEmbed = segue.destinationViewController as! UINavigationController
            let destinationViewEmbed = navViewEmbed.topViewController as! CharacterTableViewController
            destinationViewEmbed.userToken = userToken
            destinationViewEmbed.partyID = currParty?.id
        }
    }
    
    @IBAction func unwindToPartyView(sender: UIStoryboardSegue) {
        if sender.sourceViewController is EditPartyViewController {
            self.updateLabels()
        }
    }

    @IBAction func signOut(sender: UIBarButtonItem) {
        GIDSignIn.sharedInstance().signOut()
        self.performSegueWithIdentifier("backToSignInSegue", sender: self)
    }
}
