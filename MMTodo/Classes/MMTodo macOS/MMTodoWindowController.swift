//
//  MMTodoWindowController.swift
//  MMTodo macOS
//
//  Created by Matthew Merritt on 1/24/18.
//  Copyright © 2018 Matthew Merritt. All rights reserved.
//

import Cocoa

public class MMTodoWindowController: NSWindowController {

    @IBOutlet var todoContentView: MMTodoView!

    override public var windowNibName: NSNib.Name! {
        return NSNib.Name(rawValue: "MMTodoWindowController")
    }

    override public func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

        window?.title = MMTodoModel.shared.isConnected ? "MMTodo: Connected" : "MMTodo: Not Connected"

        window?.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isHidden = true
        window?.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden = true

    }

}

public class MMTodoView: NSView, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var tabView: NSTabView!

    @IBOutlet weak var workingTableView: NSTableView!
    @IBOutlet weak var workingProjectLabel: NSTextField!
    @IBOutlet weak var workingPriorityComboBox: NSComboBox!
    @IBOutlet weak var workingCreatedAtLabel: NSTextField!
    @IBOutlet weak var workingModifiedAtLabel: NSTextField!
    @IBOutlet weak var workingDueAtPicker: NSDatePicker!
    @IBOutlet weak var workingTodoText: NSTextView!

    @IBOutlet weak var waitingTableView: NSTableView!
    @IBOutlet weak var waitingProjectLabel: NSTextField!
    @IBOutlet weak var waitingPriorityComboBox: NSComboBox!
    @IBOutlet weak var waitingCreatedAtLabel: NSTextField!
    @IBOutlet weak var waitingModifiedAtLabel: NSTextField!
    @IBOutlet weak var waitingDueAtDueAtPicker: NSDatePicker!
    @IBOutlet weak var waitingTodoText: NSTextView!

    @IBOutlet weak var completedTableView: NSTableView!
    @IBOutlet weak var completedProjectLabel: NSTextField!
    @IBOutlet weak var completedPriorityComboBox: NSComboBox!
    @IBOutlet weak var completedCreatedAtLabel: NSTextField!
    @IBOutlet weak var completedModifiedAtLabel: NSTextField!
    @IBOutlet weak var completedDueAtPicker: NSDatePicker!
    @IBOutlet weak var completedTodoText: NSTextView!

    let todoModel = MMTodoModel.shared

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.workingTableView.doubleAction = #selector(self.doubleClickOnResultRow(_:))
            self.waitingTableView.doubleAction = #selector(self.doubleClickOnResultRow(_:))
            self.completedTableView.doubleAction = #selector(self.doubleClickOnResultRow(_:))
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.todoLoadNotification(_:)),
                                               name: .todoDidLoad,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.networkStatusNotification(_:)),
                                               name: .todoDidChangeNetworkStatus,
                                               object: nil)

    }

    override public func viewDidMoveToWindow() {
        NSApplication.shared.dockTile.badgeLabel = ""

        if todoModel.isConnected {
            DispatchQueue.global(qos: .background).async {
                self.todoModel.load()
                self.todoModel.loadProjects()
            }
        }
    }

    @objc func networkStatusNotification(_ notification: Notification) {

        Swift.print("got notification")
        if let status = notification.userInfo!["Status"] as! String? {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                NSApplication.shared.windows.last?.title = "MMTodo: \(status)"
            })

            guard status == "Connected" else { return  }

            todoModel.load()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {

                self.workingTableView.reloadData()
                self.waitingTableView.reloadData()
                self.completedTableView.reloadData()
            })
        }
    }

    @objc func todoLoadNotification(_ notification: Notification) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            NSApplication.shared.windows.last?.title = self.todoModel.isConnected ? "MMTodo: Connected" : "MMTodo: Not Connected"

            self.workingTableView.reloadData()
            self.waitingTableView.reloadData()
            self.completedTableView.reloadData()
        })
    }

    @objc func doubleClickOnResultRow(_ tableView: NSTableView) {
        print("doubleClickOnResultRow \(tableView.clickedRow) for \(tableView.description)")

        if tableView == completedTableView {
            print("f an a Cotton")
        }
    }

    public func numberOfRows(in tableView: NSTableView) -> Int {

        switch tableView {
        case workingTableView:
            return todoModel.todos(byStatus: .working, sorted: "Priority").count
        case waitingTableView:
            return todoModel.todos(byStatus: .waiting, sorted: "Priority").count
        case completedTableView:
            return todoModel.todos(byStatus: .complete, sorted: "Priority").count
        default:
            return todoModel.todos(byStatus: .complete, sorted: "Priority").count
        }

    }

    public func tableViewSelectionDidChange(_ notification: Notification) {

        if let tableView = notification.object as? NSTableView {
            switch tableView {
            case workingTableView:
                if tableView.selectedRow < 0 {
                    workingProjectLabel.stringValue     = ""
                    workingPriorityComboBox.stringValue = ""
                    workingCreatedAtLabel.stringValue   = ""
                    workingModifiedAtLabel.stringValue  = ""
                    workingDueAtPicker.dateValue        = Date(timeIntervalSince1970: 0)
                    workingTodoText.string              = ""
                } else if let todo = todoModel.todos(byStatus: .working, sorted: "Priority")[tableView.selectedRow] {
                    workingProjectLabel.stringValue    = todo.project
                    workingPriorityComboBox.selectItem(at: todo.priority.hashValue)
                    workingCreatedAtLabel.stringValue  = todo.dateFormatter.string(from: todo.createdAt)
                    workingModifiedAtLabel.stringValue = todo.dateFormatter.string(from: todo.modifiedAt)
                    workingTodoText.string             = todo.todo

                    if todo.dueAt != nil {
                        workingDueAtPicker.dateValue  = todo.dueAt!
                    } else {
                        workingDueAtPicker.dateValue  = Date(timeIntervalSince1970: 0)
                    }
                }

            case waitingTableView:
                if tableView.selectedRow < 0 {
                    waitingProjectLabel.stringValue     = ""
                    waitingPriorityComboBox.stringValue = ""
                    waitingCreatedAtLabel.stringValue   = ""
                    waitingModifiedAtLabel.stringValue  = ""
                    waitingDueAtDueAtPicker.dateValue   = Date(timeIntervalSince1970: 0)
                    waitingTodoText.string              = ""
                } else if let todo = todoModel.todos(byStatus: .waiting, sorted: "Priority")[tableView.selectedRow] {
                    waitingProjectLabel.stringValue    = todo.project
                    waitingPriorityComboBox.selectItem(at: todo.priority.hashValue)
                    waitingCreatedAtLabel.stringValue  = todo.dateFormatter.string(from: todo.createdAt)
                    waitingModifiedAtLabel.stringValue = todo.dateFormatter.string(from: todo.modifiedAt)
                    waitingTodoText.string             = todo.todo

                    if todo.dueAt != nil {
                        waitingDueAtDueAtPicker.dateValue = todo.dueAt!
                    } else {
                        waitingDueAtDueAtPicker.dateValue  = Date(timeIntervalSince1970: 0)
                    }
                }

            case completedTableView:
                if tableView.selectedRow < 0 {
                    completedPriorityComboBox.stringValue = ""
                    completedCreatedAtLabel.stringValue   = ""
                    completedModifiedAtLabel.stringValue  = ""
                    completedProjectLabel.stringValue     = ""
                    completedDueAtPicker.dateValue = Date(timeIntervalSince1970: 0)
                    completedTodoText.string              = ""
                } else if let todo = todoModel.todos(byStatus: .complete, sorted: "Priority")[tableView.selectedRow] {
                    completedProjectLabel.stringValue    = todo.project
                    completedPriorityComboBox.selectItem(at: todo.priority.hashValue)
                    completedCreatedAtLabel.stringValue  = todo.dateFormatter.string(from: todo.createdAt)
                    completedModifiedAtLabel.stringValue = todo.dateFormatter.string(from: todo.modifiedAt)
                    completedTodoText.string             = todo.todo

                    if todo.dueAt != nil {
                        completedDueAtPicker.dateValue   = todo.dueAt!
                    } else {
                        completedDueAtPicker.dateValue = Date(timeIntervalSince1970: 0)
                    }

                }

            default:
                Swift.print("selectedRow:", tableView.selectedRow)
            }
        }
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
        var todo: MMTodo?

        switch tableView {
        case workingTableView:
            todo = todoModel.todos(byStatus: .working, sorted: "Priority")[row]
        case waitingTableView:
            todo = todoModel.todos(byStatus: .waiting, sorted: "Priority")[row]
        case completedTableView:
            todo = todoModel.todos(byStatus: .complete, sorted: "Priority")[row]
        default:
            todo = todoModel.todos(byStatus: .working, sorted: "Priority")[row]
        }

        cell?.textField?.stringValue = (todo?.name)!

        return cell
    }
}

