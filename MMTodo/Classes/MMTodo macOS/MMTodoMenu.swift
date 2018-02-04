//
//  MMTodoMenu.swift
//  MMTodo macOS
//
//  Created by Matthew Merritt on 1/24/18.
//  Copyright © 2018 Matthew Merritt. All rights reserved.
//

import Cocoa

public class MMTodoMenu: NSObject {

    var mainMenu: NSMenu? = NSApp.mainMenu
    var helpMenu: NSMenu? = NSApp.mainMenu?.item(withTitle: "Help")?.submenu
    public var todoMenuItem: NSMenuItem = NSMenuItem()

    public init(from viewController: NSViewController, wth action: Selector) {
        super.init()

        mainMenu?.autoenablesItems = true

        todoMenuItem.title = "MMTodo"
        todoMenuItem.target = viewController
        todoMenuItem.isEnabled = true
        todoMenuItem.action = action
        todoMenuItem.keyEquivalent = "T"

        if helpMenu?.items != nil {
            helpMenu?.insertItem(NSMenuItem.separator(), at: (helpMenu?.items.count)! - 1)
            helpMenu?.insertItem(todoMenuItem, at: (helpMenu?.items.count)! - 1)
            helpMenu?.insertItem(NSMenuItem.separator(), at: (helpMenu?.items.count)! - 1)
        } else if helpMenu != nil {
            helpMenu?.addItem(NSMenuItem.separator())
            helpMenu?.addItem(todoMenuItem)
            helpMenu?.addItem(NSMenuItem.separator())
        } else if mainMenu != nil {
            // Here we need to add the Help Menu
        }

    }

}
