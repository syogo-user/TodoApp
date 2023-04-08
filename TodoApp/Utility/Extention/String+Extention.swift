//
//  String+Extention.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/21.
//

import Foundation

public extension String {

    func isConvertibleDate() -> Bool {
        let format = DateFormatter()
        format.locale = Locale(identifier: "en_US_POSIX")
        format.dateFormat = "yyyyMMddHHmm"
        if format.date(from: self) != nil {
            return true
        } else {
            return false
        }
    }

    func toDate() throws -> Date {
        let format = DateFormatter()
        format.locale = Locale(identifier: "en_US_POSIX")
        format.dateFormat = "yyyyMMddHHmm"
        guard let date = format.date(from: self) else {
            throw DomainError.parseError
        }
        return date
    }

    func dateJpFormat() -> String {
        let (year, month, day, hour, minute) = self.dateTimeTupleFormat()
        return  "\(year)年\(month)月\(day)日 \(hour)時\(minute)分"
    }

    func dateTimeTupleFormat() -> (String, String, String, String, String) {
        let datePart = String(self.prefix(8))
        let timePart = String(self.suffix(4))
        let year = String(datePart.prefix(4))
        let month = String(datePart.dropFirst(4).prefix(2))
        let day = String(datePart.dropFirst(6).prefix(2))
        let hour = String(timePart.prefix(2))
        let minute = String(timePart.suffix(2))
        return (year, month, day, hour, minute)
    }

}
