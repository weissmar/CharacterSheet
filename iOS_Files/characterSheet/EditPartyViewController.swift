//
//  EditPartyViewController.swift
//  characterSheet
//
//  Created by Rachel Weissman-Hohler on 8/12/16.
//  Copyright © 2016 Rachel Weissman-Hohler. All rights reserved.
//

import UIKit

class EditPartyViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var meetingDayPicker: UIPickerView!
    @IBOutlet weak var meetingTimePicker: UIDatePicker!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var pickerDataSource = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var userToken: String?
    var party: Party?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view controller as delegate for text field and pickerview
        nameField.delegate = self
        meetingDayPicker.delegate = self
        meetingDayPicker.dataSource = self
        
        // if party is not nil, pre-fill fields
        if party != nil {
            nameField.text = party?.name
            var selectRow = pickerDataSource.indexOf((party?.meetingDay)!)
            if selectRow == nil {
                selectRow = 0
            }
            meetingDayPicker.selectRow(selectRow!, inComponent: 0, animated: false)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let time = dateFormatter.dateFromString(party!.meetingTime!)
            meetingTimePicker.date = time!
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let date = dateFormatter.dateFromString(party!.startDate!)
            startDatePicker.date = date!
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
        let nametext = nameField.text ?? ""
        if !(nametext.isEmpty) {
            showSaveButton = true
        }
        saveButton.enabled = showSaveButton
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidTextFields()
    }
    
    // MARK: UIPickerView delegate methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    // MARK: API Post Call: Post Party
    func postPartyToAPI(token: String, party: Party, complete: (success: Bool, party: Party?) -> ()) {
        let tokenString = "Bearer " + token
        let myURL = "https://abstract-key-135222.appspot.com/users"
        let request = NSMutableURLRequest(URL: NSURL(string: myURL)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(tokenString, forHTTPHeaderField: "Authorization")
        
        let params: Dictionary<String, AnyObject> = ["name": party.name, "startDate": party.startDate!, "meetingDay": party.meetingDay!, "meetingTime": party.meetingTime!]
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
                        let parsedStartDate = parsedData["startDate"] as? String
                        let parsedMeetingDay = parsedData["meetingDay"] as? String
                        let parsedMeetingTime = parsedData["meetingTime"] as? String
                        let newParty = Party(name: parsedName, id: parsedId, startDate: parsedStartDate, meetingDay: parsedMeetingDay, meetingTime: parsedMeetingTime)
                        complete(success: true, party: newParty)
                    } else {
                        complete(success: false, party: nil)
                    }
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
    
    // MARK: API PUT Call: Update Party
    func putPartyToAPI(token: String, party: Party, complete: (success: Bool, party: Party?) -> ()) {
        let tokenString = "Bearer " + token
        let myURL = "https://abstract-key-135222.appspot.com/parties/" + self.party!.id
        let request = NSMutableURLRequest(URL: NSURL(string: myURL)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(tokenString, forHTTPHeaderField: "Authorization")
        
        let params: Dictionary<String, AnyObject> = ["name": party.name, "startDate": party.startDate!, "meetingDay": party.meetingDay!, "meetingTime": party.meetingTime!]
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
                        let parsedStartDate = parsedData["startDate"] as? String
                        let parsedMeetingDay = parsedData["meetingDay"] as? String
                        let parsedMeetingTime = parsedData["meetingTime"] as? String
                        let newParty = Party(name: parsedName, id: parsedId, startDate: parsedStartDate, meetingDay: parsedMeetingDay, meetingTime: parsedMeetingTime)
                        complete(success: true, party: newParty)
                    } else {
                        complete(success: false, party: nil)
                    }
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

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self === sender {
            let name = nameField.text!
            let id = "new"
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let meetingTime = dateFormatter.stringFromDate(meetingTimePicker.date)
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let startDate = dateFormatter.stringFromDate(startDatePicker.date)
            let meetingDay = pickerDataSource[meetingDayPicker.selectedRowInComponent(0)]
            let newParty = Party(name: name, id: id, startDate: startDate, meetingDay: meetingDay, meetingTime: meetingTime)
            
            if party != nil {
                // update existing party
                putPartyToAPI(userToken!, party: newParty!) { (success: Bool, party: Party?) -> () in
                    if success {
                        if party != nil {
                            let destinationView = segue.destinationViewController as! PartyViewController
                            destinationView.currParty = party
                            dispatch_async(dispatch_get_main_queue()) {
                                destinationView.updateLabels()
                            }
                        }
                    } else {
                        print("PUT API call failed")
                    }
                }
            } else {
                // create new party
                postPartyToAPI(userToken!, party: newParty!) { (success: Bool, party: Party?) -> () in
                    if success {
                        if party != nil {
                            let destinationView = segue.destinationViewController as! ViewController
                            dispatch_async(dispatch_get_main_queue()) {
                                destinationView.partyID = party?.id
                            }
                        }
                    } else {
                        print("POST API call failed")
                    }
                }
            }
        }
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        if party != nil {
            self.performSegueWithIdentifier("savePartyEditsSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("saveNewPartySegue", sender: self)
        }
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
