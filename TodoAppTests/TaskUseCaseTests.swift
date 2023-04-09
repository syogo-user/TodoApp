//
//  TaskUseCaseTest.swift
//  TodoAppTests
//
//  Created by 小野寺祥吾 on 2023/03/30.
//

import XCTest
@testable import TodoApp
import RxSwift
import RxTest
import RxBlocking


class TaskUseCaseTests: XCTestCase {

    var useCase: TaskUseCaseImpl!
    var repository: TaskRepositoryMock!

    override func setUp() {
        super.setUp()
        repository = TaskRepositoryMock()
        useCase = TaskUseCaseImpl(repository: repository)
    }

    func testFetchTask() {
        // Arrange
        let expectedTask = TaskListAPI.Response.Task(taskId: "1", title: "Test Task", content: "Test Content", scheduledDate: Date().dateFormat(), isCompleted: true, isFavorite: false, userId: "0123456789")

        let response = TaskListAPI.Response(message: "OK", data: [expectedTask])
        repository.fetchTaskResult = .success(response)

        // Act
        let result = try! useCase.fetchTask(userId: expectedTask.userId, authorization: "")
                    .toBlocking(timeout: 1000.0)
                    .single()
        // Assert
        XCTAssertEqual(result.count, 1)
        let resultTask = result.first!
        XCTAssertEqual(resultTask.taskId, expectedTask.taskId)
        XCTAssertEqual(resultTask.title, expectedTask.title)
        XCTAssertEqual(resultTask.content, expectedTask.content)
        XCTAssertEqual(resultTask.scheduledDate.dateFormat(), expectedTask.scheduledDate)
        XCTAssertEqual(resultTask.isCompleted, expectedTask.isCompleted)
        XCTAssertEqual(resultTask.isFavorite,expectedTask.isFavorite)
        XCTAssertEqual(resultTask.userId, expectedTask.userId)
    }

    func testAddTask() {
        // Arrange
        let expectedTask = AddTaskAPI.Response.Task(taskId: "1", title: "Test Task", content: "Test Content", scheduledDate: Date().dateFormat(), isCompleted: true, isFavorite: false, userId: "0123456789")

        let response = AddTaskAPI.Response(message: "OK", data: expectedTask)
        repository.addTaskResult = .success(response)

        // Act
        let result = try! useCase.addTask(title: expectedTask.title, content: expectedTask.content, scheduledDate: expectedTask.scheduledDate, isCompleted: expectedTask.isCompleted, isFavorite: expectedTask.isFavorite, userId: expectedTask.userId, authorization: "").toBlocking().single()

        // Assert
        XCTAssertEqual(result.taskId, expectedTask.taskId)
        XCTAssertEqual(result.title, expectedTask.title)
        XCTAssertEqual(result.content, expectedTask.content)
        XCTAssertEqual(result.scheduledDate.dateFormat(), expectedTask.scheduledDate)
        XCTAssertEqual(result.isCompleted, expectedTask.isCompleted)
        XCTAssertEqual(result.isFavorite, expectedTask.isFavorite)
        XCTAssertEqual(result.userId, expectedTask.userId)
    }

    func testUpdateTask() {
        // Arrange
        let expectedTask = UpdateTaskAPI.Response.Task(taskId: "1", title: "Test Task", content: "Test Content", scheduledDate: Date().dateFormat(), isCompleted: true, isFavorite: false, userId: "0123456789")

        let response = UpdateTaskAPI.Response(message: "OK", data: expectedTask)
        repository.updateTaskResult = .success(response)

        // Act
        let result = try! useCase.updateTask(taskId: expectedTask.taskId, title: expectedTask.title, content: expectedTask.content, scheduledDate: expectedTask.scheduledDate, isCompleted: expectedTask.isCompleted, isFavorite: expectedTask.isFavorite, userId: expectedTask.userId, authorization: "").toBlocking().single()

        // Assert
        XCTAssertEqual(result.taskId, expectedTask.taskId)
        XCTAssertEqual(result.title, expectedTask.title)
        XCTAssertEqual(result.content, expectedTask.content)
        XCTAssertEqual(result.scheduledDate.dateFormat(), expectedTask.scheduledDate)
        XCTAssertEqual(result.isCompleted, expectedTask.isCompleted)
        XCTAssertEqual(result.isFavorite, expectedTask.isFavorite)
        XCTAssertEqual(result.userId, expectedTask.userId)
    }

