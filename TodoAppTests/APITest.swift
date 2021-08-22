//
//  APITest.swift
//  TodoAppTests
//
//  Created by 小野寺祥吾 on 2021/08/22.
//

import XCTest
import Mockingjay
@testable import TodoApp

class APITest: XCTestCase {

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
    
    // タスクの取得をテスト
    func testGetTasks() {
        
        let body:[String:[String:Any]] = [
            "aaa":[
                "content":"SAP",
                "date":"20210822",
                "order":0,
                "title":"AWS勉強",
                "uid":"Q75sx5WGCaWMpR90KZCXRK989fI2"
            ],
            "bbb":[
                "content":"金フレ",
                "date":"20210822",
                "order":1,
                "title":"TOEIC勉強",
                "uid":"Q75sx5WGCaWMpR90KZCXRK989fI2"
            ]
        ]
        
        // スタブの定義　リクエストに対して常にbodyが返却される
        stub(everything,json(body))
        // APIが完了するまで待機
        let exp  = expectation(description: "wait for complete api")
        
        API.shared.getTasks(uid: "Q75sx5WGCaWMpR90KZCXRK989fI2", type: TaskList.self) { (item) in
            guard var tasks = item?.tasks else {return }
            // order順に並び替え
            tasks.sort{ (d0 ,d1) -> Bool in
                d0.order < d1.order
            }
            // 取得したタスクの件数が等しいこと
            XCTAssertEqual(tasks.count,2)
            // 取得したタスクの中身が等しいこと
            XCTAssertEqual(tasks[0], Task(taskId: "aaa", title: "AWS勉強", content: "SAP", uid: "Q75sx5WGCaWMpR90KZCXRK989fI2", date: "20210822", order: 0))
            XCTAssertEqual(tasks[1], Task(taskId: "bbb", title: "TOEIC勉強", content: "金フレ", uid: "Q75sx5WGCaWMpR90KZCXRK989fI2", date: "20210822", order: 1))
            
            // expの待機を解除
            exp.fulfill()
        }
        // 3秒でタイムアウトし、テスト失敗とする
        wait(for: [exp], timeout: 3)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
