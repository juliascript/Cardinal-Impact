//
//  SettingsViewController.swift
//  Cardinal-Wizards
//
//  Created by Miriam Haart on 10/15/17.
//  Copyright © 2017 Julia Geist. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class SettingsViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var interestsTextField: UITextField!
    
    let fb = FirebaseHelper()
    let picker = UIImagePickerController()
    let storageRef = Storage.storage().reference()
    let databaseRef = Database.database().reference()
    let profileImage: UIImage = #imageLiteral(resourceName: "profile_placeholder")
    var currentUser: User?
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        fb.logout()
    }
    @IBAction func profileButtonPressed(_ sender: Any) {
        presentPhotoOptions()
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setupUI() {
        profileButton.maskToCircle()
        profileButton.clipsToBounds = true
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func saveChanges(){
        
        let imageName = NSUUID().uuidString
        
        let storedImage = storageRef.child("profile_images").child(imageName)
        
        if let uploadData = UIImagePNGRepresentation(self.profileImage)
        {
            storedImage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                storedImage.downloadURL(completion: { (url, error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    if let urlText = url?.absoluteString{
                        self.fb.updateUserValue(key: "profile", value: urlText)
                    }
                })
            })
        }
        
        Helper.cacheUser(user: currentUser!)
    }
    
    func getProfilePic(fromSource: UIImagePickerControllerSourceType) {
    
        picker.delegate = self
        
        switch fromSource {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera;
                picker.allowsEditing = false
                self.present(picker, animated: true, completion: nil)
            }
        case .photoLibrary:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {


        profileButton.setImage(image.withRenderingMode(.automatic), for: .normal)
        profileButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .highlighted)
        profileButton.imageView?.contentMode = .scaleAspectFit
        
        let lowResImage = image.resizeImageWith(newSize: CGSize(width: 200, height: 200))
        
        currentUser!.profile = UIImagePNGRepresentation(lowResImage)!
        
        saveChanges()
        
        dismiss(animated:true, completion: nil)
        
    }
    func presentPhotoOptions() {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose A Photo", preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            self.getProfilePic(fromSource: .camera)
            
            print("taking a photo")
        })
        let choosePhotoAction = UIAlertAction(title: "Choose From Library", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
            {
                self.getProfilePic(fromSource: .photoLibrary)
            }
            
            print("choosing a photo from the library")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(choosePhotoAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
}
