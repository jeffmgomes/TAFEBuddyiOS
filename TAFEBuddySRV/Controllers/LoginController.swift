//
//  ViewController.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 24/8/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

// Login structure
struct Login: Encodable {
    let email: String
    let password: String
}

// Error enumeration
enum LoginError: Error {
    case invalidEmailOrPassword
    case networkError
    case generalError
}

extension LoginError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidEmailOrPassword:
            return NSLocalizedString("Credentials provided were invalid! Try Again.", comment: "Invalid Email or Password")
        case .networkError:
            return NSLocalizedString("It seems you are not connected! Try Again.", comment: "Network Error")
        case .generalError:
            return NSLocalizedString("General Error! Try Again.", comment: "Error")
        }
    }
}

class LoginController: UIViewController {

    //Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    // Properties
    let backgroundImageView = UIImageView()
    let baseUrl: String = "https://tafebuddy.azurewebsites.net/login" // Base url for this Controller
    
    // Activity Indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var student: Student!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackground() // Set the background up
        
        loginButtonOutlet.layer.cornerRadius = 5.0
        
        // Set delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Listem for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Stop listening keyboard events
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Hide keyboard
        self.hideKeyboard()
        
        // Test for empty fields
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty else {
            self.showToast(title: "Error", message: "Email and Password are required!")
            return
        }
        
        showLoadingHUD()
        
        // Get the token
        var accessToken: String!
        let auth = AuthenticationHelper()
        auth.ObtainToken { (token, error) in
            guard error == nil else {
                self.hideLoadingHUD()
                self.showToast(title: "Error", message: error!.localizedDescription)
                return
            }
            
            accessToken = token
            
            self.login(email: email, password: password, accessToken: accessToken) { (result, error) in
                self.hideLoadingHUD()
                // Check for errors
                guard error == nil else {
                    // If no jsonResponse print the general error
                    self.showToast(title: "Error", message: "\(error!.localizedDescription)")
                    return
                }
                
                // If no error, check which type of the user returned by the API
                if result?["type"] as? String == "Student"{
                    // Displays the appropriated Storyboard
                    if let obj = result?["value"] as? [String: Any] {
                        self.student = Student(studentId: obj["StudentID"] as? String, givenName: obj["GivenName"] as? String, lastName: obj["LastName"] as? String, email: obj["EmailAddress"] as? String)
                        self.performSegue(withIdentifier: "student", sender: nil)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "student" {
            if let tabViewController = segue.destination as? TabBarViewController {
                tabViewController.student = self.student
            }

        }
    }
    
    
    // Functions or Methods
    func login(email: String, password: String, accessToken: String, completion:@escaping ([String: Any]?, Error?) -> Void) {
             
        let login = Login(email: email, password: password)
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": accessToken
        ]
        
        AF.request(self.baseUrl,
                   method: .post,
                   parameters: login,
                   encoder: JSONParameterEncoder.default,
                   headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                  case .success:
                      guard let value = response.value as? [String: Any] else {
                          completion(nil,LoginError.generalError)
                          return
                      }
                      completion(value, nil)
                      
                  case let .failure(error):
                    if response.response?.statusCode == 401 {
                        
                    } else {
                        print("Error in login \(error)")
                        completion(nil,LoginError.generalError)
                    }
                  }
            
        }
    }
    
    // Toast
    func showToast(title: String, message: String){
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true,completion: nil)
    }
    
    // Background
    func setBackground(){
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        backgroundImageView.image = UIImage(named: "bg1")
        view.sendSubviewToBack(backgroundImageView)
    }
    
    
    // Keyboard events
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func hideKeyboard() {
        passwordTextField.resignFirstResponder()
    }
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showAdded(to: contentView, animated: true)
      hud.label.text = "Loading..."
    }

    private func hideLoadingHUD() {
      MBProgressHUD.hide(for: contentView, animated: true)
    }
}

// UITextFieldDelegate Methods
extension LoginController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            self.hideKeyboard()
        }
        return true
    }
}