    func testDeleteTask() {
        // Arrange
        let expectedTask = DeleteTaskAPI.Response.Task(taskId: "1")

        let response = DeleteTaskAPI.Response(message: "OK", data: expectedTask)
        repository.deleteTaskResult = .success(response)

        // Act
        let result = try! useCase.deleteTask(taskId: expectedTask.taskId, authorization: "").toBlocking().single()

        // Assert
        XCTAssertEqual(result, expectedTask.taskId)
    }

    func testLoadTaskList() {
        // Arrange
        let expectedTask = TaskInfoRecord(taskId: "1", title: "Test Task", content: "Test Content", scheduledDate: Date(), isCompleted: true, isFavorite: false, userId: "0123456789")

        repository.loadLocalTaskListResult = .success([expectedTask])

        // Act
        let result = try! useCase.loadLocalTaskList()
                    .toBlocking(timeout: 1000.0)
                    .single()
        // Assert
        XCTAssertEqual(result.count, 1)
        let resultTask = result.first!
        XCTAssertEqual(resultTask.taskId, expectedTask.taskId)
        XCTAssertEqual(resultTask.title, expectedTask.title)
        XCTAssertEqual(resultTask.content, expectedTask.content)
        XCTAssertEqual(resultTask.scheduledDate, expectedTask.scheduledDate)
        XCTAssertEqual(resultTask.isCompleted, expectedTask.isCompleted)
        XCTAssertEqual(resultTask.isFavorite,expectedTask.isFavorite)
        XCTAssertEqual(resultTask.userId, expectedTask.userId)
    }

    func testInsertLocalTask() {
        // Arrange
        let expectedTask = TaskInfoRecord(taskId: "1", title: "Test Task", content: "Test Content", scheduledDate: Date(), isCompleted: true, isFavorite: false, userId: "0123456789")

        repository.insertLocalTaskResult = .success(())

        // Act
        let result = useCase.insertLocalTask(taskInfo: expectedTask)
                    .toBlocking(timeout: 1000.0)
                    .materialize()
        // Assert
        switch result {
        case .completed(elements: _): break

        case .failed:
            XCTFail("Unexpected Error")
        }
    }

    func testInsertLocalTaskList() {
        // Arrange
        let expectedTask = TaskInfoRecord(taskId: "1", title: "Test Task", content: "Test Content", scheduledDate: Date(), isCompleted: true, isFavorite: false, userId: "0123456789")

        repository.insertLocalTaskListResult = .success(())

        // Act
        let result = useCase.insertLocalTaskList(taskInfoList: [expectedTask])
                    .toBlocking(timeout: 1000.0)
                    .materialize()
        // Assert
        switch result {
        case .completed(elements: _): break

        case .failed:
            XCTFail("Unexpected Error")
        }
    }

    func testUpdateLocalTask() {
        // Arrange
        let expectedTask = TaskInfoRecord(taskId: "1", title: "Test Task", content: "Test Content", scheduledDate: Date(), isCompleted: true, isFavorite: false, userId: "0123456789")

        repository.updateLocalTaskResult = .success(())

        // Act
        let result = useCase.updateLocalTask(taskInfo: expectedTask)
                    .toBlocking(timeout: 1000.0)
                    .materialize()
        // Assert
        switch result {
        case .completed(elements: _): break

        case .failed:
            XCTFail("Unexpected Error")
        }
    }

