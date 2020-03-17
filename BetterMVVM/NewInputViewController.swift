//
//  NewInputViewController.swift
//  BetterMVVM
//
//  Created by Samuel Edwin on 17/03/20.
//  Copyright © 2020 Samuel Edwin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import CasePaths

enum LoginInput: Equatable {
    case changedUserName(String)
    case changedPassword(String)
    case submit
}

extension SharedSequence {
    func compactMap<NewElement>(_ transform: @escaping (Element) -> NewElement?) -> SharedSequence<SharingStrategy, NewElement> {
        return self.map(transform).filter { $0 != nil }.map { $0! }
    }
    
    func map<NewElement>(to value: NewElement) -> SharedSequence<SharingStrategy, NewElement> {
        return self.map { _ in value }
    }
}

extension SharedSequence where Element: Equatable {
    func filter(_ value: Element) -> SharedSequence<SharingStrategy, Element> {
        return self.filter { $0 == value }
    }
}

class NewViewModel {
    func transform(_ input: Driver<LoginInput>) -> Output {
        let userName = input.compactMap(/LoginInput.changedUserName)
        let password = input.compactMap(/LoginInput.changedPassword)
        
        let credentials = Driver.combineLatest(userName, password)
        
        let submission = input.filter(.submit).withLatestFrom(credentials)
            
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
    
    struct Output {
        let errorMessage: Driver<String>
        let loginSuccess: Driver<Void>
    }
}

class NewInputViewController: UIViewController {
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: "ViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let input = ViewModel.Input(
//            userName: usernameTextField.rx.text.orEmpty.asDriver(),
//            password: passwordTextField.rx.text.orEmpty.asDriver(),
//            submit: loginButton.rx.tap.asDriver()
//        )
        
        let input = Driver.merge(
            usernameTextField.rx.text.orEmpty.asDriver().map(LoginInput.changedUserName),
            passwordTextField.rx.text.orEmpty.asDriver().map(LoginInput.changedPassword),
            loginButton.rx.tap.asDriver().map(to: .submit)
        )
        
        let vm = NewViewModel()
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
