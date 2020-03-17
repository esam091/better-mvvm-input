//
//  BetterMVVMTests.swift
//  BetterMVVMTests
//
//  Created by Samuel Edwin on 17/03/20.
//  Copyright © 2020 Samuel Edwin. All rights reserved.
//

import XCTest
@testable import BetterMVVM
import RxSwift
import RxCocoa

class BetterMVVMTests: XCTestCase {

    var viewModel: ViewModel!
    let userNameSubject = PublishSubject<String>()
    let passwordSubject = PublishSubject<String>()
    let buttonSubmitSubject = PublishSubject<Void>()
    
    let errorMessageSubject = PublishSubject<String>()
    let successSubject = PublishSubject<Void>()
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        disposeBag = DisposeBag()
        viewModel = ViewModel()
        let output = viewModel.transform(.init(
            userName: userNameSubject.asDriver(onErrorDriveWith: .empty()),
            password: passwordSubject.asDriver(onErrorDriveWith: .empty()),
            submit: buttonSubmitSubject.asDriver(onErrorDriveWith: .empty())
        ))
        
        output.errorMessage.drive(errorMessageSubject).disposed(by: disposeBag)
        output.loginSuccess.drive(successSubject).disposed(by: disposeBag)
    }

    func testInvalidInputs() {
        let assertionCalled = expectation(description: "assertion called")
        
        errorMessageSubject.subscribe(onNext: { message in
            XCTAssertEqual(message, "Username and password must not be empty")
            assertionCalled.fulfill()
        }).disposed(by: disposeBag)
        
        userNameSubject.onNext("")
        passwordSubject.onNext("")
        buttonSubmitSubject.onNext(())
        
        wait(for: [assertionCalled], timeout: 0)
    }
    
    func testValidInputs() {
        let assertionCalled = expectation(description: "assertion called")
        
        successSubject.subscribe(onNext: {
            assertionCalled.fulfill()
        }).disposed(by: disposeBag)
        
        userNameSubject.onNext("a")
        passwordSubject.onNext("b")
        buttonSubmitSubject.onNext(())
        
        wait(for: [assertionCalled], timeout: 0)
    }

    

}
