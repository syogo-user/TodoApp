//
//  Date+ExtentionTests.swift
//  TodoAppTests
//
//  Created by 小野寺祥吾 on 2021/08/28.
//

import XCTest

class Date_ExtentionTests: XCTestCase {
        
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
    
    func testDateFormat() {
        let calendar = Calendar(identifier: .gregorian)
        // 2021/08/27
        let date = calendar.date(from: DateComponents(year: 2021, month: 8, day: 27))!
        XCTAssertEqual("20210827", date.dateFormat())
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
