//
//  MMTodoModel.swift
//  MMTodo
//
//  Created by Matthew Merritt on 1/23/18.
//  Copyright © 2018 Matthew Merritt. All rights reserved.
//

import Foundation

public class MMTodoModel {
    public static var shared = MMTodoModel()

    public var todos: [MMTodo] = []
    public var projects: [Dictionary<String, Any>] = []

    public let settings = MMTodoSettings.shared

    public let con = MySQL.Connection()

    private var trying = false
    private var timer: DispatchSourceTimer?
    private var lastConnected = false
    public var isConnected = false

    public func listen(on: Bool = true) {
        if on == false {
            timer?.cancel()
            timer = nil
            return
        }

        guard settings.isPingReady() else {
            Swift.print("Not able to Ping!")
            return
        }

        let queue = DispatchQueue(label: "com.domain.app.timer")  // you can also use `DispatchQueue.main`, if you want
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.schedule(deadline: .now(), repeating: .seconds(settings.pingTimer))
        timer!.setEventHandler { [weak self] in

            do {
                let socket = try Socket(host: (self?.settings.pingHost)!, port: (self?.settings.pingPort)!)
                try socket.Connect()
                self?.isConnected = true

                if self?.isConnected != self?.lastConnected {
                    NotificationCenter.default.post(name: .todoDidChangeNetworkStatus, object: nil, userInfo: ["Status" : "Connected"])
                }

                self?.lastConnected = true
            } catch (let e) {
                self?.isConnected = false

                if self?.isConnected != self?.lastConnected {
                    NotificationCenter.default.post(name: .todoDidChangeNetworkStatus, object: nil, userInfo: ["Status" : "Not Connected"])
                }

                self?.lastConnected = false
                _ = e
                Swift.print("Here:", e)
            }
        }
        timer!.resume()
    }

    public func load(retry: Bool = false) {
        // We need connection information in order to loadProjects
        guard settings.isConnectionReady() else {
            Swift.print("Can't Load!")
            return
        }

        // We need to either be retrying or connected
        guard retry || self.isConnected else { return }

        // Wait while we are retrying and not connected
        while retry && !self.isConnected { }

        // Remove all todos for table update
        todos.removeAll()

        do {
            try con.open(settings.mySqlHost, user: settings.mySqlUsername, passwd: settings.mySqlPassword)
            try con.use(settings.mySqlDatabase)
            let select_stmt = try con.prepare("SELECT * FROM \(settings.mySqlTable) where project='\(settings.project)'")

            do {
                // send query
                let res = try select_stmt.query([])

                //read all rows from the resultset
                if let rows = try res.readAllRows()?.first {
                    for row in rows {
                        todos.append(MMTodo(with: row))
                    }
                }

                NotificationCenter.default.post(name: .todoDidLoad, object: nil)
            }
            catch (let err) {
                // if we get a error print it out
                print(err)
            }

            try con.close()

        } catch (let e) {
            Swift.print(e)
        }
    }

    public func loadProjects(retry: Bool = false) {
        // We need connection information in order to loadProjects
        guard settings.isConnectionReady() else {
            Swift.print("Can't Load!")
            return
        }

        // We need to either be retrying or connected
        guard retry || self.isConnected else { return }

        // Wait while we are retrying and not connected
        while retry && !self.isConnected { }

        // Remove all projects for table update
        projects.removeAll()

        do {
            try con.open(settings.mySqlHost, user: settings.mySqlUsername, passwd: settings.mySqlPassword)
            try con.use(settings.mySqlDatabase)

            // SQL statement to load project status in form: [[Project : name, Working Status : Count, Waiting Status : Count, Complete Status : Count]]
            let select_stmt = try con.prepare("select project as Project, count(case when `status` = 'Working' then 1 end) as Working, count(case when `status` = 'Waiting' then 1 end) as Waiting, count(case when `status` = 'Complete' then 1 end) as Complete from Todos group by `project`")

            do {
                // send query
                let res = try select_stmt.query([])


                //read all rows from the resultset
                if let rows = try res.readAllRows()?.first {
                    for row in rows {
                        projects.append(row)
                    }
                }

                NotificationCenter.default.post(name: .todoDidLoad, object: nil)
            }
            catch (let err) {
                // if we get a error print it out
                print(err)
            }

            try con.close()

        } catch (let e) {
            Swift.print(e)
        }
    }

    #if os(iOS)
    func todo(at indexPath: IndexPath) -> MMTodo? {
        return todos(byStatus: MMTodo.Status.init(hashValue: indexPath.section), sorted: "Priority")[indexPath.row] ?? nil
    }
    #elseif os(OSX)
    #endif

    func todos(byStatus status: MMTodo.Status, sorted by: String? = nil) -> [MMTodo?] {
        let matching = todos.filter { $0.status == status }

        if matching.count < 1 { return [] }

        switch by {
        case "Priority"?:
            return matching.sorted { $0.priority.hashValue > $1.priority.hashValue }
        default:
            _ = true
        }

        return matching
    }

    func todos(byPriority priority: MMTodo.Priority) -> [MMTodo?] {
        let matching = todos.filter { $0.priority == priority }
        return matching
    }

    func create(name: String, todo: String, project: String, status: MMTodo.Status, priority: MMTodo.Priority, createdAt: Date = Date(), modifiedAt: Date = Date()) {

        guard settings.isConnectionReady() else {
            Swift.print("Can't Create!")
            return
        }

        do {
            try con.open(settings.mySqlHost, user: settings.mySqlUsername, passwd: settings.mySqlPassword)
            try con.use(settings.mySqlDatabase)

            let ins_stmt = try con.prepare("INSERT INTO \(settings.mySqlTable)(name, todo, project, status, priority, createdAt, modifedAt) VALUES(?,?,?,?,?,?,?)")

            try ins_stmt.exec([name, todo, project, status.rawValue, priority.rawValue, createdAt, modifiedAt])

            try con.close()

            load()
        } catch (let e) {
            Swift.print(e)
        }
    }

    func saveTodo(_ todo: MMTodo) {
        guard settings.isConnectionReady() else {
            Swift.print("Can't Save!")
            return
        }

        do {
            try con.open(settings.mySqlHost, user: settings.mySqlUsername, passwd: settings.mySqlPassword)
            try con.use(settings.mySqlDatabase)

            let table = MySQL.Table(tableName: settings.mySqlTable, connection: con)

            todo.modifiedAt = Date()
            try table.update(todo.dictionary(), key: "id")

            try con.close()

            load()
        } catch (let e) {
            Swift.print(e)
        }
    }

    func remove(_ todo: MMTodo) {
        guard settings.isConnectionReady() else {
            Swift.print("Can't Remove!")
            return
        }

        do {
            try con.open(settings.mySqlHost, user: settings.mySqlUsername, passwd: settings.mySqlPassword)
            try con.use(settings.mySqlDatabase)

            let ins_stmt = try con.prepare("DELETE FROM \(settings.mySqlTable) WHERE id=\(todo.id)")
            try ins_stmt.exec([])

            try con.close()

            load()
        } catch (let e) {
            Swift.print(e)
        }
    }

}



