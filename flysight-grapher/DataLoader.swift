//
//  DataLoader.swift
//  flysight-grapher
//
//  Created by richö butts on 7/8/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import Foundation
import SwiftCSV
import Charts

func getCSV(_ url: URL) -> CSV? {
    do {
        let csv = try CSV(url: url)
        return csv
    } catch {
        return nil
    }
}
