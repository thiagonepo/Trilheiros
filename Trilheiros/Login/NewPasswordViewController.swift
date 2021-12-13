//
//  NewPasswordViewController.swift
//  Trilheiros
//
//  Created by Laila Guzzon Hussein Lailota on 30/08/21.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn


class NewPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
   
    @IBOutlet weak var setNewPass: UIButton!
    
    private let images = [UIImage(named: "IMG1"), UIImage(named: "IMG2"), UIImage(named: "IMG3"), UIImage(named: "IMG4"), UIImage(named: "IMG5"), UIImage(named: "IMG6")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        // Do any additional setup after loading the view.
    }

    private func setupUI () {
        self.setNewPass.layer.cornerRadius = 4
        self.backgroundImageView.image = UIImage(named: "IMG1")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            
            let randoElement = Int.random(in: 0...5)
            
            UIView.transition(with: self.backgroundImageView, duration: 5.0, options: .transitionCrossDissolve, animations: {self.backgroundImageView.image = self.images[randoElement]}, completion: nil)
        }
        
    }

    
    @IBAction func setNewPassTapped(_ sender: UIButton) {
        let auth = Auth.auth()
        
        auth.sendPasswordReset(withEmail: emailTextField.text!) { (error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let ok: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let alert = UIAlertController(title: "Sucess", message: "A password reset email has been sent!", preferredStyle: .alert)
            let ok: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel) { action in
                self.performSegue(withIdentifier: "passwordSet", sender: nil)
            }
            
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
