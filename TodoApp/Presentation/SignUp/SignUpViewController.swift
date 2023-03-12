//
//  SignUpViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/11.
//


import UIKit

class SignUpViewController: BaseViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    private let viewModel: SignUpViewModel = SignUpViewModelImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signUp(_ sender: Any) {
        guard let userName = userNameTextField.text, let password = passwordTextField.text, let email = emailTextField.text else { return }
        // TODO: email
        viewModel.signUp(userName: email, password: password, email: email)
    }
}
