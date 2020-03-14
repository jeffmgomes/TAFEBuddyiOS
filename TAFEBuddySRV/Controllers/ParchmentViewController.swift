//
//  ParchmentViewController.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 22/11/19.
//  Copyright © 2019 Jefferson Gomes. All rights reserved.
//

import UIKit

class ParchmentViewController: UIViewController {
    
    var student: Student!
    var qualification: Qualification!
    
    var activeTextField: UITextField?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var submitParchmentButton: UIButton!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var tafesaIDTextField: UITextField!
    @IBOutlet weak var qualificationTitleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        submitParchmentButton.layer.cornerRadius = 5
        
        // Set the DatePicker view
        let dateOfBirthPicker: UIDatePicker = UIDatePicker()
        dateOfBirthPicker.datePickerMode = .date
        dateOfBirthPicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        dateOfBirthTextField.delegate = self
        dateOfBirthTextField.inputView = dateOfBirthPicker
        
        // Auto populate fields based on the user
        firstNameTextField.text = self.student.GivenName
        lastNameTextField.text = self.student.LastName
        emailTextField.text = self.student.Email
        tafesaIDTextField.text = self.student.StudentId
        qualificationTitleTextField.text = self.qualification.QualName
        
        // Listem for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Stop listening keyboard events
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Keyboard events
    @objc func keyboardWillShow(notification: NSNotification) {
       if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0   )
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect = self.view.frame
        aRect.size.height -= keyboardSize.height
   
        if let activeTextField = self.activeTextField {
            if (!aRect.contains(activeTextField.frame.origin) ) {
                scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
              }
            }
       }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func hideKeyboard() {
        self.resignFirstResponder()
    }

    @objc func handleDatePicker(_ sender: UIDatePicker){
        dateOfBirthTextField.text = DateFormatter.localizedString(from: sender.date, dateStyle: .medium, timeStyle: .none)
    }
    @IBAction func submitParchmentTapped(_ sender: Any) {
        showToast(title: "Success", message: "Parchment successfully submitted!") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Toast
    func showToast(title: String, message: String, completion: @escaping() -> Void) {
        let alertAction = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            completion()
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ParchmentViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}
