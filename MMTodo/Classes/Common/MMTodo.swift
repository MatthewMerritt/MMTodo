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
#elseif os(OSX)
    import Cocoa
    public typealias Color = NSColor
#endif

public class MMTodo {
    var name: String
    var todo: String
    var project: String
    var status: Status
    var priority: Priority
    var createdAt: Date   // iCloud System Field createdAt
    var modifiedAt: Date  // iCloud System Field modifiedAt
    var dueAt: Date?
    var id: Int
    var dateFormatter: DateFormatter

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
    enum Status: String {
        case working  = "Working"
        case waiting  = "Waiting"
        case complete = "Complete"
        case count

        init(hashValue: Int) {
            switch hashValue {
            case 0:
                self = .working
            case 1:
                self = .waiting
            default:
                self = .complete
            }
        }

        init(rawValue: String) {
            switch rawValue {
            case "Working":
                self = .working
            case "Waiting":
                self = .waiting
            default:
                self = .complete
            }
        }
    }

    enum Priority: String {
        case low    = "Low"
        case medium = "Medium"
        case high   = "High"
        case count

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

