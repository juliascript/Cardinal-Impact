//
//  FirebaseHelper.swift
//  Dream High
//
//  Created by Miriam Hendler on 9/14/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SwiftyJSON

class FirebaseHelper {
    
    var ref: DatabaseReference = Database.database().reference()
    
    func signUp(newUser: User, password: String) -> Bool {
        var didSignUp = false
        Auth.auth().createUser(withEmail: newUser.email, password: password) { (user, error) in
            
            if error == nil {
                print("You have successfully signed up")
                //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                
                //Create the user in the database
                self.ref.child("users").child(user!.uid).setValue(["name": newUser.name,
                                                                   "type": newUser.type,
                                                                   "email": newUser.email,
                                                                   "longitude": "\(newUser.longitude)",
                                                                   "latitude": "\(newUser.latitude)"])
                didSignUp = true
            }
        }
        return didSignUp
    }
    
    func login(email: String, password: String, controller: UIViewController, callback: @escaping (User?)->()) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error == nil {
                
                //Print into the console if successfully logged in
                print("You have successfully logged in")
                
                self.retrieveUser(uid: user!.uid, callback: { (userInfo) in
                    callback(userInfo)
                })
                
            } else {
                
                //Tells the user that there is an error and then gets firebase to tell them the error
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                controller.present(alertController, animated: true, completion: nil)
            }
            
        }
    }
    
    func retrieveUser(uid: String, callback: @escaping (User)->()) {
        
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            print(snapshot)
            if let value = snapshot.value as? [String: Any] {
                let email = value["email"] as! String
                let name = value["name"] as! String
                let type = value["type"] as! String
                let longitude = value["longitude"] as! String
                let latitude = value["latitude"] as! String
                //                let major = value["major"] as! String
                //                let year = value["year"] as! Int
                //                let interests = value["interests"] as! [String]
                
                
                let user = User(name: name, uid: uid, email: email, type: type, latitude: Double(latitude)!, longitude: Double(longitude)!)
                
                callback(user)
            }
        })
    }
    
    func logout() {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                print("Logged out")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    //    func uploadMessage(message: Message) {
    //        if Auth.auth().currentUser != nil {
    //            for receiver in message.receivers {
    //                ref.child("posts").child(receiver).child(message.date).setValue(["name": message.sender, "message": message.message, "receivers": message.receivers])
    //            }
    //            print("Message uploaded")
    //        }
    //    }
    
    func updateUserValue(key: String, value: String) {
        if let currentUser = Auth.auth().currentUser {
            ref.child("users").child(currentUser.uid).updateChildValues([key:value])
        }
    }
    
    //func retrieveStories(vc: DiscoverViewController) {
    //    ref.child("users").queryOrdered(byChild: "has_story").queryEqual(toValue: "true").observe(.childAdded, with: { (snapshot) in
    //
    //        if let value = snapshot.value as? [String: String] {
    //            let name = value["name"]
    //            let nationality = value["nationality"]
    //            let profile = value["profile"]
    //
    //            let college = value["college"]
    //            let major = value["major"]
    //            let about = value["about"] ?? ""
    //            let advice = value["advice"] ?? ""
    //            let email = value["email"] ?? "mjammer18@gmail.com"
    //
    //            let mentor = Mentor(name: name!,email: email, profile: profile!, nationality: nationality!, college: college!, major: major!)
    //            let story = Story(mentor: mentor, about: about, advice: advice)
    //
    //            let uid = snapshot.key
    //            print(uid)
    //            story.uid = uid
    //
    //
    //            vc.stories.append(story)
    //
    //        }
    //    })
    //}
    
    func retrieveUsers(vc: MapViewController) {
        let userRef = ref.child("users")
        
        userRef.observe(.value, with: { (snapshot) in
            if let messagesSnapshot = snapshot.value as? [String: [String: Any]] {
                if vc.users.count == 0 {
                    for uid in messagesSnapshot.keys {
                        let messageData = messagesSnapshot[uid]!
                        
                        let name = messageData["name"] as! String
                        let email = messageData["email"] as! String
                        let type = messageData["type"] as! String
                        var longitude = "0.0"
                        if messageData["longitude"] != nil {
                            longitude = messageData["longitude"] as! String
                        }
                        
                        var latitude = "0.0"
                        if messageData["latitude"] != nil {
                            latitude = messageData["latitude"] as! String
                        }
                        
                        let user = User(name: name, uid: uid, email: email, type: type, latitude: Double(latitude)!, longitude: Double(longitude)!)
                        
                        vc.users.append(user)
                    }
                } else {
                    var count = 0
                    let last = messagesSnapshot.keys.count
                    for uid in messagesSnapshot.keys {
                        count += 1
                        
                        if count == last {
                            let messageData = messagesSnapshot[uid]!
                            
                            let name = messageData["name"] as! String
                            let email = messageData["email"] as! String
                            let type = messageData["type"] as! String
                            var longitude = "0.0"
                            if messageData["longitude"] != nil {
                                longitude = messageData["longitude"] as! String
                            }
                            
                            var latitude = "0.0"
                            if messageData["latitude"] != nil {
                                latitude = messageData["latitude"] as! String
                            }
                            
                            let user = User(name: name,uid: uid, email: email, type: type, latitude: Double(latitude)!, longitude: Double(longitude)!)
                            
                            if user.uid != Auth.auth().currentUser!.uid {
                                vc.users.append(user)
                            }
                        }
                        
                    }
                }
            }
        })
        
        userRef.observe(.childChanged, with: { (snapshot) in
            //Determine if coordinate has changed
            var index = -1
            if let messagesSnapshot = snapshot.value as? [String: [String: Any]] {
                for uid in messagesSnapshot.keys {
                    
                    index += 1
                    
                    let messageData = messagesSnapshot[uid]!
                    
                    let name = messageData["name"] as! String
                    let email = messageData["email"] as! String
                    let type = messageData["type"] as! String
                    let longitude = messageData["longitude"] as! String
                    let latitude = messageData["latitude"] as! String
                    
                    let user = User(name: name,uid: uid, email: email, type: type, latitude: Double(latitude)!, longitude: Double(longitude)!)
                    if vc.users[index].latitude != Double(latitude)! && vc.users[index].longitude != Double(longitude)! {
                        vc.users[index] = user
                    }
                }
            }
        })
        
    }
    
    //func uploadSchools() {
    //    var count = 0
    //    //        let schools = dumpJson(file: "school")
    //    var data = readDataFromCSV(fileName: "school", fileType: "csv")
    //    data = cleanRows(file: data!)
    //    let csvRows = csv(data: data!)
    //
    //    for school in csvRows {
    //        count += 1
    //        print(school)
    //        if count > 1 {
    //            ref.child("schools").child("\(count)").setValue(["name": school[0], "institution": "college", "link": school[1], "image_url": school[2], "info": ""])
    //        }
    //    }
    //
    //}
    
    func dumpJson(file: String) -> JSON {
        let path = Bundle.main.path(forResource: file, ofType: "json")
        let jsonData = NSData(contentsOfFile:path!)
        let json = JSON(data: jsonData! as Data)
        return json
        //        println(json["DDD"].string)
    }
    
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
        return cleanFile
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
}


