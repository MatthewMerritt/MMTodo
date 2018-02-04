//
//  TextViewController.swift
//  ShiftToday
//
//  Created by Matthew Merritt on 12/27/16.
//  Copyright © 2017 MerrittWare. All rights reserved.
//

import UIKit

public protocol MMTodoTextViewControllerDelegate {
    func saveTodo(todo: MMTodo, isAdding: Bool)
}

public class MMTodoTextViewController: UIViewController {

    var delegate: MMTodoTextViewControllerDelegate!
    var todo: MMTodo!

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var statusButton: UIBarButtonItem!
    @IBOutlet weak var priorityButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!

    var fromPreview = false
    var isPrviewing = false
    var needsSaving = false

    let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 240, height: 22))

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        textField.text = "Title"
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textColor = UIColor.darkText
        textField.textAlignment = .center
        textField.delegate = self
        self.navigationItem.titleView = textField

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MMTodoTextViewController.textFieldDoneButtonAction(_:)))
        doneButton.tag = textField.tag
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        textView.inputAccessoryView = toolBar
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        textView.text = todo.todo
        textField.text = todo.name

        priorityButton.title = todo.priority.rawValue
        statusButton.title   = todo.status.rawValue

        // TODO: - Need to get statusbar and navigationbar height

        if isPrviewing {
            textView.contentInset.top += 66
            toolBar.isHidden = true
        } else if fromPreview {
            textView.contentInset.top -= 66
            toolBar.isHidden = false
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        isEditing = false
        
        todo.todo = textView.text

        if delegate != nil && needsSaving {
            if todo.name.count < 1 {
                let array = todo.todo.components(separatedBy: CharacterSet.newlines)
                todo.name = array.first!
            }

            delegate.saveTodo(todo: todo, isAdding: false)
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func textFieldDoneButtonAction(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MMTodoTextViewController {
    override public var previewActionItems : [UIPreviewActionItem] {

//        let infoAction = UIPreviewAction(title: "File Information", style: .default) { (action, viewController) -> Void in
////            self.filesCollectionViewController.fileInfo()
//        }

        let shareAction = UIPreviewAction(title: "Share", style: .default) { (action, viewController) -> Void in
//            self.shareActionView()
        }

//        let renameAction = UIPreviewAction(title: "Rename", style: .default) { (action, viewController) -> Void in
////            self.document.renameActionView()
//        }

//        let deleteAction = UIPreviewAction(title: "Remove", style: .destructive) { (action, viewController) -> Void in
////            self.document.removeActionView(confirm: true)
//        }

//        return [infoAction, shareAction, renameAction, deleteAction]
        return [shareAction]
    }

}

// MARK: - UITextFieldDelegate
extension MMTodoTextViewController: UITextFieldDelegate, UITextViewDelegate {

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.borderStyle = .roundedRect
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.borderStyle = .none
        todo.name = textField.text!
        needsSaving = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        needsSaving = true
    }

}

// MARK: - IBActions
extension MMTodoTextViewController {

    @IBAction func nameButtonAction(_ sender: UIBarButtonItem) {
//        Swift.print("nameButtonAction")

        let popover = UIViewController()
        popover.modalPresentationStyle = .popover

        if let presentation = popover.popoverPresentationController {
            presentation.delegate = self
            presentation.barButtonItem = sender
        }

        present(popover, animated: true, completion: nil)

    }

    @IBAction func priorityButtonAction(_ sender: UIBarButtonItem) {
//        Swift.print("priorityButtonAction")

        let picker = storyboard?.instantiateViewController(withIdentifier: "TodoPickerViewID") as? TodoPickerViewController

        picker?.delegate = self
        picker?.modalPresentationStyle = .popover
        picker?.preferredContentSize = CGSize(width: 375, height: 260)
        picker?.pickerType = .priority
        picker?.pickerValue = todo.priority
        picker?.isModalInPopover = true


        if let presentation = picker?.popoverPresentationController {
            presentation.delegate = self
            presentation.barButtonItem = sender
        }

        present(picker!, animated: true, completion: nil)
    }

    @IBAction func statusButtonAction(_ sender: UIBarButtonItem) {
        let picker = storyboard?.instantiateViewController(withIdentifier: "TodoPickerViewID") as? TodoPickerViewController

        picker?.delegate = self
        picker?.modalPresentationStyle = .popover
        picker?.preferredContentSize = CGSize(width: 375, height: 260)
        picker?.pickerType = .status
        picker?.pickerValue = todo.status

        picker?.isModalInPopover = true

        if let presentation = picker?.popoverPresentationController {
            presentation.delegate = self
            presentation.barButtonItem = sender
        }

        present(picker!, animated: true, completion: nil)
    }

    @IBAction func dueDateButtonAction(_ sender: UIBarButtonItem) {
        let picker = storyboard?.instantiateViewController(withIdentifier: "TodoPickerViewID") as? TodoPickerViewController

        picker?.delegate = self
        picker?.modalPresentationStyle = .popover
        picker?.preferredContentSize = CGSize(width: 375, height: 260)
        picker?.pickerType = .dueDate
        picker?.pickerValue = todo.dueAt
        picker?.isModalInPopover = true

        if let presentation = picker?.popoverPresentationController {
            presentation.delegate = self
            presentation.barButtonItem = sender
        }

        present(picker!, animated: true, completion: nil)
    }

}

extension MMTodoTextViewController: TodoPickerViewControllerDelegate {

    func didCancel(indexPath: IndexPath?) {
    }

    func didSelect(selection: Any, ofType pickerType: TodoPickerType, indexPath: IndexPath?) {
//        Swift.print("Selected: \(selection) ofType: \(pickerType)")

        switch pickerType {
        case .priority:
            todo.priority = selection as! MMTodo.Priority
            priorityButton.title = todo.priority.rawValue
            needsSaving = true
        case .status:
            todo.status = selection as! MMTodo.Status
            statusButton.title = todo.status.rawValue
            needsSaving = true
        case .createDate:
            todo.createdAt = selection as! Date
            needsSaving = true
        case .dueDate:
            todo.dueAt = selection as? Date
            needsSaving = true
        default:
            Swift.print("Never!")
        }
    }
}

extension MMTodoTextViewController: UIPopoverPresentationControllerDelegate {

    // MARK: Popover delegate functions

    // Override iPhone behavior that presents a popover as fullscreen.
    // i.e. now it shows same popover box within on iPhone & iPad
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // show popover box for iPhone and iPad both
        return UIModalPresentationStyle.none
    }
    
}

