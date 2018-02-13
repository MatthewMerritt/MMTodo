//
//  MMTodoConfiguration.swift
//  MMTodo macOS
//
//  Created by Matthew Merritt on 2/2/18.
//

import Foundation

public class MMTodoSettings {
    public static var shared = MMTodoSettings()

    public var mySqlHost: String
    public var mySqlPort: Int
    public var mySqlDatabase: String
    public var mySqlTable: String
    public var mySqlUsername: String
    public var mySqlPassword: String
    public var pingHost: String
    public var pingPort: Int
    public var pingTimer: Int
    public var project: String
    public var isShakable: Bool

    init() {

        let defaults = UserDefaults.standard
        let userDefaultsDefaults = [
            "MySQLPort"  : 3309,
            "pingPort"   : 80,
            "pingTimer"  : 15,
            "isShakable" : true,
            ] as [String : Any]

        defaults.register(defaults: userDefaultsDefaults)

        mySqlHost     = defaults.string(forKey: "MySQLHost") ?? ""
        mySqlPort     = defaults.integer(forKey: "MySQLPort")
        mySqlDatabase = defaults.string(forKey: "MySQLDatabase") ?? ""
        mySqlTable    = defaults.string(forKey: "MySQLTable") ?? ""
        mySqlUsername = defaults.string(forKey: "MySQLUsername") ?? ""
        mySqlPassword = defaults.string(forKey: "MySQLPassword") ?? ""
        pingHost      = defaults.string(forKey: "pingHost") ?? ""
        pingPort      = defaults.integer(forKey: "pingPort")
        pingTimer     = defaults.integer(forKey: "pingTimer")
        project       = defaults.string(forKey: "project") ?? ""
        isShakable    = defaults.bool(forKey: "isShakable")
    }

    public func save() {
        let defaults = UserDefaults.standard

        defaults.synchronize()

        mySqlHost     = defaults.string(forKey: "MySQLHost") ?? ""
        mySqlPort     = defaults.integer(forKey: "MySQLPort")
        mySqlDatabase = defaults.string(forKey: "MySQLDatabase") ?? ""
        mySqlTable    = defaults.string(forKey: "MySQLTable") ?? ""
        mySqlUsername = defaults.string(forKey: "MySQLUsername") ?? ""
        mySqlPassword = defaults.string(forKey: "MySQLPassword") ?? ""
        pingHost      = defaults.string(forKey: "pingHost") ?? ""
        pingPort      = defaults.integer(forKey: "pingPort")
        pingTimer     = defaults.integer(forKey: "pingTimer")
        project       = defaults.string(forKey: "project") ?? ""
        isShakable    = defaults.bool(forKey: "isShakable")
    }

    func isConnectionReady() -> Bool {
        guard MMTodoSettings.shared.mySqlHost     != "" else { return false }
        guard MMTodoSettings.shared.mySqlUsername != "" else { return false }
        guard MMTodoSettings.shared.mySqlPassword != "" else { return false }
        guard MMTodoSettings.shared.project       != "" else { return false }

        return true
    }

    func isPingReady() -> Bool {
        guard MMTodoSettings.shared.pingHost != "" else { return false }

        return true
    }
}

