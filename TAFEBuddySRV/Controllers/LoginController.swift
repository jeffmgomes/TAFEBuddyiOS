//
//  ViewController.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 24/8/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import UIKit

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

    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Properties
    let backgroundImageView = UIImageView()
    let baseUrl: String = "https://tafebuddy.azurewebsites.net/login" // Base url for this Controller
    
    // Activity Indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var student: Student!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackground() // Set the background up
        setActivityIndicator() // Activity Indicator
        
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

        self.toogleActivityIndicator()
        
        // Call Login method
        self.login(email: email, password: password) { jsonResponse, error in
            // Becase web requests runs on the a different thread we need to dispatch from the main queue
            DispatchQueue.main.async {
                self.toogleActivityIndicator()
                // Check for errors
                guard error == nil else {
                    // If no jsonResponse print the general error
                    self.showToast(title: "Error", message: "\(error!.localizedDescription)")
                    return
                }
                
                // If no error, check which type of the user returned by the API
                if jsonResponse?["type"] as? String == "Student"{
                    // Displays the appropriated Storyboard
                    if let obj = jsonResponse?["value"] as? [String: Any] {
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
    func login(email: String, password: String, completion:@escaping ([String: Any]?, Error?) -> Void) {
        //Declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        let parameters: [String: Any] = ["email": email, "password": password] as Dictionary
        
        //Create the url
        let url = URL(string: self.baseUrl)! //change the url
        
        //Create the session object
        let session = URLSession(configuration: .default)
        
        //Now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST" //Set http method as POST
        
        // Convert the Dictionary as JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        // Add the headers
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
        //Create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                             // check for fundamental networking error
                    completion(nil, LoginError.networkError)
                    return
            }

            guard 200 ... 299 ~= response.statusCode else {                    // check for http errors
                if response.statusCode == 401 {
                    completion(nil, LoginError.invalidEmailOrPassword)
                } else {
                    completion(nil, LoginError.generalError)
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]{
                   completion(json,nil)
                }
            } catch {
                completion(nil,error)
            }
            
        })
        
        task.resume()
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
    
    // Activity Indicator
    func setActivityIndicator() {
        self.view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge;
        activityIndicator.backgroundColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)
    }
    func toogleActivityIndicator() {
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
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

