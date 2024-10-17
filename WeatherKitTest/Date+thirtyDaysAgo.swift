//
//  Date+thirtyDaysAgo.swift
//  WeatherKitTest
//
//  Created by 能登 要 on 2024/10/17.
//

import Foundation

extension Date {
    static var thirtyDaysAgo: Date {
        return Calendar.current.date(byAdding: .day, value: -30, to: .now)!
    }
}

