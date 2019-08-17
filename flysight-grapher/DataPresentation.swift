//
//  DataPresentation.swift
//  flysight-grapher
//
//  Created by richö butts on 8/16/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

protocol DataPresentable {
    func loadData(_ data: DataSet)
    func clearData()
}
