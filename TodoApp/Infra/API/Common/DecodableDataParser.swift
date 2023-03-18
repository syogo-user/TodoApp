//
//  DecodableDataParser.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/17.
//

import Foundation
import APIKit

final class DecodableDataParser: DataParser {
    var contentType: String? {
        "application/json"
    }

    func parse(data: Data) throws -> Any {
        data
    }
}
