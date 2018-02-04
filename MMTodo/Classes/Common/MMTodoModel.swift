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

    var todos: [MMTodo] = []
    public var projects: [String] = []

    public let conInfo = MMTodoConfiguration.shared

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

        guard conInfo.isPingReady() else {
            Swift.print("Not able to Ping!")
            return
        }

        let queue = DispatchQueue(label: "com.domain.app.timer")  // you can also use `DispatchQueue.main`, if you want
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.schedule(deadline: .now(), repeating: .seconds(conInfo.pingTimer))
        timer!.setEventHandler { [weak self] in
            // do whatever you want here



            do {
                let socket = try Socket(host: (self?.conInfo.pingHost)!, port: (self?.conInfo.pingPort)!)
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

    func load(retry: Bool = false) {
        guard conInfo.isConnectionReady() else {
            Swift.print("Can't Load!")
            return
        }

        guard retry || self.isConnected else { return }

        while retry && !self.isConnected { }

        do {
            try con.open(conInfo.mySqlHost, user: conInfo.mySqlUsername, passwd: conInfo.mySqlPassword)
            try con.use(conInfo.mySqlDatabase)
            let select_stmt = try con.prepare("SELECT * FROM \(conInfo.mySqlTable) where project='\(conInfo.project)'")

            do {
                // send query
                let res = try select_stmt.query([])

                todos.removeAll()

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

    func loadProjects(retry: Bool = false) {
        guard conInfo.isConnectionReady() else {
            Swift.print("Can't Load!")
            return
        }

        guard retry || self.isConnected else { return }

        while retry && !self.isConnected { }

        do {
            try con.open(conInfo.mySqlHost, user: conInfo.mySqlUsername, passwd: conInfo.mySqlPassword)
            try con.use(conInfo.mySqlDatabase)
            let select_stmt = try con.prepare("SELECT DISTINCT `project` FROM \(conInfo.mySqlTable)")

            do {
                // send query
                let res = try select_stmt.query([])

                projects.removeAll()

                //read all rows from the resultset
                if let rows = try res.readAllRows()?.first {
                    for row in rows {
                        projects.append(row["project"] as! String)
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
        return todos(byStatus: MMTodo.Status.init(hashValue: indexPath.section))[indexPath.row] ?? nil
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

        guard conInfo.isConnectionReady() else {
            Swift.print("Can't Create!")
            return
        }

        do {
            try con.open(conInfo.mySqlHost, user: conInfo.mySqlUsername, passwd: conInfo.mySqlPassword)
            try con.use(conInfo.mySqlDatabase)

            let ins_stmt = try con.prepare("INSERT INTO \(conInfo.mySqlTable)(name, todo, project, status, priority, createdAt, modifedAt) VALUES(?,?,?,?,?,?,?)")

            try ins_stmt.exec([name, todo, project, status.rawValue, priority.rawValue, createdAt, modifiedAt])

            try con.close()

            load()
        } catch (let e) {
            Swift.print(e)
        }
    }

    func saveTodo(_ todo: MMTodo) {
        guard conInfo.isConnectionReady() else {
            Swift.print("Can't Save!")
            return
        }

        do {
            try con.open(conInfo.mySqlHost, user: conInfo.mySqlUsername, passwd: conInfo.mySqlPassword)
            try con.use(conInfo.mySqlDatabase)

            let table = MySQL.Table(tableName: conInfo.mySqlTable, connection: con)

            todo.modifiedAt = Date()
            try table.update(todo.dictionary(), key: "id")

            try con.close()

            load()
        } catch (let e) {
            Swift.print(e)
        }
    }

    func remove(_ todo: MMTodo) {
        guard conInfo.isConnectionReady() else {
            Swift.print("Can't Remove!")
            return
        }

        do {
            try con.open(conInfo.mySqlHost, user: conInfo.mySqlUsername, passwd: conInfo.mySqlPassword)
            try con.use(conInfo.mySqlDatabase)

            let ins_stmt = try con.prepare("DELETE FROM \(conInfo.mySqlTable) WHERE id=\(todo.id)")
            try ins_stmt.exec([])

            try con.close()

            load()
        } catch (let e) {
            Swift.print(e)
        }
    }

}



