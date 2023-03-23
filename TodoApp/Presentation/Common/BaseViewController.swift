//
//  BaseViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/09.
//

import Foundation
import UIKit
import MBProgressHUD

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
        case DomainError.unacceptableResultCode(_):
            print("")
        default:
            break
        }
        onDomainErrorHandler()
    }

    func setIndicator(show: Bool, animated: Bool = true) {
        let view: UIView = self.navigationController?.view ?? self.view
        if show {
            if let hud = MBProgressHUD.forView(view) {
                hud.show(animated: animated)
                hud.minShowTime = Constants.minShowTimeLoading
            } else {
                let hudShow = MBProgressHUD.showAdded(to: view, animated: animated)
                hudShow.minShowTime = Constants.minShowTimeLoading
            }
        } else {
            MBProgressHUD.hide(for: view, animated: animated)
        }
    }
}
