//
//  SignUpViewController.swift
//  Cardinal-Wizards
//
//  Created by Miriam Haart on 10/14/17.
//  Copyright © 2017 Julia Geist. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Cache

class SignUpViewController: UIViewController {

    var isLogin = false
    var ref: DatabaseReference?
    
    var fields = ["Full Name", "Email", "Password"]
    let users : [StudentType] = [.newcomer, .wizard]
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var newUser = User(name: "", uid: "",email: "", type: "student", state: "not lost", latitude: 0.0, longitude: 0.0)
    
    @IBAction func exitToSignUp(segue: UIStoryboardSegue) {}
    
    @IBAction func backButtonPressed(_ sender: Any) {
    }
    
    @IBAction func startSearchQuery(sender: AnyObject) {
        chooseUserType(sender)
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        for i in 0..<fields.count {
            let index = i + 4
            let textField = self.view.viewWithTag(index) as? UITextField
            
            if textField!.text == fields[i] {
                showAlert()
                return
            }
            
            
        }
        
        let name = (self.view.viewWithTag(4) as! UITextField).text!
        let email = (self.view.viewWithTag(5) as! UITextField).text!
        let password = (self.view.viewWithTag(6) as! UITextField).text!
        
        newUser.name = name
        newUser.email = email
        
        if isLogin {
            let db = FirebaseHelper()
            db.login(email: email, password: password, controller: self, callback: { (currentUser) in
                if let user = currentUser {
                    self.newUser.name = user.name
                    self.newUser.type = user.type
                    
                    self.instantiateHomeScreen()
                } else {
                    self.showAlert()
                }
            })
        } else {
            signUp(password: password)
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setUpUI()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func instantiateHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "Home") as! MapViewController
        cacheUser()
        vc.currentUser = self.newUser
        self.present(vc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postsSegue" {
            let vc = segue.destination as! ViewController
            
            cacheUser()
            
            vc.currentUser = newUser
            
        }
    }
    
    func setUpUI() {
        
        let tmpButton = self.view.viewWithTag(1) as? UIButton
        tmpButton!.roundAndShadow(radius: 10, opacity: 0.0, borderWidth: 1, borderColor: Helper.colorWithHexString(hex: "#FC2707").cgColor)
        
        
        backButton.roundAndShadow(radius: 10, opacity: 0.0, borderWidth: 1, borderColor: Helper.colorWithHexString(hex: "#FC2707").cgColor)
        
        
        if isLogin {
            self.fields[0] = "login"
            
            let tmpView = self.view.viewWithTag(7)
            let tmpStackView = self.view.viewWithTag(8) as? UIStackView
            
            tmpView!.isHidden = true
            tmpStackView!.isHidden = true
            
            signUpButton.setTitle("Log In", for: .normal)
        }
        
    }
    
    
    func signUp(password: String) {
        print(newUser)
        if newUser.name != "" && newUser.email != "" && newUser.type != "" && password != "" && password != "Password" {
            Auth.auth().createUser(withEmail: newUser.email, password: password) { (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                    
                    //Create the user in the database
                    self.ref!.child("users").child(user!.uid).setValue(["name": self.newUser.name,
                                                                        "type": self.newUser.type,
                                                                        "email": self.newUser.email,
                                                                        "longitude": "\(self.newUser.longitude)",
                                                                        "latitude": "\(self.newUser.latitude)"])
                    
                    self.instantiateHomeScreen()
                } else {
                    self.showAlert()
                }
            }
        } else {
            showAlert()
        }
        
    }
    
    func chooseUserType(_ sender: AnyObject) {
        let chosenButton = sender as! UIButton
        let chosenIndex = chosenButton.tag
        
        
        for i in 0..<users.count {
            let index = i + 1
            if index == chosenIndex {
                let userType = users[i]
                newUser.type = userType.rawValue
                chosenButton.roundAndShadow(radius: 10, opacity: 0.0, borderWidth: 2, borderColor: Helper.colorWithHexString(hex: "#FC2707").cgColor)
            } else {
                print(i)
                let tmpButton = self.view.viewWithTag(index) as? UIButton
                tmpButton?.layer.borderWidth = 0
            }
        }
    }
    
    func cacheUser() {
        let diskConfig = DiskConfig(name: "Floppy")
        
        let storage = try? Storage(diskConfig: diskConfig)
        
        try? storage?.setObject(newUser, forKey: "currentUser")
    }
    
    func showAlert() {
        //Tells the user that there is an error and then gets firebase to tell them the error
        let alertController = UIAlertController(title: "Missing Fields", message: "Please complete all fields", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if fields.contains(textField.text!) {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if  textField.text == "" {
            
            textField.text = fields[textField.tag - 4]
            
        }
    }
}