extension MMTodoView: NSTextViewDelegate {

    public func textDidEndEditing(_ notification: Notification) {
        if let textView = notification.object as? NSTextView {

            var todo: MMTodo?

            switch textView {
            case workingTodoText:
                todo = todoModel.todos(byStatus: .working, sorted: "Priority")[workingTableView.selectedRow]

            case waitingTodoText:
                todo = todoModel.todos(byStatus: .waiting, sorted: "Priority")[waitingTableView.selectedRow]

            case completedTodoText:
                todo = todoModel.todos(byStatus: .complete, sorted: "Priority")[completedTableView.selectedRow]

            default:
                _ = true
            }

            if todo != nil {
                todo?.todo = textView.string
            }
        }
    }
}

// MARK: Picker and ComboBox Actions
extension MMTodoView: NSDatePickerCellDelegate, NSComboBoxDelegate {

    public func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        Swift.print("here?")
    }

    public func comboBoxSelectionDidChange(_ notification: Notification) {
        // This menu only makes sense if an MMTodo is selected
        guard workingTableView.selectedRow > -1 || waitingTableView.selectedRow > -1 || completedTableView.selectedRow > -1 else { return }

        let comboBox = notification.object as! NSComboBox

        switch comboBox {
        case workingPriorityComboBox:
            if let todo = todoModel.todos(byStatus: .working, sorted: "Priority")[workingTableView.selectedRow] {
                todo.priority = MMTodo.Priority(hashValue: comboBox.indexOfSelectedItem)
            }

        case waitingPriorityComboBox:
            if let todo = todoModel.todos(byStatus: .waiting, sorted: "Priority")[waitingTableView.selectedRow] {
                todo.priority = MMTodo.Priority(hashValue: comboBox.indexOfSelectedItem)
            }

        case completedPriorityComboBox:
            if let todo = todoModel.todos(byStatus: .complete, sorted: "Priority")[completedTableView.selectedRow] {
                todo.priority = MMTodo.Priority(hashValue: comboBox.indexOfSelectedItem)
            }

        default:
            Swift.print(comboBox)
        }
    }

    @IBAction func dueAtDatePickerAction(_ sender: NSDatePicker) {
        // This menu only makes sense if an MMTodo is selected
        guard workingTableView.selectedRow > -1 || waitingTableView.selectedRow > -1 || completedTableView.selectedRow > -1 else { return }

        switch sender {
        case workingDueAtPicker:
            if let todo = todoModel.todos(byStatus: .working, sorted: "Priority")[workingTableView.selectedRow] {
                todo.dueAt = sender.dateValue
            }

        case waitingDueAtDueAtPicker:
            if let todo = todoModel.todos(byStatus: .working, sorted: "Priority")[waitingTableView.selectedRow] {
                todo.dueAt = sender.dateValue
            }

            case completedDueAtPicker:
            if let todo = todoModel.todos(byStatus: .complete, sorted: "Priority")[completedTableView.selectedRow] {
                todo.dueAt = sender.dateValue
            }

        default:
            _ = true
        }
    }

}

