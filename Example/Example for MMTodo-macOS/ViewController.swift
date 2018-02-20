//
//  ViewController.swift
//  MMTodo_Example-macOS
//
//  Created by Matthew Merritt on 2/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Cocoa
import MMTodo

class ViewController: NSViewController {

    // Get an Instance of the MMTodoModel, MMTodoMenu and MMTodoWindowController
    let todoModel = MMTodoModel.shared
    var todoMenu: MMTodoMenu!
    var todoWindowController: MMTodoWindowController?

    @IBOutlet weak var configureDBButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // Create Menu and place it on the Help Menu
        todoMenu = MMTodoMenu(from: self, wth: #selector(self.todoMenuAction(_:)))

        // TODO: Fix this to use UserDefaults like iOS
        // Setup the ping and MySQL Information
        todoModel.settings.pingHost = "ping Host"
        todoModel.settings.mySqlHost = "MySQL Host"
        todoModel.settings.mySqlUsername = "MySQL Username"
        todoModel.settings.mySqlPassword = "MySQL Password"
        todoModel.settings.project = "Project"

        // Start the listener for MySQL connection changes
        self.todoModel.listen()
    }

    // Menu Actions
    @objc func todoMenuAction(_ sender: NSMenuItem) {
        if todoWindowController == nil {
            todoMenu.todoMenuItem.state = .on
            todoWindowController = MMTodoWindowController()
            todoWindowController?.showWindow(sender)
        } else {
            todoMenu.todoMenuItem.state = .off
            todoWindowController?.close()
            todoWindowController = nil
        }
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

