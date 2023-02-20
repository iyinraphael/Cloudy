//
//  WeekViewModel.swift
//  Cloudy
//
//  Created by Bart Jacobs on 27/05/2020.
//  Copyright © 2020 Cocoacasts. All rights reserved.
//

import UIKit

struct WeekViewModel {

    // MARK: - Properties

    let weatherData: [WeatherDayData]

    // MARK: - Public API

    var numberOfSections: Int {
        1
    }

    var numberOfDays: Int {
        weatherData.count
    }
    
    func viewModel(for index: Int) -> WeatherDayViewModel {
        WeatherDayViewModel(weatherDayData: weatherData[index])
    }

}
