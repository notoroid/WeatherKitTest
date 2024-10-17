//
//  Date+isTomorrow.swift
//  WeatherKitTest
//
//  Created by 能登 要 on 2024/10/17.
//

import Foundation

extension Date {
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
}
