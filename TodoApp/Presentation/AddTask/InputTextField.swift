//
//  InputTextField.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/20.
//

import UIKit

@IBDesignable class InputTitleTextField: UITextField {

    @IBInspectable var padding: CGPoint = CGPoint(x: 10.0, y: 0.0)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        // テキストの内側に余白
        return bounds.insetBy(dx: self.padding.x, dy: self.padding.y)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        // 入力中のテキストの内側に余白
        return bounds.insetBy(dx: self.padding.x, dy: self.padding.y)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        // プレースホルダーの内側に余白
        return bounds.insetBy(dx: self.padding.x, dy: self.padding.y)
    }
}
