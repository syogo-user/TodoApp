//
//  Date+ExtentionTests.swift
//  TodoAppTests
//
//  Created by 小野寺祥吾 on 2023/03/31.
//

import XCTest

final class Date_ExtentionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testDateFormat() {
        XCTContext.runActivity(named: "日付型を文字列に変換") { _ in
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: DateComponents(year: 2023, month: 4, day: 13, hour: 14, minute: 30))!
            let expectedDate = "202304131430"
            XCTAssertEqual(date.dateFormat(), expectedDate)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
