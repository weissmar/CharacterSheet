//
//  ViewController.swift
//  characterSheet
//
//  Created by Rachel Weissman-Hohler on 8/11/16.
//  Copyright © 2016 Rachel Weissman-Hohler. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    var userToken: String?
    var partyID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: API GET Call: Get Party Details
    func getPartyDetails(complete: (success: Bool, party: Party?) -> ()) {
        let myURL = "https://abstract-key-135222.appspot.com/parties/" + partyID!
        let request = NSMutableURLRequest(URL: NSURL(string: myURL)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary
                if let parsedData = json {
                    let parsedName = parsedData["name"] as! String
                    let parsedId = parsedData["urlsafeKey"] as! String
                    let parsedStartDate = parsedData["startDate"] as? String
                    let parsedMeetingDay = parsedData["meetingDay"] as? String
                    let parsedMeetingTime = parsedData["meetingTime"] as? String
                    let newParty = Party(name: parsedName, id: parsedId, startDate: parsedStartDate, meetingDay: parsedMeetingDay, meetingTime: parsedMeetingTime)
                    complete(success: true, party: newParty)
                } else {
                    complete(success: false, party: nil)
                }
            } catch {
                print(error)
                print("Error: couldn't parse json:")
                let stringData = String(response)
                print(stringData)
                complete(success: false, party: nil)
            }
        })
        task.resume()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if partyID != nil {
            getPartyDetails() { (success: Bool, party: Party?) -> () in
                if success {
                    if party != nil {
                        let navView = segue.destinationViewController as! UINavigationController
                        let destinationView = navView.topViewController as! PartyViewController
                        destinationView.currParty = party
                        destinationView.userToken = self.userToken
                    }
                } else {
                    print("Call to API to retrieve party details failed.")
                }
            }
        } else {
            let navView = segue.destinationViewController as! UINavigationController
            let destinationView = navView.topViewController as! EditPartyViewController
            destinationView.userToken = self.userToken
        }
    }
    
    @IBAction func unwindToSignIn(sender: UIStoryboardSegue) {
        if sender.sourceViewController is EditPartyViewController {
            self.performSegueWithIdentifier("existingPartySegue", sender: self)
        }
    }
    
    @IBAction func unwindToSignInSignedOut(sender: UIStoryboardSegue) {
    }
}