    func testDeleteLocalTask() {
        // Arrange
        let expectedTaskId = "1"

        repository.deleteLocalTaskResult = .success(())

        // Act
        let result = useCase.deleteLocalTask(taskId: expectedTaskId)
                    .toBlocking(timeout: 1000.0)
                    .materialize()
        // Assert
        switch result {
        case .completed(elements: _): break

        case .failed:
            XCTFail("Unexpected Error")
        }
    }

    func testDeleteLocalTaskAll() {
        // Arrange
        repository.deleteLocalTaskAllResult = .success(())

        // Act
        let result = useCase.deleteLocalTaskAll()
                    .toBlocking(timeout: 1000.0)
                    .materialize()
        // Assert
        switch result {
        case .completed(elements: _): break

        case .failed:
            XCTFail("Unexpected Error")
        }
    }

    func testDeleteLocalTaskList() {
        let expectedTaskIdList = ["1", "2"]
        // Arrange
        repository.deleteLocalTaskListResult = .success(())

        // Act
        let result = useCase.deleteLocalTaskList(taskIdList: expectedTaskIdList)
                    .toBlocking(timeout: 1000.0)
                    .materialize()
        // Assert
        switch result {
        case .completed(elements: _): break

        case .failed:
            XCTFail("Unexpected Error")
        }
    }
    
    func testSortAscendingOrderDate() {
        var itemList = [
            TaskInfo(taskId: "1", title: "1番目", content: "", scheduledDate: Date(), isCompleted: false, isFavorite: false, userId: "0123456789"),
            TaskInfo(taskId: "2", title: "2番目", content: "", scheduledDate: Date().addingTimeInterval(3600), isCompleted: false, isFavorite: false, userId: "0123456789"),
            TaskInfo(taskId: "3", title: "3番目", content: "", scheduledDate: Date().addingTimeInterval(-3600), isCompleted: false, isFavorite: false, userId: "0123456789"),
            TaskInfo(taskId: "4", title: "4番目", content: "", scheduledDate: Date().addingTimeInterval(7000), isCompleted: false, isFavorite: false, userId: "0123456789"),
            TaskInfo(taskId: "5", title: "5番目", content: "", scheduledDate: Date().addingTimeInterval(-7000), isCompleted: false, isFavorite: false, userId: "0123456789"),
        ]
        useCase.sortTask(itemList: &itemList, sort: Sort.ascendingOrderDate.rawValue)
        XCTAssertEqual(itemList.map { $0.taskId }, ["5", "3", "1", "2", "4"])
    }
    
    func testSortDescendingOrderDate() {
        var itemList = [
            TaskInfo(taskId: "1", title: "1番目", content: "", scheduledDate: Date(), isCompleted: false, isFavorite: false, userId: "0123456789"),
            TaskInfo(taskId: "2", title: "2番目", content: "", scheduledDate: Date().addingTimeInterval(3600), isCompleted: false, isFavorite: false, userId: "0123456789"),
            TaskInfo(taskId: "3", title: "3番目", content: "", scheduledDate: Date().addingTimeInterval(-3600), isCompleted: false, isFavorite: false, userId: "0123456789"),
            TaskInfo(taskId: "4", title: "4番目", content: "", scheduledDate: Date().addingTimeInterval(7000), isCompleted: false, isFavorite: false, userId: "0123456789"),
            TaskInfo(taskId: "5", title: "5番目", content: "", scheduledDate: Date().addingTimeInterval(-7000), isCompleted: false, isFavorite: false, userId: "0123456789"),
        ]
        useCase.sortTask(itemList: &itemList, sort: Sort.descendingOrderDate.rawValue)
        XCTAssertEqual(itemList.map { $0.taskId }, ["4", "2", "1", "3", "5"])
    }
    
}

