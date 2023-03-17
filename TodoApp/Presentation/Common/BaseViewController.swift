//
//  BaseViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/09.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func handlerError(error: Error, onDomainErrorHandler: () -> Void) {
        switch error {
        case DomainError.authError:
            print("認証処理に失敗しました。")
        case DomainError.localDBError:
            print("ローカルDBの更新に失敗しました。再度サインインをお願いします。")
        case DomainError.unownedError:
            print("処理に失敗しました。")
        case DomainError.unacceptableAPIResultError(_):
            print("")
        default:
            break
        }
        onDomainErrorHandler()
    }
}
