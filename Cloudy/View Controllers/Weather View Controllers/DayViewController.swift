//
//  DayViewController.swift
//  Cloudy
//
//  Created by Bart Jacobs on 01/10/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit
import Combine

protocol DayViewControllerDelegate: AnyObject {
    func controllerDidTapSettingsButton(controller: DayViewController)
    func controllerDidTapLocationButton(controller: DayViewController)
}

final class DayViewController: WeatherViewController {

    // MARK: - Properties

    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var windSpeedLabel: UILabel!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!

    // MARK: -

    weak var delegate: DayViewControllerDelegate?
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup Bindings
        setupBindings()

        //Update View
        updateView()
    }

    var viewModel: DayViewModel?

    // MARK: - Public Interface

    override func reloadData() {
        updateView()
    }

    // MARK: - View Methods

    private func updateView() {
        messageLabel.text = "Cloudy was unable to fetch weather data."
    }

    // MARK: -

    private func setupBindings() {
        viewModel?.datePublisher
            .assign(to: \.text, on: dateLabel)
            .store(in: &subscriptions)

        viewModel?.timePublisher
            .assign(to: \.text, on: timeLabel)
            .store(in: &subscriptions)

        viewModel?.summaryPublisher
            .assign(to: \.text, on: descriptionLabel)
            .store(in: &subscriptions)

        viewModel?.temperaturePublisher
            .assign(to: \.text, on: temperatureLabel)
            .store(in: &subscriptions)

        viewModel?.windSpeedPublisher
            .assign(to: \.text, on: windSpeedLabel)
            .store(in: &subscriptions)

        viewModel?.imagePublisher
            .assign(to: \.image, on: iconImageView)
            .store(in: &subscriptions)

        viewModel?.loadingPublisher
            .map { !$0 }
            .assign(to: \.isHidden, on: activityIndicatorView)
            .store(in: &subscriptions)

        viewModel?.hasWeatherDataPublisher
            .map { !$0 }
            .assign(to: \.isHidden, on: weatherDataContainerView)
            .store(in: &subscriptions)

        viewModel?.hasWeatherDataErrorPublisher
            .map { !$0 }
            .assign(to: \.isHidden, on: messageLabel)
            .store(in: &subscriptions)
    }

    // MARK: - Actions

    @IBAction private func didTapSettingsButton(_ sender: UIButton) {
        delegate?.controllerDidTapSettingsButton(controller: self)
    }

    @IBAction private func didTapLocationButton(_ sender: UIButton) {
        delegate?.controllerDidTapLocationButton(controller: self)
    }

}
