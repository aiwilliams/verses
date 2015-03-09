//
//  SettingsSection.swift
//  verses
//
//  Created by Isaac Williams on 3/6/15.
//  Copyright (c) 2015 The Williams Family. All rights reserved.
//

import UIKit

protocol SettingsSection {
    func enabledWhenRemindersOff() -> Bool
    func reuseIdentifier() -> String
    func numberOfRows() -> Int
    func configureCell(cell: UITableViewCell, atIndex index: Int)
}