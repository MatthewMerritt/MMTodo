//
//  MMTodoTableViewController.swift
//  MMTodo iOS
//
//  Created by Matthew Merritt on 1/24/18.
//  Copyright © 2018 Matthew Merritt. All rights reserved.
//

import UIKit

extension UIViewController {

    override open func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake && MMTodoSettings.shared.isShakable {
            UIApplication.shared.keyWindow?.rootViewController?.present(MMTodoTableViewController.todoNavigationController!, animated: true, completion: { })
        }
    }
    
}

public class MMTodoTableViewController: UITableViewController {

    static var shared: MMTodoTableViewController? = {
        let podBundle = Bundle(for: MMTodoTableViewController.self)

        if let sb = UIStoryboard.init(name: "Storyboard-iOS", bundle: podBundle) as UIStoryboard?, let navController = sb.instantiateViewController(withIdentifier: "MMTodoTableViewNavController") as? UINavigationController, let tableViewController = navController.viewControllers.first as? MMTodoTableViewController {
            return tableViewController
        } else {
            return nil
        }
    }()

    static var todoNavigationController: UINavigationController? = {
        let podBundle = Bundle(for: MMTodoTableViewController.self)

        if let sb = UIStoryboard.init(name: "Storyboard-iOS", bundle: podBundle) as UIStoryboard?, let navController = sb.instantiateViewController(withIdentifier: "MMTodoTableViewNavController") as? UINavigationController, let tableViewController = navController.viewControllers.first as? MMTodoTableViewController {
            return navController
        } else {
            return nil
        }
    }()

    var addButtonItem: UIBarButtonItem!

