//
//  WeatherKitTestApp.swift
//  WeatherKitTest
//
//  Created by 能登 要 on 2022/06/20.
//

import SwiftUI

@main
struct WeatherKitTestApp: App {
    let locationManager: LocationManager = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView(locationManager: locationManager)
        }
    }
}
