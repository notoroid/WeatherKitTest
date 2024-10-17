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

enum WetherType {
    case currentWeather
    case hourly
}

struct ContentView: View {
    @Environment(LocationManager.self) private var locationManager

    @State var errorMessage: String = ""
    @State var showErrorAlert: Bool = false
    @State var locationType = LocationType.sapporo
    
    @State private var selectedWetherType: WetherType = .hourly

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

            Picker("天気情報", selection: $selectedWetherType, content: {
                            Text("現在の気温").tag(WetherType.currentWeather)
                            Text("24時間予報(iOS18 〜)").tag(WetherType.hourly)
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
                    
                    switch selectedWetherType {
                    case .currentWeather: WeatherView(location: location)
                    case .hourly: HourlyWeatherView(location: location)
                    }
                    
                    Spacer()
                }
            } else {
                switch locationType {
                case .sapporo:
                    switch selectedWetherType {
                        case .currentWeather: WeatherView(location: locationType.location!)
                        case .hourly: HourlyWeatherView(location: locationType.location!)
                    }
                    Spacer()
                case .tokyo:
                    switch selectedWetherType {
                        case .currentWeather: WeatherView(location: locationType.location!)
                        case .hourly: HourlyWeatherView(location: locationType.location!)
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
