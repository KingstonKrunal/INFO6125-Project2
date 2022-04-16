//
//  LogInViewController.swift
//  INFO6125-Project2
//
//  Created by Krunal Shah on 2022-04-12.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Do empty check
    }
    
    @IBAction func login(_ sender: UIButton) {
        if let email = emailTF.text, let password = passwordTF.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                if error != nil {
                    strongSelf.errorAlert(error: error?.localizedDescription ?? "Error occured while signing in")
                }
                
                if authResult?.user != nil {
                    strongSelf.gotoMapVC()
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
        let alert = UIAlertController(title: "Sign In Failed!", message: error, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showSignUpVC(_ sender: UIButton) {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "signUpVC") as! SignUpViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated: false)
    }
    
}
