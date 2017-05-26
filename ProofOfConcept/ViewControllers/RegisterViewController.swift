//
//  RegisterViewController.swift
//  ProofOfConcept
//
//  Created by Stephen Vickers on 2/28/17.
//  Copyright © 2017 Stephen Vickers. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseRemoteConfig

class RegisterViewController: UIViewController {

    //MARK: - Private variables -

    private let TAG = "RegisterViewController"

    private var fireBaseRef: FIRDatabaseReference!

    private var fireBaseRemote : FIRRemoteConfig!

    fileprivate let userDefaults = UserDefaults.standard

    fileprivate var errorCount = 0

    fileprivate static let maxErrorCount = 3
    
    fileprivate let yMoveValue: CGFloat  = 175
    
    fileprivate var keyBoardShown = false
    
    //MARK: - Outlets for the View -
    


    @IBOutlet weak var registerCardOutlet: UIDesignableView!
    ///Outlet for the to get the User Name from the View
    @IBOutlet weak var userNameTextOutlet: UILoginTextField!

    ///Outlet to get the User's Email from the View
    @IBOutlet weak var userEmailTextOutlet: UILoginTextField!

    ///Outlet to get the User's Password from the view
    @IBOutlet weak var userPasswordTextField: UILoginTextField!

    ///Outlet for the registerLoginButton
    @IBOutlet weak var registerLoginButtonOutlet: UIDesignableButton!
    
    @IBOutlet weak var loginButtonOutlet: UIDesignableButton!

    
    //MARK: - Override of the UIViewController methods used in this class -
    
    //function to do setup of the screen right before it appears
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up a Notification for the keyboard showing or hiding
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil )
        
        //set the posistion of the loginButton
        self.loginButtonOutlet.center = self.registerLoginButtonOutlet.center


