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
    public var isShakable = true

    init() {
        self.mySqlHost     = ""
        self.mySqlPort     = 3309
        self.mySqlDatabase = "MMTodo"
        self.mySqlTable    = "Todos"
        self.mySqlUsername = ""
        self.mySqlPassword = ""
        self.pingHost      = ""
        self.pingPort      = 80
        self.pingTimer     = 15
        self.project       = ""
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

