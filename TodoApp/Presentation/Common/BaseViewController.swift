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
    private let networkUseCase: NetworkUseCase = NetworkUseCaseImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

//    func handlerError(
//        error: Error,
//        onAuthError: (() -> Void)? = nil,
//        onLocalDbError: (() -> Void)? = nil,
//        onAPIError: (() -> Void)? = nil,
//        onParseError: (() -> Void)? = nil,
//        onNetworkError: (() -> Void)? = nil,
//        onUnKnowError: (() -> Void)
//    ) {
//        switch error {
//        case DomainError.authError:
//            print("認証処理に失敗しました。")
//            onAuthError?()
//        case DomainError.localDbError:
//            print("ローカルDBの更新に失敗しました。再度サインインをお願いします。")
//            onLocalDbError?()
//        case DomainError.onAPIError(_):
//            print("通信処理に失敗しました。")
//            onAPIError?()
//        case DomainError.parseError:
//            print("変換に処理に失敗しました。")
//            onParseError?()
//        case DomainError.networkError:
//            print("インターネットへの接続に失敗しました。")
//            onNetworkError?()
//        case DomainError.unKnownError:
//            print("処理に失敗しました。")
//            onUnKnowError()
//        default:
//            onUnKnowError()
//            print("処理に失敗しました。")
//            break
//        }
//    }

    func showDialog(title: String, message: String, buttonTitle: String, completion: (() -> Void)? = nil) {
        let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { action in
            completion?()
        }))
        self.present(dialog,animated: true,completion: nil)
    }

    func sessionErrorDialog() {
        self.showDialog(
            title: R.string.localizable.sessionErrorTitle(),
            message: R.string.localizable.sessionErrorMessage(),
            buttonTitle: R.string.localizable.ok()
        )
    }

    func localDbErrorDialog() {
        self.showDialog(
            title: R.string.localizable.localDbErrorTitle(),
            message: R.string.localizable.localUserDBErrorMessage(),
            buttonTitle: R.string.localizable.ok()
        )
    }

    func tokenErrorDialog() {
        self.showDialog(
            title: R.string.localizable.tokenErrorTitle(),
            message:  R.string.localizable.tokenErrorMessage(),
            buttonTitle:  R.string.localizable.ok()
        )
    }

    func parseErrorDialog() {
        self.showDialog(
            title: R.string.localizable.dateParseErrorTitle(),
            message:  R.string.localizable.dateParseErrorMessage(),
            buttonTitle:  R.string.localizable.ok()
        )
    }

    func networkErrorDialog() {
        self.showDialog(
            title: R.string.localizable.networkErrorTitle(),
            message:  R.string.localizable.networkErrorMessage(),
            buttonTitle:  R.string.localizable.ok()
        )
    }

    func unKnowErrorDialog() {
        self.showDialog(
            title: R.string.localizable.unknownErrorTitle(),
            message:  R.string.localizable.unknownErrorMessage(),
            buttonTitle:  R.string.localizable.ok()
        )
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

    func isConnect(completion: () -> Void ) {
        if (networkUseCase.isConnect()) {
            completion()
        } else {
            // リフレッシュ時に固まることを防ぐためダイアログ表示を1秒遅らせる
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.handlerError(
//                    error: DomainError.networkError,
//                    onNetworkError: { self.networkErrorDialog() },
//                    onUnKnowError: { self.unKnowErrorDialog() })
//            }
        }
    }
}
