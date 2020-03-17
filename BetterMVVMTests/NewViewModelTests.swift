//
//  NewViewModelTests.swift
//  BetterMVVMTests
//
//  Created by Samuel Edwin on 17/03/20.
//  Copyright © 2020 Samuel Edwin. All rights reserved.
//

import XCTest
@testable import BetterMVVM
import RxSwift
import RxCocoa

class NewViewModelTests: XCTestCase {

    var viewModel: NewViewModel!
    let input = PublishSubject<MyFeatureInputs>()
    
    let errorMessageSubject = PublishSubject<String>()
    let successSubject = PublishSubject<Void>()
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        disposeBag = DisposeBag()
        viewModel = NewViewModel()
        let output = viewModel.transform(input.asDriver(onErrorDriveWith: .empty()))
        
        output.errorMessage.drive(errorMessageSubject).disposed(by: disposeBag)
        output.loginSuccess.drive(successSubject).disposed(by: disposeBag)
    }

    func testInvalidInputs() {
        let assertionCalled = expectation(description: "assertion called")
        
        errorMessageSubject.subscribe(onNext: { message in
            XCTAssertEqual(message, "Username and password must not be empty")
            assertionCalled.fulfill()
        }).disposed(by: disposeBag)
        
        input.onNext(.changedUsername(""))
        input.onNext(.changedPassword(""))
        input.onNext(.submit)
        
        wait(for: [assertionCalled], timeout: 0)
    }
    
    func testValidInputs() {
        let assertionCalled = expectation(description: "assertion called")
        
        successSubject.subscribe(onNext: {
            assertionCalled.fulfill()
        }).disposed(by: disposeBag)
        
        input.onNext(.changedUsername("a"))
        input.onNext(.changedPassword("b"))
        input.onNext(.submit)
        
        wait(for: [assertionCalled], timeout: 0)
    }

}
