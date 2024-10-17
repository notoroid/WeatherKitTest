//
//  WeatherChangesView.swift
//  WeatherKitTest
//
//  Created by 能登 要 on 2024/10/17.
//

import SwiftUI
import CoreLocation
import WeatherKit

struct WeatherChangesView: View {
    let location: CLLocation
    
    @State var lowTemperatureInformation: String = "なし"
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(lowTemperatureInformation)")
                .font(.title)
            Spacer()
        }
        .task {
            let changes = try! await WeatherService()
                .weather(for: location, including: .changes)
            
            let lowTemperatureChanges = changes?
                .filter(\.date.isTomorrow)
                .map(\.lowTemperature)
            
            if let lowTemperatureChanges, lowTemperatureChanges.contains(.decrease) {
                lowTemperatureInformation = "明日の温度:低下の恐れ"
            }
            
            if let lowTemperatureChanges, lowTemperatureChanges.contains(.steady) {
                lowTemperatureInformation = "明日の温度:落ち着いた状況で推移"
            }
        }
    }
}

#Preview {
    WeatherChangesView(location: CLLocation.sapporo)
}
