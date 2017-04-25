//
//  EditCharacterViewController.swift
//  characterSheet
//
//  Created by Rachel Weissman-Hohler on 8/12/16.
//  Copyright © 2016 Rachel Weissman-Hohler. All rights reserved.
//

import UIKit

class EditCharacterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var xpTextField: UITextField!
    @IBOutlet weak var iqTextField: UITextField!
    @IBOutlet weak var strTextField: UITextField!
    @IBOutlet weak var dexTextField: UITextField!
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var userToken: String?
    var partyID: String?
    var character: Character?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set view controller as delegate for text fields
        nameTextField.delegate = self
        xpTextField.delegate = self
        iqTextField.delegate = self
        strTextField.delegate = self
        dexTextField.delegate = self

        // if character is not nil, prefill fields
        if character != nil {
            navigationItem.title = "Edit Character"
            nameTextField.text = character?.name
            xpTextField.text = String(character!.XP!)
            iqTextField.text = String(character!.IQ!)
            strTextField.text = String(character!.STR!)
            dexTextField.text = String(character!.DEX!)
            if character?.charImage != nil {
                characterImageView.image = character?.charImage
            }
        }
        
        // disable save button if name field is empty
        checkValidTextFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // disable save button when editing text field
        saveButton.enabled = false
    }
    
    func checkValidTextFields() {
        // disable save button if name field is empty
        var showSaveButton = false
        let nametext = nameTextField.text ?? ""
        if !(nametext.isEmpty) {
            showSaveButton = true
        }
        saveButton.enabled = showSaveButton
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidTextFields()
    }
    
    // MARK: Image view methods
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .PhotoLibrary
        
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        characterImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: API Post Call: Post Character
    func postCharacterToAPI(token: String, character: Character, complete: (success: Bool, character: Character?) -> ()) {
        let tokenString = "Bearer " + token
        let myURL = "https://abstract-key-135222.appspot.com/parties/" + partyID! + "/characters"
        let request = NSMutableURLRequest(URL: NSURL(string: myURL)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(tokenString, forHTTPHeaderField: "Authorization")
        
        let params: Dictionary<String, AnyObject> = ["name": character.name, "XP": character.XP!, "IQ": character.IQ!, "STR": character.STR!, "DEX": character.DEX!]
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params as NSDictionary, options: NSJSONWritingOptions(rawValue: 0))
        //*************************************************************************
        print(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)!)
        print("_______")
        //*************************************************************************
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //*************************************************************************
            print(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
            print(String(response))
            print(String(error))
            print("_____")
            //*************************************************************************
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary
                if let parsedData = json {
                    if let parsedId = parsedData["urlsafeKey"] as? String {
                        let parsedName = parsedData["name"] as! String
                        let parsedXP = parsedData["XP"] as? Int
                        let parsedIQ = parsedData["IQ"] as? Int
                        let parsedSTR = parsedData["STR"] as? Int
                        let parsedDEX = parsedData["DEX"] as? Int
                        let newCharacter = Character(name: parsedName, id: parsedId, XP: parsedXP, IQ: parsedIQ, STR: parsedSTR, DEX: parsedDEX)
                        complete(success: true, character: newCharacter)
                    } else {
                        complete(success: false, character: nil)
                    }
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
    
    // MARK: API PUT Call: Update Character
    func putCharacterToAPI(token: String, character: Character, complete: (success: Bool, character: Character?) -> ()) {
        let tokenString = "Bearer " + token
        let myURL = "https://abstract-key-135222.appspot.com/characters/" + self.character!.id
        let request = NSMutableURLRequest(URL: NSURL(string: myURL)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(tokenString, forHTTPHeaderField: "Authorization")
        
        let params: Dictionary<String, AnyObject> = ["name": character.name, "XP": character.XP!, "IQ": character.IQ!, "STR": character.STR!, "DEX": character.DEX!]
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params as NSDictionary, options: NSJSONWritingOptions(rawValue: 0))
        //*************************************************************************
        print(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)!)
        print("_______")
        //*************************************************************************
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //*************************************************************************
            print(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
            print(String(response))
            print(String(error))
            print("_____")
            //*************************************************************************
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary
                if let parsedData = json {
                    if let parsedId = parsedData["urlsafeKey"] as? String {
                        let parsedName = parsedData["name"] as! String
                        let parsedXP = parsedData["XP"] as? Int
                        let parsedIQ = parsedData["IQ"] as? Int
                        let parsedSTR = parsedData["STR"] as? Int
                        let parsedDEX = parsedData["DEX"] as? Int
                        let newCharacter = Character(name: parsedName, id: parsedId, XP: parsedXP, IQ: parsedIQ, STR: parsedSTR, DEX: parsedDEX)
                        complete(success: true, character: newCharacter)
                    } else {
                        complete(success: false, character: nil)
                    }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self === sender {
            let name = nameTextField.text
            let XP = Int(xpTextField.text ?? "0")
            let IQ = Int(iqTextField.text ?? "0")
            let STR = Int(strTextField.text ?? "0")
            let DEX = Int(dexTextField.text ?? "0")
            let newCharacter = Character(name: name!, id: "new", XP: XP, IQ: IQ, STR: STR, DEX: DEX)
            
            if character != nil {
                // update existing character
                putCharacterToAPI(userToken!, character: newCharacter!) { (success: Bool, character: Character?) -> () in
                    if success {
                        if character != nil {
                            character?.charImage = self.characterImageView.image
                            let destinationView = segue.destinationViewController as! CharacterViewController
                            destinationView.character = character
                            dispatch_async(dispatch_get_main_queue()) {
                                destinationView.updateLabels()
                            }
                        }
                    } else {
                        print("PUT Call to API failed")
                    }
                }
            } else {
                // create new character
                postCharacterToAPI(userToken!, character: newCharacter!) { (success: Bool, character: Character?) -> () in
                    if success {
                        if character != nil {
                            character?.charImage = self.characterImageView.image
                            let destinationView = segue.destinationViewController as! CharacterTableViewController
                            destinationView.characters.append(character!)
                            dispatch_async(dispatch_get_main_queue()) {
                                destinationView.tableView.reloadData()
                            }
                        }
                    } else {
                        print("POST Call to API failed")
                    }
                }
            }
        }
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        if character != nil {
            self.performSegueWithIdentifier("backToCharacterViewSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("backToCharacterTableSegue", sender: self)
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
