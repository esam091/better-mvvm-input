//
//  ViewController.swift
//  BetterMVVM
//
//  Created by Samuel Edwin on 17/03/20.
//  Copyright © 2020 Samuel Edwin. All rights reserved.
//

import UIKit
import RxCocoa

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
        
        return Output(
            errorMessage: .empty(),
            loginSuccess: .empty()
        )
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

