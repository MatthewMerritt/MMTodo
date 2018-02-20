//
//  MMTodo.swift
//  MMTodo macOS
//
//  Created by Matthew Merritt on 1/23/18.
//  Copyright © 2018 Matthew Merritt. All rights reserved.
//

import Foundation
#if os(iOS)
    import UIKit
    public typealias Color = UIColor
    public typealias Image = UIImage
#elseif os(OSX)
    import Cocoa
    public typealias Color = NSColor
    public typealias Image = NSImage
#endif

/// MMTodo is the container for all your Todos.
public class MMTodo {

    // MARK: Properties

    /// The name used to for an MMTodo
    var name: String

    /// The actual todo for an MMTodo
    var todo: String

    /// The project that an MMTodo belongs to.
    var project: String

    /// The MMTodo.Status that an MMTodo has.
    var status: Status

    /// The MMTodo.Priority that an MMTodo has.
    var priority: Priority

    /// The date that an MMTodo was created.
    var createdAt: Date

    /// The date that an MMTodo was last modified.
    var modifiedAt: Date

    /// The date tht an MMTodo is due.
    var dueAt: Date?

    /// MySQL id for an MMTodo.
    var id: Int

    /// This is used to format a date for an MMTodo.
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        df.timeZone  = .current

        return df
    }()

    // MARK: Initializers

    /// Create an MMTodo from a Dictionary.
    ///
    /// - Notes: MySQL returns a Dictionary on queryies.
    ///
    /// - Parameter dictionary: Dictionary representation of an MMTodo.
    init(with dictionary: Dictionary<String, Any>) {
        self.name = dictionary["name"] as! String
        self.todo = dictionary["todo"] as! String
        self.project = dictionary["project"] as! String
        self.status  = Status(rawValue: dictionary["status"] as! String)
        self.priority  = Priority(rawValue: dictionary["priority"] as! String)
        self.createdAt = dictionary["createdAt"] as! Date
        self.modifiedAt = dictionary["modifedAt"] as! Date

        if dictionary["dueAt"] != nil {
            self.dueAt = dictionary["dueAt"] as? Date
        } else {
            self.dueAt = nil
        }

        self.id   = dictionary["id"] as! Int

        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = .current
    }

    /// This creates and returns a Dictionary representation of an MMTodo.
    ///
    /// - Returns: The Dictionary of an MMTodo.
    func dictionary() -> Dictionary<String, Any> {
        var dict: Dictionary<String, Any> = [:]

        dict["name"]      = self.name
        dict["todo"]      = self.todo
        dict["project"]   = self.project
        dict["status"]    = self.status.rawValue
        dict["priority"]  = self.priority.rawValue
        dict["createdAt"] = self.createdAt
        dict["modifedAt"] = self.modifiedAt
        dict["dueAt"]     = self.dueAt
        dict["id"]        = self.id

        return dict
    }
}

extension MMTodo {

    // MARK: MMTodo enums

    /// Status represents the various MMTodo Status values.
    enum Status: String {

        /// MMTodo currently not complete and active
        case working  = "Working"

        /// MMTodo currently not completed, but not active
        case waiting  = "Waiting"

        /// MMTodo complete
        case complete = "Complete"

        /// Workaround for making controls - it is always the last value
        case count

        /// Initialize an MMTodo Status by Int.
        ///
        /// - Parameter hashValue:  Int value to initialize MMTodo Status as.
        init(hashValue: Int) {
            switch hashValue {
            case 0:
                self = .working
            case 1:
                self = .waiting
            case 2:
                self = .complete
            default:
                self = .complete
            }
        }

        /// Initialize an MMTodo Status by String.
        ///
        /// - Parameter rawValue:  String value to initialize MMTodo Status as.
        init(rawValue: String) {
            switch rawValue {
            case "Working":
                self = .working
            case "Waiting":
                self = .waiting
            case "Complete":
                self = .complete
            default:
                self = .complete
            }
        }
    }

    /// Priority represents the various MMTodo Status values.
    enum Priority: String {

        /// Complete when possible
        case low    = "Low"

        /// Needs to be done, but nothing is broken
        case medium = "Medium"

        /// Fix this now, something is broken
        case high   = "High"

        /// Workaround for making controls - it is always the last value
        case count

        /// Initialize MMTodo Priority.
        ///
        /// - Parameter hashValue: Int value to intialize MMTodo Priority as.
        init(hashValue: Int) {
            switch hashValue {
            case 0:
                self = .low
            case 1:
                self = .medium
            default:
                self = .high
            }
        }

        /// Initialize MMTodo Priority.
        ///
        /// - Parameter rawValue: String value to initialize MMTodo Priority as.
        init(rawValue: String) {
            switch rawValue {
            case "Low":
                self = .low
            case "Medium":
                self = .medium
            default:
                self = .high
            }
        }

        /// MMTodo Priority Colors
        ///
        /// - Returns: Returns a color for the MMTodo Priority.
        ///
        /// - Note: color is typealiased depending on platform.
        func color() -> Color {
            switch self {
            case .low:
                return .green
            case .medium:
                return .yellow
            default:
                return .red
            }
        }
    }

}

