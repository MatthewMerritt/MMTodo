//
//  MMTodoConfiguration.swift
//  MMTodo macOS
//
//  Created by Matthew Merritt on 2/2/18.
//

import Foundation

public class MMTodoConfiguration {
    public static var shared = MMTodoConfiguration()

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
        guard MMTodoConfiguration.shared.mySqlHost     != "" else { return false }
        guard MMTodoConfiguration.shared.mySqlUsername != "" else { return false }
        guard MMTodoConfiguration.shared.mySqlPassword != "" else { return false }
        guard MMTodoConfiguration.shared.project       != "" else { return false }

        return true
    }

    func isPingReady() -> Bool {
        guard MMTodoConfiguration.shared.pingHost != "" else { return false }

        return true
    }
}