// MARK: - Button Actions
extension MMTodoView {

    @IBAction func addButtonAction(_ sender: NSButton) {

        switch sender.tag {
        case 1:
            todoModel.create(name: "New Working Todo", todo: "Insert todo here", project: todoModel.settings.project, status: .working, priority: .medium)
        case 2:
            todoModel.create(name: "New Waiting Todo", todo: "Insert todo here", project: todoModel.settings.project, status: .waiting, priority: .medium)
        case 3:
            todoModel.create(name: "New Completed Todo", todo: "Insert todo here", project: todoModel.settings.project, status: .complete, priority: .medium)
        default:
            _ = true
        }
    }

    @IBAction func removeButtonAction(_ sender: NSButton) {

        // This menu only makes sense if an MMTodo is selected
        guard workingTableView.selectedRow > -1 || waitingTableView.selectedRow > -1 || completedTableView.selectedRow > -1 else { return }

        var removeTodo: MMTodo? = nil

        switch sender.tag {
        case 1:
            removeTodo = todoModel.todos(byStatus: .working)[workingTableView.selectedRow]
        case 2:
            removeTodo = todoModel.todos(byStatus: .waiting)[waitingTableView.selectedRow]
        case 3:
            removeTodo = todoModel.todos(byStatus: .complete)[completedTableView.selectedRow]
        default:
            _ = true
        }

        // done if we have nothing to remove
        guard removeTodo != nil else { return }

        let a = NSAlert()
        a.messageText = "MMTodo remove Todo?"
        a.informativeText = "Are you sure you want to remove this Todo?"

        a.addButton(withTitle: "Delete")
        a.addButton(withTitle: "Cancel")
        a.alertStyle = NSAlert.Style.critical

        a.beginSheetModal(for: self.window!) { (modalResponse) in
            guard modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn else { return }
            self.todoModel.remove(removeTodo!)
        }


    }

