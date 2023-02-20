//
//  DayViewModel.swift
//  Cloudy
//
//  Created by Bart Jacobs on 21/05/2020.
//  Copyright © 2020 Cocoacasts. All rights reserved.
//

import UIKit

struct DayViewModel {

    // MARK: - Properties

    let weatherData: WeatherData
    
    // MARK: -

    private let dateFormatter = DateFormatter()

    // MARK: - Public API
    
    var date: String {
        // Configure Date Formatter
        dateFormatter.dateFormat = "EEE, MMMM d"

        return dateFormatter.string(from: weatherData.time)
    }
    
    var time: String {
        // Configure Date Formatter
        dateFormatter.dateFormat = UserDefaults.timeNotation.dateFormat

        return dateFormatter.string(from: weatherData.time)
    }
 
    var summary: String {
        weatherData.summary
    }

    var temperature: String {
        let temperature = weatherData.temperature
        
        switch UserDefaults.temperatureNotation {
        case .fahrenheit:
            return String(format: "%.1f °F", temperature)
        case .celsius:
            return String(format: "%.1f °C", temperature.toCelcius)
        }
    }
 
    var windSpeed: String {
        let windSpeed = weatherData.windSpeed

        switch UserDefaults.unitsNotation {
        case .imperial:
            return String(format: "%.f MPH", windSpeed)
        case .metric:
            return String(format: "%.f KPH", windSpeed.toKPH)
        }
    }

    var image: UIImage? {
        UIImage.imageForIcon(with: weatherData.icon)
    }
    
}
