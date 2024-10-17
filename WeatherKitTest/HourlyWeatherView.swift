//
//  HourlyWeatherView.swift
//  WeatherKitTest
//
//  Created by 能登 要 on 2024/10/17.
//

import SwiftUI
import CoreLocation
import WeatherKit
import Charts

struct TemperaturesFor24HourItem: Identifiable {
    var id: Date {
        date
    }
    
    let date: Date
    let temperature: Double
}

struct HourlyWeatherView: View {
    let location: CLLocation
    
    @State var temperature: String = ""
    @State var uvIndex: String = ""
    @State var weatherCondition: String = ""
    
    @State var temperaturesFor24Hour: [TemperaturesFor24HourItem] = .init()

    var body: some View {
        VStack {
            Text("気温:") .font(.headline)
            Chart(temperaturesFor24Hour) { item in
                       LineMark(
                            x: .value("date", item.date),
                            y: .value("temperature", item.temperature)
                       )
                   }
                   .chartYScale(domain: -10...44)
                   .chartYAxisLabel(position: .trailing, alignment: .center, spacing: 10) {
                       Text("気温")
                           .font(.system(size: 15, weight: .bold))
                   }
                   .chartXAxis {
                       AxisMarks(values: .automatic)
                   }
        }
        .task {
            let weatherService = WeatherService()
            let temperatures = try! await weatherService.weather(
                                                        for: location,
                                                        including: .hourly
                                                    )
            temperaturesFor24Hour = temperatures[0..<24].map{
                TemperaturesFor24HourItem(date: $0.date, temperature: $0.temperature.value)
            }
        }
    }
}

#Preview {
    WeatherView(location: CLLocation.sapporo)
}

