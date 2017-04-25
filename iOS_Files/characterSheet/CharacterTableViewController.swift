//
//  CharacterTableViewController.swift
//  characterSheet
//
//  Created by Rachel Weissman-Hohler on 8/12/16.
//  Copyright © 2016 Rachel Weissman-Hohler. All rights reserved.
//

import UIKit

class CharacterTableViewController: UITableViewController {
    
    // MARK: Properties
    var characters = [Character]()
    var characterImages = [CharacterImage]()
    var userToken: String?
    var partyID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem()
        
        loadCharacterData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "characterCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CharacterTableViewCell
        let character = characters[indexPath.row]

        cell.nameLabel.text = character.name
        if character.charImage != nil {
            cell.imageViewSm.image = character.charImage
        }

        return cell
    }

    // MARK: API GET Call: Get list of Party Members
    func getListMembers(complete: (success: Bool, keys: [String]?) -> ()) {
        let myURL = "https://abstract-key-135222.appspot.com/parties/" + partyID! + "/characters"
        let request = NSMutableURLRequest(URL: NSURL(string: myURL)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary
                if let parsedData = json {
                    let parsedKeys = parsedData["keys"] as? [String]
                    complete(success: true, keys: parsedKeys)
                } else {
                    complete(success: false, keys: nil)
                }
            } catch {
                print(error)
                print("Error: couldn't parse json:")
                let stringData = String(response)
                print(stringData)
                complete(success: false, keys: nil)
            }
        })
        task.resume()
    }
    
    // MARK: API GET Call: Get character details
    func getCharacterDetails(characterID: String, complete: (success: Bool, character: Character?) -> ()) {
        let myURL = "https://abstract-key-135222.appspot.com/characters/" + characterID
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
                    let parsedXP = parsedData["XP"] as? Int
                    let parsedIQ = parsedData["IQ"] as? Int
                    let parsedSTR = parsedData["STR"] as? Int
                    let parsedDEX = parsedData["DEX"] as? Int
                    let newCharacter = Character(name: parsedName, id: parsedId, XP: parsedXP, IQ: parsedIQ, STR: parsedSTR, DEX: parsedDEX)
                    complete(success: true, character: newCharacter)
                } else {
                    complete(success: false, character: nil)
                }
            } catch {
                print(error)
                print("Error: couldn't parse json:")
                let stringData = String(response)
                print(stringData)
                complete(success: false, character: nil)
            }
        })
        task.resume()
    }
    
    func loadCharacterData(){
        getListMembers() { (success: Bool, keys: [String]?) -> () in
            if success {
                if keys != nil {
                    for key in keys! {
                        self.getCharacterDetails(key) { (success: Bool, character: Character?) -> () in
                            if success {
                                if character != nil {
                                    self.characters += [character!]
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: API DELETE Call: Delete specified character
    func deleteCharacter(characterID: String, complete: (success: Bool) -> ()) {
        let myURL = "https://abstract-key-135222.appspot.com/characters/" + characterID
        let request = NSMutableURLRequest(URL: NSURL(string: myURL)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary
                if json != nil {
                    complete(success: true)
                } else {
                    complete(success: false)
                }
            } catch {
                print(error)
                print("Error: couldn't parse json:")
                let stringData = String(response)
                print(stringData)
                complete(success: false)
            }
        })
        task.resume()
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            deleteCharacter(characters[indexPath.row].id) { (success: Bool) -> () in
                if success {
                    self.characters.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    //self.saveCharacterImages()
                }
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "characterDetailSegue" {
            let navView = segue.destinationViewController as! UINavigationController
            let destinationView = navView.topViewController as! CharacterViewController
            destinationView.userToken = self.userToken
            if let selectedCharacterCell = sender as? CharacterTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCharacterCell)!
                let selectedCharacter = characters[indexPath.row]
                destinationView.character = selectedCharacter
            }
        } else if segue.identifier == "addCharacterSegue" {
            let navView = segue.destinationViewController as! UINavigationController
            let destinationView = navView.topViewController as! EditCharacterViewController
            destinationView.userToken = self.userToken
            destinationView.partyID = partyID
        }
    }
    
    @IBAction func unwindToCharacterTableView(sender: UIStoryboardSegue) {
        if sender.sourceViewController is EditCharacterViewController {
            //saveCharacterImages()
            self.tableView.reloadData()
        }
    }
    
    /*
    // MARK: NSCoding
    func saveCharacterImages() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(characterImages, toFile: CharacterImage.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save character images.")
        }
    }
    
    func loadCharacterImages() -> [CharacterImage]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(CharacterImage.ArchiveURL.path!) as? [CharacterImage]
    }*/
}
