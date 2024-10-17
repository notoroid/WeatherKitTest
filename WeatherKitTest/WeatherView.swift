//
//  WeatherView.swift
//  WeatherKitTest
//
//  Created by 能登 要 on 2024/10/17.
//

import SwiftUI
import CoreLocation
import WeatherKit

struct WeatherView: View {
    let location: CLLocation
    
    @State var temperature: String = ""
    @State var uvIndex: String = ""
    @State var weatherCondition: String = ""

    var body: some View {
        VStack {
            Text("気温:\(temperature)").font(.title)
            Text("UI指数:\(uvIndex)").font(.title)
            Text("天候:\(weatherCondition)").font(.title)
        }
        .task {
            let weatherService = WeatherService()
            let weather = try! await weatherService.weather(for: location)
            
            let temperatureDescription = String(format: "%.2f", weather.currentWeather.temperature.value)
            temperature = "\(temperatureDescription)"

            switch weather.currentWeather.uvIndex.category {
                case .low:
                    uvIndex = "低い (\(weather.currentWeather.uvIndex.value))"
                case .moderate:
                    uvIndex = "適度 (\(weather.currentWeather.uvIndex.value))"
                case .high:
                    uvIndex = "高い (\(weather.currentWeather.uvIndex.value))"
                case .veryHigh:
                    uvIndex = "とても高い (\(weather.currentWeather.uvIndex.value))"
                case .extreme:
                    uvIndex = "危険な高さ (\(weather.currentWeather.uvIndex.value))"
            }
            weatherCondition = weather.currentWeather.condition.description
        }
    }
}

#Preview {
    WeatherView(location: CLLocation.sapporo)
}
