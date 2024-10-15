//
//  ContentView.swift
//  WeatherKitTest
//
//  Created by 能登 要 on 2022/06/20.
//

import SwiftUI
import WeatherKit

struct ContentView: View {
    @Environment(LocationManager.self) private var locationManager

    @State var temperature: String = ""
    @State var uvIndex: String = ""
    @State var weatherCondition: String = ""
    @State var errorMessage: String = ""
    @State var showErrorAlert: Bool = false
    
    var body: some View {
        
        if !locationManager.currentLocation.active {
            VStack {
                Image(systemName: "location.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("位置情報取得中…")
            }.task {
                do {
                    try await locationManager.startCurrentLocation()
                } catch let error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }.alert(errorMessage, isPresented: $showErrorAlert) {
                Button("OK", role: .cancel, action: { errorMessage = ""})
            }
            
            
        } else {
            VStack {
                Text("気温:\(temperature)") .font(.largeTitle)
                Text("UI指数:\(uvIndex)").font(.title)
                Text("天候:\(weatherCondition)").font(.title)
            }
            .task {
                let weatherService = WeatherService()
                let currentLocation = locationManager.currentLocation
                let weather = try! await weatherService.weather(for: currentLocation.location)
                
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
}

#Preview {
    ContentView()
        .environment(LocationManager())
}
