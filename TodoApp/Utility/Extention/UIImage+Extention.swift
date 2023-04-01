//
//  UIImage+Extention.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/04/01.
//

import Foundation
import UIKit

extension UIImage {
    func resize(size resizedSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
