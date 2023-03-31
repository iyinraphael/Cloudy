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

    let weatherDataStatePublisher: AnyPublisher<WeatherDataState, Never>

    // MARK: -

    var loadingPublisher: AnyPublisher<Bool, Never> {
           weatherDataStatePublisher
               .map { $0.isLoading }
               .eraseToAnyPublisher()
       }

       var hasWeatherDataPublisher: AnyPublisher<Bool, Never> {
           weatherDataStatePublisher
               .map { $0.weatherData != nil }
               .eraseToAnyPublisher()
       }

       var hasWeatherDataErrorPublisher: AnyPublisher<Bool, Never> {
           weatherDataStatePublisher
               .map { $0.weatherDataError != nil }
               .eraseToAnyPublisher()
       }

    // MARK: - Public API
    
    var datePublisher: AnyPublisher<String?, Never> {
        let dateFormatter = DateFormatter()

        // Configure Date Formatter
        dateFormatter.dateFormat = "EEE, MMMM d"

        return weatherDataStatePublisher
            .compactMap { $0.weatherData }
            .map { dateFormatter.string(from: $0.time) }
            .eraseToAnyPublisher()
    }
    
    var timePublisher: AnyPublisher<String?, Never> {
        let dateFormatter = DateFormatter()

        // Configure Date Formatter
        dateFormatter.dateFormat = UserDefaults.timeNotation.dateFormat

        return weatherDataStatePublisher
            .compactMap { $0.weatherData }
            .map { dateFormatter.string(from: $0.time) }
            .eraseToAnyPublisher()
    }
 
    var summaryPublisher: AnyPublisher<String?, Never> {

        return weatherDataStatePublisher
            .compactMap { $0.weatherData }
            .map { $0.summary }
            .eraseToAnyPublisher()
    }

    var temperaturePublisher: AnyPublisher<String?, Never> {
        weatherDataStatePublisher
            .compactMap { $0.weatherData }
            .map {
                switch UserDefaults.temperatureNotation {
                case .fahrenheit:
                    return String(format: "%.1f °F", $0!.temperature)
                case .celsius:
                    return String(format: "%.1f °C", $0!.temperature.toCelcius)
                }
            }
            .eraseToAnyPublisher()
    }
 
    var windSpeedPublisher: AnyPublisher<String?, Never> {
        weatherDataStatePublisher
            .compactMap { $0.weatherData }
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
        weatherDataStatePublisher
            .compactMap { $0.weatherData }
            .map {  UIImage.imageForIcon(with: $0.icon) }
            .eraseToAnyPublisher()
    }
    
}
