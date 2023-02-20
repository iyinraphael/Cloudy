//
//  SettingsTableViewCell.swift
//  Cloudy
//
//  Created by Bart Jacobs on 03/10/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit

final class SettingsTableViewCell: UITableViewCell {

    // MARK: - Properties

    @IBOutlet private var mainLabel: UILabel!

    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()

        // Configure Cell
        selectionStyle = .none
    }

    // MARK: - Public API
    
    func configure(with presentable: SettingsPresentable) {
        // Configure Main Label
        mainLabel.text = presentable.text
        
        // Set Accessory Type
        accessoryType = presentable.accessoryType
    }
    
}
