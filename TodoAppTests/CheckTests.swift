//
//  CheckTests.swift
//  TodoAppTests
//
//  Created by 小野寺祥吾 on 2021/08/24.
//

import XCTest
@testable import TodoApp

class CheckTests: XCTestCase {
    let check = Check()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testIsEmpty() {
        let empty = ""
        let notEmpty = "value"
        XCTAssertTrue(check.isEmpty(inputArray: empty,notEmpty))
        XCTAssertFalse(check.isEmpty(inputArray: notEmpty,notEmpty))
    }
    
    func testIsNotEqual() {
        let password = "123456"
        let passwordCheck = "123459"
        XCTAssertTrue(check.isNotEqual(str1: password, str2: passwordCheck))
        XCTAssertFalse(check.isNotEqual(str1: password, str2: password))
    }
    
    func testMailAddressFormatCheck() {
        let mail1 = "sgmail.com"
        let mail2 = "sgmail@.com"
        let mail3 = "s@gmailcom"
        let mail4 = "s@gmail.com"
        XCTAssertTrue(check.mailAddressFormatCheck(address: mail1))
        XCTAssertTrue(check.mailAddressFormatCheck(address: mail2))
        XCTAssertTrue(check.mailAddressFormatCheck(address: mail3))
        XCTAssertFalse(check.mailAddressFormatCheck(address: mail4))
    }

    func testCharaMinCountCheck() {
        let password1 = "12345"
        let password2 = "123456"
        XCTAssertTrue(check.charaMinCountCheck(str: password1, minCount: 6))
        XCTAssertFalse(check.charaMinCountCheck(str: password2, minCount: 6))
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
