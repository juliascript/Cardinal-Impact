//
//  LoginViewController.swift
//  Cardinal-Wizards
//
//  Created by Miriam Haart on 10/14/17.
//  Copyright © 2017 Julia Geist. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    //Button IBOutlets
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    //Exit Segue
    @IBAction func exitToOnboard(segue: UIStoryboardSegue){}
    
    var isLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //IBActions
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        isLogin = false
        performSegue(withIdentifier: "signUpSegue", sender: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        isLogin = true
        performSegue(withIdentifier: "signUpSegue", sender: self)
    }
    
    
    // Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SignUpViewController
        if segue.identifier == "signUpSegue" {
            vc.isLogin = isLogin
        }
    }
    
    
    // Helpers
    
    func setUpUI() {
        //        Helper.colorWithHexString(hex: "#FC2707").cgColor
        signUpButton.roundAndShadow(radius: 20, opacity: 0.0)
        loginButton.roundAndShadow(radius: 20, opacity: 0.0, borderWidth: 1, borderColor: StanfordColor.darkgreen.cgColor)
        
    }

}
