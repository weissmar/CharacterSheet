//
//  AppDelegate.swift
//  characterSheet
//
//  Created by Rachel Weissman-Hohler on 8/11/16.
//  Copyright © 2016 Rachel Weissman-Hohler. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Initialize sign-in (from https://developers.google.com/identity/sign-in/ios/sign-in?ver=swift )
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
    
    // MARK: API Post Call
    func postTokenToAPI(token: String, complete: (success: Bool, party: String?) -> ()) {
        let tokenString = "Bearer " + token
        let myURL = "https://abstract-key-135222.appspot.com/sign-in"
        let request = NSMutableURLRequest(URL: NSURL(string: myURL)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(tokenString, forHTTPHeaderField: "Authorization")
        
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
                    if let partyID = parsedData["party"] as? String {
                        complete(success: true, party: partyID)
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

    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let idToken = user.authentication.idToken
            
            // send token to back-end to validate and get user's character info 
            postTokenToAPI(idToken) { (success: Bool, party: String?) -> () in
                if success {
                    let rootViewController = self.window!.rootViewController as? ViewController
                    rootViewController?.userToken = idToken
                    if !(party?.isEmpty)! {
                        // get party info and display party page
                        rootViewController?.partyID = party
                        rootViewController?.performSegueWithIdentifier("existingPartySegue", sender: self)
                    } else {
                        // show create new party page
                        rootViewController?.partyID = nil
                        rootViewController?.performSegueWithIdentifier("newPartySegue", sender: self)
                    }
                } else {
                    // redirect back to sign-in page
                    GIDSignIn.sharedInstance().signOut()
                }
            }
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // **************************************************************************************
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

