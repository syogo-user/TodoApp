//
//  SignInViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/09.
//

import UIKit
import Amplify
import AWSCognitoAuthPlugin

class SignInViewController: BaseViewController {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private let viewModel: SignInViewModel = SignInViewModelImpl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func signIn(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        viewModel.signIn(userName: email, password: password)
    }
    
    @IBAction private func createAccount(_ sender: Any) {
        self.toAccount()
    }
        
    @IBAction private func googleSignIn(_ sender: Any) {
        Task {
            await socialSignInWithWebUI(provider: .google)
        }
    }
    
    @IBAction private func appleSignIn(_ sender: Any) {
        Task {
            await socialSignInWithWebUI(provider: .apple)
        }
    }

    // TODO: 後で適切な場所に移動
    func socialSignInWithWebUI(provider :AuthProvider) async {
        do {
            let signInResult = try await Amplify.Auth.signInWithWebUI(for: provider, presentationAnchor: self.view.window!)

            if signInResult.isSignedIn {
                print("Sign in succeeded")            
                self.viewModel.setUserInfo()
            }
        } catch let error as AuthError {
            print("Sign in failed \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }    
}
