//
//  ViewController.swift
//  MPSearchAndKill
//
//  Created by Luna Gao on 16/9/27.
//  Copyright © 2016年 luna.gao. All rights reserved.
//

import Cocoa
import Foundation

open class Row: NSObject {
    var COMMAND: String = ""
    var USER: String = ""
    var TYPE: String = ""
    var NODE: String = ""
    var NAME: String = ""
    var FD: String = ""
    var Tag: String = ""
    
    init(command inCommand: String, user inUser: String, type inType: String, node inNode: String, name inName: String, fd inFd: String, kill inKill: String) {
        COMMAND = inCommand
        USER = inUser
        TYPE = inType
        NODE = inNode
        NAME = inName
        FD = inFd
        Tag = "Kill:" + inKill
    }
}

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var portTextField: NSTextField!
    @IBOutlet weak var errorLabel: NSTextField!
    @IBOutlet weak var loading: NSProgressIndicator!
    
    @IBOutlet weak var tableView: NSTableView!
    
    var rows: [Row] = []
    var port: String = ""
    
    override func viewDidLoad() {
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            // Fallback on earlier versions
        }
        loading.isHidden = true
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func clickKill(_ sender: AnyObject) {
        let button = sender as! NSButton
        let value = button.title
        var valueArray = value.components(separatedBy: ":")
        killProc(PID: valueArray[1])
    }
    
    func killProc(PID: String) {
        search(refush: true, killCommand: "/bin/kill -9 " + PID)
        search(refush: true, killCommand: "")
    }

    @IBAction func clickSearchButton(_ sender: AnyObject) {
        search(refush: false, killCommand: "")
    }
    
    func search(refush: Bool, killCommand: String) {
        rows.removeAll()
        tableView.reloadData()
        loading.isHidden = false
        loading.startAnimation(nil)
        let portNumber = (portTextField.stringValue as NSString).intValue
        errorLabel.isHidden = true
        if portNumber == 0 {
            errorLabel.isHidden = false
            loading.isHidden = true
            return
        }
        if !refush {
            port = portTextField.stringValue
        }
        let str : String
        if killCommand == "" {
            str = callShell(command: "/usr/sbin/lsof -i :" + port)
        } else {
            str = callShell(command: killCommand)
        }
        addInRow(str: str)
        loading.stopAnimation(nil)
        loading.isHidden = true
    }
    
    func addInRow(str: String) {
        let myArray = str.components(separatedBy: "\n")
        for i in 1 ..< myArray.count {
            let rowString = myArray[i]
            var rowArray = rowString.components(separatedBy: " ")
            let arrayCount = rowArray.count
            for j in 0 ..< rowArray.count {
                if rowArray[arrayCount - 1 - j] == "" || rowArray[arrayCount - 1 - j] == " " {
                    rowArray.remove(at: arrayCount - 1 - j)
                }
            }
            if rowArray.count < 9 {
                continue
            }
            let oneRow = Row(command: rowArray[0], user: rowArray[2], type: rowArray[4], node: rowArray[7], name: rowArray[8] + rowArray[9], fd: rowArray[3], kill: rowArray[1])
            rows.append(oneRow)
        }
        tableView.reloadData()
    }
    
    func callShell(command: String) -> String! {
        let task = authorization(command: command)
        if task.err {
            return ""
        }
        task.privilegedTask?.waitUntilExit()
        
        // Read output file handle for data
        let readHandle = task.privilegedTask?.outputFileHandle()
        let outputData = readHandle!.readDataToEndOfFile()
        let result : NSString? = NSString(data: outputData, encoding: 4)
        return result as String!
    }
    
    func authorization(command: String) -> (err: Bool, privilegedTask: STPrivilegedTask?) {
        // Create task
        let privilegedTask = STPrivilegedTask()
        var args = command.components(separatedBy: " ")
        privilegedTask.setLaunchPath(args[0])
        args.remove(at: 0)
        privilegedTask.setArguments(args)
        
        // Setting working directory is optional, defaults to /
        // NSString *path = [[NSBundle mainBundle] resourcePath];
        // [privilegedTask setCurrentDirectoryPath:path];
        
        // Launch it, user is prompted for password
        let err = privilegedTask.launch()
        if (err != errAuthorizationSuccess) {
            if (err == errAuthorizationCanceled) {
                NSLog("User cancelled")
            } else {
                NSLog("Something went wrong")
            }
            return (true, nil)
        } else {
            NSLog("Task successfully launched")
        }
        return (false, privilegedTask)
    }
    
    open func numberOfRows(in tableView: NSTableView) -> Int {
        return rows.count
    }
    
    open func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return rows[row]
    }
}
