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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Do empty check
        
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
                        db.collection("users").addDocument(data: [
                            "uid": uid,
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