class TaskRepositoryMock: TaskRepository {
    var sortOrder: String?
    var filterCondition: String?
    var fetchTaskResult: Result<TaskListAPI.Response, Error>!
    var addTaskResult: Result<AddTaskAPI.Response, Error>!
    var updateTaskResult: Result<UpdateTaskAPI.Response, Error>!
    var deleteTaskResult: Result<DeleteTaskAPI.Response, Error>!
    var loadLocalTaskListResult: Result<[TaskInfoRecord], Error>!
    var insertLocalTaskResult: Result<Void, Error>!
    var insertLocalTaskListResult: Result<Void, Error>!
    var updateLocalTaskResult: Result<Void, Error>!
    var deleteLocalTaskResult: Result<Void, Error>!
    var deleteLocalTaskAllResult: Result<Void, Error>!
    var deleteLocalTaskListResult: Result<Void, Error>!

    func fetchTask(userId: String, authorization: String) -> Single<TaskListAPI.Response> {
        switch fetchTaskResult {
        case .success(let taskInfo):
            return Single.just(taskInfo)
        case .failure(let error):
            return Single.error(error)
        case .none:
            fatalError("fatalError")
        }
    }

    func addTask(title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<AddTaskAPI.Response> {
        switch addTaskResult {
        case .success(let taskInfo):
            return Single.just(taskInfo)
        case .failure(let error):
            return Single.error(error)
        case .none:
            fatalError("fatalError")
        }
    }

    func updateTask(taskId: String, title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<UpdateTaskAPI.Response> {
        switch updateTaskResult {
        case .success(let taskInfo):
            return Single.just(taskInfo)
        case .failure(let error):
            return Single.error(error)
        case .none:
            fatalError("fatalError")
        }
    }

    func deleteTask(taskId: String, authorization: String) -> Single<DeleteTaskAPI.Response> {
        switch deleteTaskResult {
        case .success(let taskInfo):
            return Single.just(taskInfo)
        case .failure(let error):
            return Single.error(error)
        case .none:
            fatalError("fatalError")
        }
    }

    func loadLocalTaskList() -> Single<[TaskInfoRecord]> {
        switch loadLocalTaskListResult {
        case .success(let taskInfo):
            return Single.just(taskInfo)
        case .failure(let error):
            return Single.error(error)
        case .none:
            fatalError("fatalError")
        }
    }

    func insertLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
        switch insertLocalTaskResult {
        case .success(let taskInfo):
            return Single.just(taskInfo)
        case .failure(let error):
            return Single.error(error)
        case .none:
            fatalError("fatalError")
        }
    }

    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) -> Single<Void> {
        switch insertLocalTaskListResult {
        case .success(let taskInfo):
            return Single.just(taskInfo)
        case .failure(let error):
            return Single.error(error)
        case .none:
            fatalError("fatalError")
        }
    }

    func updateLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
        switch updateLocalTaskResult {
        case .success(let taskInfo):
            return Single.just(taskInfo)
        case .failure(let error):
            return Single.error(error)
        case .none:
            fatalError("fatalError")
        }
    }

    func deleteLocalTask(taskId: String) -> Single<Void> {
        switch deleteLocalTaskResult {
        case .success(let taskInfo):
            return Single.just(taskInfo)
        case .failure(let error):
            return Single.error(error)
        case .none:
            fatalError("fatalError")
        }
    }

    func deleteLocalTaskAll() -> Single<Void> {
        switch deleteLocalTaskAllResult {
        case .success(let taskInfo):
            return Single.just(taskInfo)
        case .failure(let error):
            return Single.error(error)
        case .none:
            fatalError("fatalError")
        }
    }

    func deleteLocalTaskList(taskIdList: [String]) -> Single<Void> {
        switch deleteLocalTaskListResult {
        case .success(let taskInfo):
            return Single.just(taskInfo)
        case .failure(let error):
            return Single.error(error)
        case .none:
            fatalError("fatalError")
        }
    }
}
