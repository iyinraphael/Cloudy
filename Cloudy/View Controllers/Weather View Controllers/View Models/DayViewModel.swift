//
//  DayViewModel.swift
//  Cloudy
//
//  Created by Bart Jacobs on 21/05/2020.
//  Copyright © 2020 Cocoacasts. All rights reserved.
//

import UIKit
import Combine

struct DayViewModel {

    // MARK: - Properties

    let loadingPublisher: AnyPublisher<Bool, Never>
    let weatherDataPublisher: AnyPublisher<WeatherData, Never>
    let weatherDataErrorPublisher: AnyPublisher<WeatherDataError, Never>

    // MARK: -

    private let dateFormatter = DateFormatter()

    // MARK: - Public API
    
    var datePublisher: AnyPublisher<String?, Never> {
        let dateFormatter = DateFormatter()

        // Configure Date Formatter
        dateFormatter.dateFormat = "EEE, MMMM d"

        return weatherDataPublisher
            .map { dateFormatter.string(from: $0.time) }
            .eraseToAnyPublisher()
    }
    
    var timePublisher: AnyPublisher<String?, Never> {
        let dateFormatter = DateFormatter()

        // Configure Date Formatter
        dateFormatter.dateFormat = UserDefaults.timeNotation.dateFormat

        return weatherDataPublisher
            .map { dateFormatter.string(from: $0.time) }
            .eraseToAnyPublisher()
    }
 
    var summaryPublisher: AnyPublisher<String?, Never> {

        return weatherDataPublisher
            .map { $0.summary }
            .eraseToAnyPublisher()
    }

    var temperaturePublisher: AnyPublisher<String?, Never> {
        weatherDataPublisher
            .map {
                switch UserDefaults.temperatureNotation {
                case .fahrenheit:
                    return String(format: "%.1f °F", $0.temperature)
                case .celsius:
                    return String(format: "%.1f °C", $0.temperature.toCelcius)
                }
            }
            .eraseToAnyPublisher()
    }
 
    var windSpeedPublisher: AnyPublisher<String?, Never> {
        weatherDataPublisher
            .map {
                switch UserDefaults.unitsNotation {
                case .imperial:
                    return String(format: "%.f MPH", $0.windSpeed)
                case .metric:
                    return String(format: "%.f KPH", $0.windSpeed.toKPH)
                }
            }
            .eraseToAnyPublisher()
    }

    var imagePublisher: AnyPublisher<UIImage?, Never> {
        weatherDataPublisher
            .map {  UIImage.imageForIcon(with: $0.icon) }
            .eraseToAnyPublisher()
    }
    
}