//        //Find out if the user has logged in before and set up the view accordingly
//        if userDefaults.bool(forKey: UserDefaultCalls.registeredBefore.rawValue) {
//            self.registerLoginButtonOutlet.alpha = 0
//            self.userNameTextOutlet.text = self.userDefaults.value(forKey: UserDefaultCalls.userName.rawValue) as? String
//        } else {
//            self.loginButtonOutlet.alpha = 0
//        }

        //Set the delegates on the textFields
        self.userEmailTextOutlet.delegate = self
        self.userNameTextOutlet.delegate = self
        self.userPasswordTextField.delegate = self

        //Set the FIRDatebase reference for the view
        self.fireBaseRef = FIRDatabase.database().reference()
        
        
       
    }
    
    ///Override of the UIView.viewWillDisappear(_:) function
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Remove the NotificationCenter observer from the application
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.setUpView()        
    }

    //MARK: - Actions for the RegisterViewController class -

    @IBAction func registerLoginTouchedUp(_ sender: UIButton) {

        guard let name = self.userNameTextOutlet.text, self.validateInput(input: name) else {
            return
        }

        guard let email = self.userEmailTextOutlet.text,  self.validateInput(input: email) else{
            return
        }

        guard let password = self.userPasswordTextField.text , self.validateInput(input: password) else {
            return
        }

        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user : FIRUser?, error) in
            
            if error != nil {

                FIRAuth.auth()?.signIn(withEmail: email, password: password, completion:  { (user: FIRUser?, error) in

                    if error != nil {


                       _ = self.handleError(error: error! as NSError)


                    } else {

                    }


                })

                self.userDefaults.set(true, forKey: UserDefaultCalls.registeredBefore.rawValue)
//                self.showErrorCard(error: error!)
                return
            }


            self.userDefaults.set(name, forKey: UserDefaultCalls.userName.rawValue)

            let userRef = self.fireBaseRef.child(FireBaseCalls.users.rawValue)

            let values = [FireBaseCalls.userName.rawValue: name, FireBaseCalls.userEmail.rawValue: email]

            let uid = user?.uid

            userRef.child(uid!).updateChildValues(values, withCompletionBlock: { (userError, ref) in

                if userError != nil {
                    return
                }

            })

        })

        self.showNextView()
    }

    
    @IBAction func loginButtonTouchUP(_ sender: UIDesignableButton) {

        guard let email = self.userEmailTextOutlet.text,  self.validateInput(input: email) else{
            return
        }

        guard let password = self.userPasswordTextField.text , self.validateInput(input: password) else {
            return
        }

        let name = userNameTextOutlet.text

        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion:  { (user: FIRUser?, error) in

            if error != nil {

                self.increaseErrorCount()
                _ = self.handleError(error: error! as NSError)


            } else {

                let userRef = self.fireBaseRef.child(FireBaseCalls.users.rawValue)

                let values = [FireBaseCalls.userName.rawValue: name, FireBaseCalls.userEmail.rawValue: email]

                let uid = user?.uid

                userRef.child(uid!).updateChildValues(values, withCompletionBlock: { (userError, ref) in

                    if userError != nil {
                        return
                    }

                })

                self.showNextView()
            }
        })


    }
    


    //MARK: - Private Functions for the RegisterViewController Class

    ///Private Function to validate that the user entered a valid string in any of the Text fields
    /// -param input: A string to check if it's a valid input
    private func validateInput(input: String) -> Bool {
        return input.characters.count > 0
    }

    private func increaseErrorCount(){
        self.errorCount += 1
    }

    private func resetErrorCount(){
        self.errorCount = 0
    }

    private func handleError(error: NSError?) -> String? {

        var alert : UIAlertController?

        if let errCode = FIRAuthErrorCode(rawValue: (error?._code)!){
            switch errCode{
            case .errorCodeWrongPassword:
                alert = UIAlertController(title: "Incorrect Password", message: "The password you entered was incorrect", preferredStyle: .alert)

                alert!.addTextField(configurationHandler: {(textField: UITextField) in
                    textField.placeholder = "PASSWORD:"
                    textField.isSecureTextEntry = true
                    textField.keyboardType = .alphabet
                })

                let action1 = UIAlertAction(title: "Okay", style: .default, handler: {(action: UIAlertAction) in
                    self.userPasswordTextField.text = alert!.textFields![0].text!
                    self.loginButtonTouchUP(self.loginButtonOutlet)
                })
                alert!.addAction(action1)

            case .errorCodeInvalidEmail:
                alert = UIAlertController(title: "Invalid Email", message: "That Email Address is invalid", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Okay", style: .default, handler: handleInvalidEmail)
                alert!.addAction(action1)

            case .errorCodeAccountExistsWithDifferentCredential:
                alert = UIAlertController(title: "Email Already Exist ", message: "That Email is already in use", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Cancel", style: .cancel)
                alert!.addAction(action1)



            default:
                alert = UIAlertController(title: "Something went wrong here", message: "We're not sure what happened", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Okay", style: .default)
                alert!.addAction(action1)

            }
        }


        self.present(alert!, animated: true)


        return nil 
    }

    private func showNextView(){
        let launchScreen = storyboard?.instantiateViewController(withIdentifier: "launchScreen") as! LaunchViewController
        self.present(launchScreen, animated: true)

    }
    
    ///Function to set up/ change the layout of the view.
    private func setUpView(){
        
        if UIDevice.current.orientation.isPortrait && UIDevice.current.userInterfaceIdiom == .pad{
            self.registerCardOutlet.center = self.view.center
        }else if UIDevice.current.userInterfaceIdiom == .pad{
            self.registerCardOutlet.center.x = self.view.center.x
            self.registerCardOutlet.center.y = self.view.center.y - 225
        }else{
            self.registerCardOutlet.center = self.view.center
        }
    }


}

//MARK: - Extension on the RegisterViewController Class -

extension RegisterViewController : UITextFieldDelegate {

    //MARK: - Extensions to make RegisterVewController conform to UITextFieldDelegate -

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        switch (textField){
        case self.userNameTextOutlet:
            self.userEmailTextOutlet.becomeFirstResponder()
        case self.userEmailTextOutlet:
            self.userPasswordTextField.becomeFirstResponder()
        case self.userPasswordTextField:
            textField.resignFirstResponder()
            if self.userDefaults.bool(forKey: UserDefaultCalls.registeredBefore.rawValue){
                self.loginButtonTouchUP(self.loginButtonOutlet)
            }else {
                self.registerLoginTouchedUp(self.registerLoginButtonOutlet)
            }
        default:
            textField.resignFirstResponder()

        }
        return true
    }
    
    ///Function to be called when the keyboard will Appear
    ///
    /// -Parameter notification:    A NSNotification that calls this function
    @objc fileprivate func keyBoardWillAppear(_ notification: NSNotification){
        
        if UIDevice.current.orientation.isLandscape &&
            UIDevice.current.userInterfaceIdiom == .pad &&
            !self.keyBoardShown{
            self.registerCardOutlet.center.y -= self.yMoveValue
        }
        
        self.keyBoardShown = true
    }
    
    ///Function to be called when the keyboard will Disappear
    ///
    /// -Parameter notification:    A NSNotification that calls the function
    @objc fileprivate func keyBoardWillDisappear( _ notification: NSNotification){
        self.registerCardOutlet.center = self.view.center
        self.keyBoardShown = false
    }

}

extension RegisterViewController {

    fileprivate func handleInvalidEmail(action: UIAlertAction) {
        self.userEmailTextOutlet.text = ""
        self.userPasswordTextField.text = ""
    }

    fileprivate func handleInvalidPassword(action: UIAlertAction){
        self.userPasswordTextField.text = ""
    }
}
