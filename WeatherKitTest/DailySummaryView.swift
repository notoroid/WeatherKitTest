//
//  DailySummaryView.swift
//  WeatherKitTest
//
//  Created by 能登 要 on 2024/10/17.
//

import SwiftUI
import CoreLocation
import WeatherKit


struct DailySummaryView: View {
    let location: CLLocation
    
    @State var precipitationAmount: String = ""
    @State var snowfallAmount: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(precipitationAmount)")
            Text("\(snowfallAmount)")
            Spacer()
        }
        .task {
            let pastThirtyDaysSummary = try! await WeatherService()
                .dailySummary(
                    for: location,
                   forDaysIn: DateInterval(start: .thirtyDaysAgo, end: .now),
                   including: .precipitation
                )
                .first

            if let pastThirtyDaysSummary {
                precipitationAmount = "降雨量:\( String(format: "%.2f",pastThirtyDaysSummary.precipitationAmount.value)))"
                snowfallAmount = "降雪量:\( String(format: "%.2f",pastThirtyDaysSummary.snowfallAmount.value)))"
            }
        }
    }
}

#Preview {
    DailySummaryView(location: .sapporo)
}
