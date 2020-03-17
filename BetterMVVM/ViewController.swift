//
//  ViewController.swift
//  BetterMVVM
//
//  Created by Samuel Edwin on 17/03/20.
//  Copyright © 2020 Samuel Edwin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewModel {
    struct Input {
        let userName: Driver<String>
        let password: Driver<String>
        let submit: Driver<Void>
    }
    
    struct Output {
        let errorMessage: Driver<String>
        let loginSuccess: Driver<Void>
    }
    
    func transform(_ input: Input) -> Output {
        let credentials = Driver.combineLatest(input.userName, input.password)
        
        let submission = input.submit.withLatestFrom(credentials)
            
        let error = submission.filter { (credential) -> Bool in
            let (userName, password) = credential
            
            return userName.isEmpty || password.isEmpty
        }.map { _ in
            "Username and password must not be empty"
        }
        
        let success = submission.filter { (credential) -> Bool in
            let (userName, password) = credential
            
            return !userName.isEmpty && !password.isEmpty
        }.map { _ in
            
        }
        
        return Output(
            errorMessage: error,
            loginSuccess: success
        )
    }
}

class ViewController: UIViewController {
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let input = ViewModel.Input(
            userName: usernameTextField.rx.text.orEmpty.asDriver(),
            password: passwordTextField.rx.text.orEmpty.asDriver(),
            submit: loginButton.rx.tap.asDriver()
        )
        
        let vm = ViewModel()
        let output = vm.transform(input)
        
        output.loginSuccess.drive(onNext: { _ in
            let alert = UIAlertController(title: "Done", message: "Done", preferredStyle: .alert)
                
                alert
                    .addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        output.errorMessage.drive(onNext: { message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                
                alert
                    .addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }


}

