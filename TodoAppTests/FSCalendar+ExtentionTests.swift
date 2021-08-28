//
//  FSCalendar+ExtentionTests.swift
//  TodoAppTests
//
//  Created by 小野寺祥吾 on 2021/08/28.
//

import XCTest
import FSCalendar

class FSCalendar_ExtentionTests: XCTestCase {
    let fsCalendar = FSCalendar()
    let calendar = Calendar(identifier: .gregorian)
    
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
    
    func testJudgeHoliday() {
        // 2021/08/09 祝日
        let date1 = calendar.date(from: DateComponents(year: 2021, month: 8, day: 9))!
        // 2021/08/27 平日
        let date2 = calendar.date(from: DateComponents(year: 2021, month: 8, day: 27))!
        XCTAssertTrue(fsCalendar.judgeHoliday(date1))
        XCTAssertFalse(fsCalendar.judgeHoliday(date2))
    }
    
    func testGetWeekIdx() {
        // 2021/08/22 (日) 〜 2021/08/28 (土)
        let sun = calendar.date(from: DateComponents(year: 2021, month: 8, day: 22))!
        let mon = calendar.date(from: DateComponents(year: 2021, month: 8, day: 23))!
        let tue = calendar.date(from: DateComponents(year: 2021, month: 8, day: 24))!
        let wed = calendar.date(from: DateComponents(year: 2021, month: 8, day: 25))!
        let thu = calendar.date(from: DateComponents(year: 2021, month: 8, day: 26))!
        let fri = calendar.date(from: DateComponents(year: 2021, month: 8, day: 27))!
        let sat = calendar.date(from: DateComponents(year: 2021, month: 8, day: 28))!        
        XCTAssertEqual(fsCalendar.getWeekIdx(sun), 0) // 日曜日
        XCTAssertEqual(fsCalendar.getWeekIdx(mon), 1) // 月曜日
        XCTAssertEqual(fsCalendar.getWeekIdx(tue), 2) // 火曜日
        XCTAssertEqual(fsCalendar.getWeekIdx(wed), 3) // 水曜日
        XCTAssertEqual(fsCalendar.getWeekIdx(thu), 4) // 木曜日
        XCTAssertEqual(fsCalendar.getWeekIdx(fri), 5) // 金曜日
        XCTAssertEqual(fsCalendar.getWeekIdx(sat), 6) // 土曜日
    }
    
    func testLayoutCalendar() {
        fsCalendar.layoutCalendar()
        XCTAssertEqual(fsCalendar.calendarWeekdayView.weekdayLabels[0].textColor, UIColor.red)   // 日曜日
        XCTAssertEqual(fsCalendar.calendarWeekdayView.weekdayLabels[1].textColor, UIColor.black) // 月曜日
        XCTAssertEqual(fsCalendar.calendarWeekdayView.weekdayLabels[2].textColor, UIColor.black) // 火曜日
        XCTAssertEqual(fsCalendar.calendarWeekdayView.weekdayLabels[3].textColor, UIColor.black) // 水曜日
        XCTAssertEqual(fsCalendar.calendarWeekdayView.weekdayLabels[4].textColor, UIColor.black) // 木曜日
        XCTAssertEqual(fsCalendar.calendarWeekdayView.weekdayLabels[5].textColor, UIColor.black) // 金曜日
        XCTAssertEqual(fsCalendar.calendarWeekdayView.weekdayLabels[6].textColor, UIColor.blue)  // 土曜日
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
