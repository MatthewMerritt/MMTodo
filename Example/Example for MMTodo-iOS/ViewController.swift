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

    // Get the single MMTodoModel, this will load settings from UserDefaults
    public var todoModel = MMTodoModel.shared

    @IBOutlet weak var connectDBButton: UIButton!

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Start the listener for MySQL connection changes
        self.todoModel.listen()

        connectDBButton.setImage(UIImage(named: "DBConfigure", in: Bundle.init(for: MMTodo.self), compatibleWith: nil), for: .normal)

    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

