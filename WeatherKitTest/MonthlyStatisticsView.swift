//
//  MonthlyStatisticsView.swift
//  WeatherKitTest
//
//  Created by 能登 要 on 2024/10/17.
//

import SwiftUI
import CoreLocation
import WeatherKit

struct MonthlyStatisticsView: View {
    let location: CLLocation
    
    @State var information: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(information)")
            Spacer()
        }
        .task {
            let averagePrecipitation = try! await WeatherService()
                .monthlyStatistics(
                    for: location,
                    startMonth: 1,
                    endMonth: 12,
                    including: .precipitation
                )
            let averagePrecipitationAmountsPerMonth = Dictionary(
                grouping: averagePrecipitation,
                by: \.month
            )
            
            information = averagePrecipitationAmountsPerMonth.description
            
        }
    }
}

#Preview {
    MonthlyStatisticsView(location: CLLocation.sapporo)
}