    @IBAction func saveButtonAction(_ sender: NSButton) {
        // This menu only makes sense if an MMTodo is selected
        guard workingTableView.selectedRow > -1 || waitingTableView.selectedRow > -1 || completedTableView.selectedRow > -1 else { return }

        self.window?.makeFirstResponder(nil)

        var saveTodo: MMTodo? = nil

        switch sender.tag {
        case 1:
            if let todo = todoModel.todos(byStatus: .working, sorted: "Priority")[workingTableView.selectedRow] {
                saveTodo = todo
            }

        case 2:
            if let todo = todoModel.todos(byStatus: .waiting, sorted: "Priority")[waitingTableView.selectedRow] {
                saveTodo = todo
            }

        case 3:
            if let todo = todoModel.todos(byStatus: .complete, sorted: "Priority")[completedTableView.selectedRow] {
                saveTodo = todo
            }

        default:
            _ = true
        }

        if saveTodo != nil {
            todoModel.saveTodo(saveTodo!)
        }
    }

    @IBAction func refreshButtonAction(_ sender: NSButton) {
        todoModel.load()
        workingTableView.reloadData()
        waitingTableView.reloadData()
        completedTableView.reloadData()
    }

    @IBAction func changeStatusAction(_ sender: NSButton) {

        // This menu only makes sense if an MMTodo is selected
        guard workingTableView.selectedRow > -1 || waitingTableView.selectedRow > -1 || completedTableView.selectedRow > -1 else { return }

        var selectedTodo: MMTodo? = nil

        let menu = NSMenu(title: "Status")

        let workingMenuItem = menu.addItem(withTitle: "Working", action: #selector(self.changeStatus(_:)), keyEquivalent: "")
        workingMenuItem.target = self
        workingMenuItem.image = NSImage(named: NSImage.Name(rawValue: "NSStatusAvailable"))

        let waitingMenuItem = menu.addItem(withTitle: "Waiting", action: #selector(self.changeStatus(_:)), keyEquivalent: "")
        waitingMenuItem.target = self
        waitingMenuItem.image = NSImage(named: NSImage.Name(rawValue: "NSStatusUnavailable"))

        let completeMenuItem = menu.addItem(withTitle: "Complete", action: #selector(self.changeStatus(_:)), keyEquivalent: "")
        completeMenuItem.target = self
        completeMenuItem.image = NSImage(named: NSImage.Name(rawValue: "NSStatusNone"))

        if workingTableView.selectedRow > -1 {
            if let todo = todoModel.todos(byStatus: .working, sorted: "Priority")[workingTableView.selectedRow] {
                workingMenuItem.state = .on
                selectedTodo = todo
            }
        }

        if waitingTableView.selectedRow > -1 {
            if let todo = todoModel.todos(byStatus: .waiting, sorted: "Priority")[waitingTableView.selectedRow] {
                waitingMenuItem.state = .on
                selectedTodo = todo
            }
        }

        if completedTableView.selectedRow > -1 {
            if let todo = todoModel.todos(byStatus: .complete, sorted: "Priority")[completedTableView.selectedRow] {
                completeMenuItem.state = .on
                selectedTodo = todo
            }
        }

        workingMenuItem.representedObject = selectedTodo
        waitingMenuItem.representedObject = selectedTodo
        completeMenuItem.representedObject = selectedTodo

        var location = sender.frame.origin
        location.y += 17
        location.x += 17

        menu.popUp(positioning: nil, at: location, in: self)
    }

    @objc func changeStatus(_ sender: NSMenuItem) {

        // Make sure we are getting an MMTodo from this menu item
        if let todo = sender.representedObject as? MMTodo {
            let a = NSAlert()
            a.messageText = "MMTodo Status Change"
            var newTab = 0

            switch sender.title {
            case "Working":
                a.informativeText = "Do you want to set the Status to \"Working\"?"
            case "Waiting":
                a.informativeText = "Do you want to set the Status to \"Waiting\"?"
                newTab = 1
            case "Complete":
                a.informativeText = "Do you want to set the Status to \"Complete\"?"
                newTab = 2
            default:
                _ = true
            }

            a.addButton(withTitle: "Update")
            a.addButton(withTitle: "Cancel")
            a.alertStyle = NSAlert.Style.informational

            a.beginSheetModal(for: self.window!) { (modalResponse) in
                guard modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn else { return }

                todo.status = MMTodo.Status(rawValue: sender.title)

                self.todoModel.saveTodo(todo)

                self.tabView.selectTabViewItem(at: newTab)
            }
        }

    }

}
