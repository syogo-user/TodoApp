//
//  String+ExtentionTests.swift
//  TodoAppTests
//
//  Created by 小野寺祥吾 on 2023/03/30.
//

import XCTest

final class String_ExtentionTests: XCTestCase {

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

    func testIsConvertibleDate() {
        XCTContext.runActivity(named: "Date型への変換可能な書式") { _ in
            let validDate = "202304131430"
            XCTAssertTrue(validDate.isConvertibleDate())
        }
        XCTContext.runActivity(named: "Date型への変換不可な書式") { _ in
            let invalidDate = "202300000000"
            XCTAssertFalse(invalidDate.isConvertibleDate())
        }
    }

    func testToDate() throws {
        try XCTContext.runActivity(named: "日付型への変換") { _ in
            let validDate = "202304131430"
            let calendar = Calendar(identifier: .gregorian)
            let expectedDate = calendar.date(from: DateComponents(year: 2023, month: 4, day: 13, hour: 14, minute: 30))!
            XCTAssertEqual(try validDate.toDate(), expectedDate)
        }
    }

    func testDateJpFormat() {
        XCTContext.runActivity(named: "今年の日付の場合") { _ in
            let validDateOfThisYear = "202304131430"
            XCTAssertEqual(validDateOfThisYear.dateJpFormat(), "04月13日 14時30分")
        }
        XCTContext.runActivity(named: "去年の日付の場合") { _ in
            let validDateOfLastYear = "202204131430"
            XCTAssertEqual(validDateOfLastYear.dateJpFormat(), "2022年04月13日 14時30分")
        }
    }

    func testDateTimeTupleFormat() {
        XCTContext.runActivity(named: "年, 月, 日, 分, 秒に分割") { _ in
            let validDate = "202304131430"
            let year = validDate.dateTimeTupleFormat().0
            let month = validDate.dateTimeTupleFormat().1
            let day = validDate.dateTimeTupleFormat().2
            let hour = validDate.dateTimeTupleFormat().3
            let minute = validDate.dateTimeTupleFormat().4
            XCTAssertEqual(year, "2023")
            XCTAssertEqual(month, "04")
            XCTAssertEqual(day, "13")
            XCTAssertEqual(hour, "14")
            XCTAssertEqual(minute, "30")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
