# MMTodo

[![CI Status](http://img.shields.io/travis/MatthewMerritt/MMTodo.svg?style=flat)](https://travis-ci.org/MatthewMerritt/MMTodo)
[![Version](https://img.shields.io/cocoapods/v/MMTodo.svg?style=flat)](http://cocoapods.org/pods/MMTodo)
[![License](https://img.shields.io/cocoapods/l/MMTodo.svg?style=flat)](http://cocoapods.org/pods/MMTodo)
[![Platform](https://img.shields.io/cocoapods/p/MMTodo.svg?style=flat)](http://cocoapods.org/pods/MMTodo)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

MMTodo is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```swift
pod 'MMTodo'
```

## Usage iOS

1. In ViewController File, include MMTodo
```swift
import MMTodo
```

2. In ViewController Class, add these
```swift

// Get an instance of the MMTodoModel
public var todoModel = MMTodoModel.shared
```

3. In ViewController.ViewDidLoad function, initialize MMTodo
```swift
// Setup the ping and MySQL Information
todoModel.settings.pingHost = "ping Host"
todoModel.settings.mySqlHost = "MySQL Host"
todoModel.settings.mySqlUsername = "MySQL Username"
todoModel.settings.mySqlPassword = "MySQL Password"
todoModel.settings.project = "Project"

// Start the listener for MySQL connection changes
self.todoModel.listen()
```

4. Add Storyboard-iOS.storyboard  to Target -> MMTodo -> Build Phases  -> Copy Bundle Resources

5. Now MMTodo will be available when you *shake* your device.

## Usage macOS

1. In ViewController File, include MMTodo
```swift
import MMTodo
```

2. In ViewController Class, add these
```swift
// Get an Instance of the MMTodoModel, MMTodoMenu and MMTodoWindowController
let todoModel = MMTodoModel.shared
var todoMenu: MMTodoMenu!
var todoWindowController: MMTodoWindowController?
```

3. In ViewController.ViewDidLoad function, initialize MMTodo
```swift
// Create Menu and place it on the Help Menu
todoMenu = MMTodoMenu(from: self, wth: #selector(self.todoMenuAction(_:)))

// Setup the ping and MySQL Information
todoModel.settings.pingHost = "ping Host"
todoModel.settings.mySqlHost = "MySQL Host"
todoModel.settings.mySqlUsername = "MySQL Username"
todoModel.settings.mySqlPassword = "MySQL Password"
todoModel.settings.project = "Project"

// Start the listener for MySQL connection changes
self.todoModel.listen()
```

4. Add the menu functions to your ViewController Class
```swift
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
```

5. Add MMTodoWindowController.xib, Bar.png and Save.pdf to Target -> MMTodo -> Build Phases  -> Copy Bundle Resources

6. Now MMTodo will be available by Command-Shift-T or in your Help Menu.

## Requirements

+ Xcode 9
+ Swift 4.0+

## Dependencies

+ MMTodo uses [MySqlSwiftNative](https://github.com/mcorega/MySqlSwiftNative) for MySQL connectivity.

   *Currently MMTodo is using a manual install since there isn't a working Swift 4 Branch.*

## Todo

+ Add Todo Title edit in macOS

## Author

MatthewMerritt

## License

MMTodo is available under the MIT license. See the LICENSE file for more info.
