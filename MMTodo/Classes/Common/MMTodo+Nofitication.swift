//
//  MMTodo+Nofitication.swift
//  MMTodo macOS
//
//  Created by Matthew Merritt on 2/2/18.
//

import Foundation

public extension Notification.Name {

    /// Notification sent when Network Status changed.
    static let todoDidChangeNetworkStatus = Notification.Name("MMTodoNetworkStatusNotification")

    /// Notification sent when the MMTodo's have been loaded.
    static let todoDidLoad = Notification.Name("MMTodoLoadNotification")

}
