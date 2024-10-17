//
//  HistoricalComparisonsView.swift
//  WeatherKitTest
//
//  Created by 能登 要 on 2024/10/17.
//

import SwiftUI
import CoreLocation
import WeatherKit

struct HistoricalComparisonsView: View {
    let location: CLLocation
    
    @State var information: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(information)")
                .font(.title)
            Spacer()
        }
        .task {
            let mostSignificant = try! await WeatherService()
                .weather(for: location, including: .historicalComparisons)?
                .first
            switch mostSignificant {
            case .lowTemperature(let trend), .highTemperature(let trend):
                
                let deviationDescription = switch trend.deviation {
                case .muchHigher: "より高い"
                case .higher: "高い"
                case .normal: "普通"
                case .lower: "低い"
                case .muchLower: "より低い"
                @unknown default: "不明"
                }
                information = "過去と比べ、" + deviationDescription
            case .some, .none:
                break
            }
        }
    }
    
}

#Preview {
    HistoricalComparisonsView(location: CLLocation.sapporo)
}
