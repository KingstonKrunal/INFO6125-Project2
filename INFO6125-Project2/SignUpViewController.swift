//
//  SignUpViewController.swift
//  INFO6125-Project2
//
//  Created by Krunal Shah on 2022-04-12.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var pTypeTF: UITextField!
    @IBOutlet weak var pnameTF: UITextField!
    @IBOutlet weak var unameTF: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorMessageForEmailId: UILabel!
    @IBOutlet weak var errorMessageForPassword: UILabel!
    @IBOutlet weak var errorMessageForUserName: UILabel!
    @IBOutlet weak var errorMessageForPetName: UILabel!
    @IBOutlet weak var errorMessageForPetType: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Do empty check
        signUpButton.isEnabled = (emailTF.text == nil || passwordTF.text == nil || pnameTF.text == nil || unameTF.text == nil || pTypeTF.text == nil)
    }
    
    func checkingValidity()  {
        if let email = emailTF.text, let password = passwordTF.text, let uName = unameTF.text, let pName = pnameTF.text, let pType = pTypeTF.text {
            if !email.isEmpty && !password.isEmpty && !uName.isEmpty && !pName.isEmpty && !pType.isEmpty {
                signUpButton.isEnabled = true
            } else {
                signUpButton.isEnabled = false
            }
        }
    }
    
    @IBAction func userNameTFChanged(_ sender: UITextField) {
        checkingValidity()
        
        if let userName = unameTF.text{
            if !userName.isEmpty {
                errorMessageForUserName.isHidden = true
            } else {
                errorMessageForUserName.isHidden = false
            }
        }
    }
    
    @IBAction func petNameTFChanged(_ sender: UITextField) {
        checkingValidity()
        
        if let petName = pnameTF.text{
            if !petName.isEmpty {
                errorMessageForPetName.isHidden = true
            } else {
                errorMessageForPetName.isHidden = false
            }
        }
    }
    
    @IBAction func petTypeTFChanged(_ sender: UITextField) {
        checkingValidity()
        
        if let petType = pTypeTF.text{
            if !petType.isEmpty {
                errorMessageForPetType.isHidden = true
            } else {
                errorMessageForPetType.isHidden = false
            }
        }
    }
    
    @IBAction func emailTFChanged(_ sender: UITextField) {
        checkingValidity(   )
        
        if let email = emailTF.text{
            if !email.isEmpty {
                errorMessageForEmailId.isHidden = true
            } else {
                errorMessageForEmailId.isHidden = false
            }
        }
    }
    
    @IBAction func passwordTFChanged(_ sender: UITextField) {
        checkingValidity()
        
        if let password = passwordTF.text{
            if !password.isEmpty {
                errorMessageForPassword.isHidden = true
            } else {
                errorMessageForPassword.isHidden = false
            }
        }
    }
    
    @IBAction func signup(_ sender: Any) {
        if let uname = unameTF.text, let pname = pnameTF.text, let pType = pTypeTF.text, let email = emailTF.text, let password = passwordTF.text {
            
            let auth = Auth.auth()
            if auth.currentUser != nil {
                //TODO: Query user data from firebase, if not exists create it.
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if error != nil {
                    self.errorAlert(error: error?.localizedDescription ?? "Error occured while registering user")
                }
                
                if authResult?.user != nil {
                    if let uid = authResult?.user.uid {
                        let db = Firestore.firestore()
                        db.collection("users").document(uid).setData([
                            "name": uname,
                            "pet_name": pname,
                            "pet_type": pType
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                                self.errorAlert(error: "Error occured while registering user")
                            } else {
                                self.gotoMapVC()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func gotoMapVC() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "mapViewController") as! MapViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated: true)
    }
    
    func errorAlert(error: String) {
        let alert = UIAlertController(title: "Sign Up Failed!", message: error, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showLoginVC(_ sender: UIButton) {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LogInViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated: false)
    }
    
}

