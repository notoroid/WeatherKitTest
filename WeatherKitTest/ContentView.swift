//
//  ContentView.swift
//  WeatherKitTest
//
//  Created by 能登 要 on 2022/06/20.
//

import SwiftUI
import WeatherKit
import CoreLocation

enum LocationType: Int, Identifiable {
    var id: Int { self.rawValue }
    
    case here = 0
    case sapporo = 1
    case tokyo = 2
    
    var description: String {
        switch self {
        case .here: "現在地"
        case .sapporo: "札幌"
        case .tokyo: "東京"
        }
    }
    var imageSystemName: String {
        switch self {
        case .here: "location.fill"
        default: "bookmark.fill"
        }
    }
    
    var location: CLLocation? {
        switch self {
        case .here: nil
        case .sapporo: CLLocation.sapporo
        case .tokyo: CLLocation.tokyo
        }
    }
}

struct CircleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundStyle(.black)
  }
}

enum WeatherType {
    case currentWeather
    case hourly
    case weatherChanges
    case historicalComparisons
//    case monthlyStatistics
    case dailySummary
}

struct ContentView: View {
    @Environment(LocationManager.self) private var locationManager

    @State var errorMessage: String = ""
    @State var showErrorAlert: Bool = false
    @State var locationType = LocationType.sapporo
    
    @State private var selectedWeatherType: WeatherType = .hourly

    var body: some View {
        VStack {
            HStack {
                ForEach([LocationType.here,LocationType.sapporo,LocationType.tokyo]){ content in
                    Button {
                        locationType = content
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: content.imageSystemName)
                                .frame(width: 52, height: 52)
                                .foregroundColor(.white)
                                .background(
                                    locationType == content ? .blue : .gray
                                )
                                .cornerRadius(26)
                            Text(content.description)
                                .font(.system(size: 12, weight: .semibold))
                                .frame(width: 80)
                        }
                    }
                    .buttonStyle(CircleButtonStyle())
                }
            }

            Picker("天気情報", selection: $selectedWeatherType, content: {
                            Text("現在の気温").tag(WeatherType.currentWeather)
                            Text("24時間予報").tag(WeatherType.hourly)
                            Text("天候変化").tag(WeatherType.weatherChanges)
                            Text("過去平均値との比較").tag(WeatherType.historicalComparisons)
//                            Text("月間統計").tag(WeatherType.monthlyStatistics)
                            Text("3日概要").tag(WeatherType.dailySummary)
                        })
                        .pickerStyle(SegmentedPickerStyle()) // <1>
                        .padding(.horizontal)
            
            if locationType == .here {
                if !locationManager.currentLocation.active {
                    VStack {
                        Spacer()
                        Image(systemName: "location.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                        Text("位置情報取得中…")
                        Spacer()
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
                    let location: CLLocation = locationManager.currentLocation.location
                    
                    switch selectedWeatherType {
                    case .currentWeather: WeatherView(location: location)
                    case .hourly: HourlyWeatherView(location: location)
                    case .weatherChanges: WeatherChangesView(location: location)
                    case .historicalComparisons: HistoricalComparisonsView(location: location)
//                    case .monthlyStatistics: MonthlyStatisticsView(location: location)
                    case .dailySummary: DailySummaryView(location: location)
                    }
                    
                    Spacer()
                }
            } else {
                switch locationType {
                case .sapporo:
                    switch selectedWeatherType {
                    case .currentWeather: WeatherView(location: locationType.location!)
                    case .hourly: HourlyWeatherView(location: locationType.location!)
                    case .weatherChanges: WeatherChangesView(location: locationType.location!)
                    case .historicalComparisons: HistoricalComparisonsView(location: locationType.location!)
//                    case .monthlyStatistics: MonthlyStatisticsView(location: locationType.location!)
                    case .dailySummary: DailySummaryView(location: locationType.location!)
                    }
                    Spacer()
                case .tokyo:
                    switch selectedWeatherType {
                    case .currentWeather: WeatherView(location: locationType.location!)
                    case .hourly: HourlyWeatherView(location: locationType.location!)
                    case .weatherChanges: WeatherChangesView(location: locationType.location!)
                    case .historicalComparisons: HistoricalComparisonsView(location: locationType.location!)
//                    case .monthlyStatistics: MonthlyStatisticsView(location: locationType.location!)
                    case .dailySummary: DailySummaryView(location: locationType.location!)
                    }
                    Spacer()
                default:
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(LocationManager())
}
