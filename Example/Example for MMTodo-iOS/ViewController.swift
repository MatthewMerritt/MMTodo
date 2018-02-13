//
//  ViewController.swift
//  MMTodo
//
//  Created by MatthewMerritt on 02/03/2018.
//  Copyright (c) 2018 MatthewMerritt. All rights reserved.
//

import UIKit
import MMTodo

public class ViewController: UIViewController {
    //    let connectionInformation = ConnectionInformation.shared
    public var todoModel = MMTodoModel.shared

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.


        Swift.print("pinghost", todoModel.settings.pingHost)
        Swift.print("mysqlhost", todoModel.settings.mySqlHost)

        // Setup the ping and MySQL Information
//        todoModel.settings.pingHost = "ping Host"
//        todoModel.settings.mySqlHost = "MySQL Host"
//        todoModel.settings.mySqlUsername = "MySQL Username"
//        todoModel.settings.mySqlPassword = "MySQL Password"
//        todoModel.settings.project = "Project"

        // Start the listener for MySQL connection changes
        self.todoModel.listen()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

