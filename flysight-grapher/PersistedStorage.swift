//
//  PersistedStorage.swift
//  flysight-grapher
//
//  Created by richö butts on 9/10/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<Value: Codable> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get {
            return UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