    var todoModel = MMTodoModel.shared

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonItemAction(sender:)))

        self.navigationItem.rightBarButtonItems = [editButtonItem, addButtonItem]

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.todoLoadNotification(_:)),
                                               name: .todoDidLoad,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.networkStatusNotification(_:)),
                                               name: .todoDidChangeNetworkStatus,
                                               object: nil)

    }


    @objc func todoLoadNotification(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.title = self.todoModel.isConnected ? self.todoModel.settings.project : "Not Connected"
            self.tableView.reloadData()
        })
    }

    @objc func networkStatusNotification(_ notification: Notification) {

        if let status = notification.userInfo!["Status"] as! String? {

            todoModel.load()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.title = self.todoModel.isConnected ? self.todoModel.settings.project : "Not Connected"

                guard status == "Connected" else { return  }

                self.tableView.reloadData()
            })
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.title = self.todoModel.isConnected ? self.todoModel.settings.project : "Not Connected"

        if todoModel.isConnected {
            DispatchQueue.global(qos: .background).async {
                self.todoModel.load()
            }
        }
    }

    override public func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        addButtonItem.isEnabled = !isEditing
    }

    @objc func addButtonItemAction(sender: UIBarButtonItem) {
        todoModel.create(name: "New Working Todo", todo: "Insert todo here", project: todoModel.settings.project, status: .working, priority: .medium)
    }

    @IBAction func doneButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true) { }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return MMTodo.Status.count.hashValue
    }

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return MMTodo.Status(hashValue: section).rawValue
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoModel.todos(byStatus: MMTodo.Status.init(hashValue: section)).count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()

        // Configure the cell...
        if let todo = todoModel.todo(at: indexPath) {
            if todo.dueAt != nil {
                cell = tableView.dequeueReusableCell(withIdentifier: "DueAtCell", for: indexPath)
                if let priorityLabel = cell.viewWithTag(1) as? UILabel,
                    let nameLabel = cell.viewWithTag(2) as? UILabel,
                    let dueAtLabel = cell.viewWithTag(3) as? UILabel {
                    priorityLabel.layer.cornerRadius = priorityLabel.frame.size.width / 2
                    priorityLabel.clipsToBounds = true
                    priorityLabel.backgroundColor = todo.priority.color()

                    nameLabel.text = todo.name

                    cell.backgroundColor = .white

                    if todo.dueAt! < Date().addingTimeInterval(2 * (24 * (60 * 60))) && todo.status != MMTodo.Status.complete {
                        cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.25)
                    }

                    if todo.dueAt! < Date() && todo.status != MMTodo.Status.complete {
                        cell.backgroundColor = UIColor.red.withAlphaComponent(0.25)
                    }

                    dueAtLabel.text = todo.dateFormatter.string(from: todo.dueAt!)
                }
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)

                if let priorityLabel = cell.viewWithTag(1) as? UILabel,
                    let nameLabel = cell.viewWithTag(2) as? UILabel {
                    priorityLabel.layer.cornerRadius = priorityLabel.frame.size.width / 2
                    priorityLabel.clipsToBounds = true
                    priorityLabel.backgroundColor = todo.priority.color()

                    nameLabel.text = todo.name
                }
            }
        }

        return cell
    }

    override public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let todo = todoModel.todo(at: indexPath)!

        let highPriorityAction = UIContextualAction(style: .normal, title: "!") { (action, view, success:(Bool) -> Void) in
            // share item at indexPath
            tableView.isEditing = false
            todo.priority = MMTodo.Priority(hashValue: 2)
            self.saveTodo(todo: todo, isAdding: false)
        }

        highPriorityAction.backgroundColor = UIColor.red

        let mediumPriorityAction = UIContextualAction(style: .normal, title: "!") { (action, view, success:(Bool) -> Void) in
            // share item at indexPath
            tableView.isEditing = false
            todo.priority = MMTodo.Priority(hashValue: 1)
            self.saveTodo(todo: todo, isAdding: false)
        }

        mediumPriorityAction.backgroundColor = UIColor.yellow

        let lowPriorityAction = UIContextualAction(style: .normal, title: "!") { (action, view, success:(Bool) -> Void) in
            // share item at indexPath
            tableView.isEditing = false
            todo.priority = MMTodo.Priority(hashValue: 0)
            self.saveTodo(todo: todo, isAdding: false)
        }

        lowPriorityAction.backgroundColor = UIColor.green

        isEditing = false

        return UISwipeActionsConfiguration(actions: [lowPriorityAction, mediumPriorityAction, highPriorityAction])
    }

    override public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let todo = todoModel.todo(at: indexPath)!

            let removeAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, success:(Bool) -> Void) in
                self.isEditing = false

                // share item at indexPath
                let alertController = UIAlertController(title: "Todo", message: "Are you sure you want to delete this Todo?", preferredStyle: .alert)

                // Create OK button
                let OKAction = UIAlertAction(title: "Delete", style: .destructive) { (action:UIAlertAction!) in
                    // Code in this block will trigger when OK button tapped.
                    self.todoModel.remove(todo)
                }

                alertController.addAction(OKAction)

                // Create Cancel button
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                    self.isEditing = false
                }

                alertController.addAction(cancelAction)

                // Present Dialog message
                self.present(alertController, animated: true, completion:nil)
            }

            isEditing = false

            return UISwipeActionsConfiguration(actions: [removeAction])

    }

    override public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    // Override to support conditional editing of the table view.
    override public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    // Override to support editing the table view.
    override public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if let todo = todoModel.todo(at: indexPath) {
                todoModel.remove(todo)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    // Override to support rearranging the table view.
    override public func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if let todo = todoModel.todo(at: fromIndexPath) {
            todo.status = MMTodo.Status(hashValue: to.section)
            todoModel.saveTodo(todo)
        }
    }

    // Override to support conditional rearranging of the table view.
    override public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "detailsId" {
            if let viewController = segue.destination as? MMTodoTextViewController,
               let indexPath = tableView.indexPathForSelectedRow,
               let todo = todoModel.todo(at: indexPath) {

                viewController.delegate = self
                viewController.todo = todo
            }
        }
    }

}

// MARK: - TodoTextViewControllerDelegate
extension MMTodoTableViewController: MMTodoTextViewControllerDelegate {

    public func saveTodo(todo: MMTodo, isAdding: Bool) {
        // TODO: Need to get this working better for responsive UI
//        DispatchQueue.global(qos: .background).async {
        //DispatchQueue.main.async {
            self.todoModel.saveTodo(todo)
//        }
    }
}
