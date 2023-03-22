//
//  StringExtention.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/21.
//

import Foundation

extension String {
    // TODO: 
    /// yyyyMMdd → yyyy年MM月dd日 に変換
    func dateJpFormat() -> String {
        let (year, month, day) = self.dateTupleFormat()
        let str = "\(year)年\(month)月\(day)日"
        return str
    }

    /// yyyyMMdd → (yyyy, MM, dd)に変換
    func dateTupleFormat() -> (String, String, String) {
        let year = String(self.prefix(4))
        let startIndex = self.index(self.startIndex, offsetBy: 4)
        let endIndex = self.index(self.endIndex, offsetBy: -3)
        let month = String(self[startIndex...endIndex])
        let day = String(self.suffix(2))
        return (year, month, day)
    }

    func toDate() -> Date? {
        let (year, month, day) = self.dateTupleFormat()
        let calendar = Calendar.current
        let selectDate = calendar.date(from: DateComponents(year: Int(year), month: Int(month), day: Int(day)))
        return selectDate
    }
}
