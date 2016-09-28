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
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", String(format: "%@", "kill -9 " + PID)]
        task.standardOutput = pipe
        task.launch()
        search(refush: true)
    }

    @IBAction func clickSearchButton(_ sender: AnyObject) {
        search(refush: false)
    }
    
    func search(refush: Bool) {
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
        let str = callShell(command: "lsof -i :" + port)
        addInRow(str: str!)
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
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", String(format: "%@", command)]
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        task.launch()
        let result : NSString? = NSString(data: file.readDataToEndOfFile(), encoding: 4)
        return result as String!
    }
    
    open func numberOfRows(in tableView: NSTableView) -> Int {
        return rows.count
    }
    
    open func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return rows[row]
    }
}
