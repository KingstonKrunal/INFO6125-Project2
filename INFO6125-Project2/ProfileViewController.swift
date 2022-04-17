//
//  ProfileViewController.swift
//  INFO6125-Project2
//
//  Created by Krunal Shah on 2022-04-17.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var uName: UILabel!
    @IBOutlet weak var uEmail: UILabel!
    @IBOutlet weak var pName: UILabel!
    @IBOutlet weak var pType: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let db = Firestore.firestore()
        
        if let curUser = Auth.auth().currentUser {
            let docRef = db.collection("users").document(curUser.uid)
            docRef.getDocument { document, error in
                if error != nil {
                    // TODO: show alert
                } else {
                    if let document = document, document.exists {
                        self.uName.text = document.get("name") as? String
                        self.uEmail.text = curUser.email
                        self.pName.text = document.get("pet_name") as? String
                        self.pType.text = document.get("pet_type") as? String
                   } else {
                       print("Document does not exist")
                   }
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
