//
//  ViewController.swift
//  MyFirstApp
//
//  Created by Changhee Han on 2020/07/07.
//

import UIKit
import SQLite3

class ViewController: UIViewController {
    
    var db: OpaquePointer?
    var posts = Array<Dictionary<String, String>>()
    var selectedRow: Int = 0
    
    @IBOutlet weak var submitName: UITextField!
    @IBOutlet weak var submitPhone: UITextField!
    @IBOutlet weak var submitLocation: UITextField!
    @IBOutlet weak var submitDesc: UITextView!
    @IBOutlet weak var dataTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = openDatabase()
        if db != nil {
            createTable()
            refreshData()
        }
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        if db != nil {
            insertPost(name: submitName.text!, phone: submitPhone.text!, location: submitLocation.text!, desc: submitDesc.text!)
        }
        clearText()
    }
    
    @IBAction func onClear(_ sender: Any) {
        clearText()
    }
    
    private func clearText() {
        submitName.text = ""
        submitPhone.text = ""
        submitLocation.text = ""
        submitDesc.text = "Input further explanation here..."
    }
    
    private var dbPath: String {
        return try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Petcare.db").path
    }
    
    private func openDatabase() -> OpaquePointer? {
        var pointer: OpaquePointer? = nil
        let result = sqlite3_open(self.dbPath, &pointer)
        
        if result == SQLITE_OK {
            return pointer
        }
        return nil
    }
    
    private func closeDatabase(_ pointer: OpaquePointer?) {
        if pointer != nil {
            sqlite3_close(pointer!)
        }
    }
    
    private func createTable() {
        var createStatement: OpaquePointer? = nil
        
        let query = "CREATE TABLE IF NOT EXISTS Post (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(255) NOT NULL, phone VARCHAR(255), location VARCHAR(255), desc TEXT);"
        
        if sqlite3_prepare_v2(db, query, -1, &createStatement, nil) == SQLITE_OK {
            if sqlite3_step(createStatement) == SQLITE_DONE {
                print("Table successfully created.")
            }
            else {
                print("Error while sending query to create table.")
            }
        }
        else {
            print("Error while creating table.")
        }
        
        sqlite3_finalize(createStatement)
    }
    
    private func getPost() {
        var getStatement: OpaquePointer? = nil
        let query = "SELECT * FROM Post;"
        
        if sqlite3_prepare_v2(db, query, -1, &getStatement, nil) == SQLITE_OK {
            posts.removeAll()
            
            while sqlite3_step(getStatement) == SQLITE_ROW {
                let queryName = String(cString: sqlite3_column_text(getStatement, 1))
                let queryPhone = String(cString: sqlite3_column_text(getStatement, 2))
                let queryLocation = String(cString: sqlite3_column_text(getStatement, 3))
                let queryDesc = String(cString: sqlite3_column_text(getStatement, 4))
                
                let singlePost : Dictionary<String, String> = ["name":queryName, "phone":queryPhone, "location":queryLocation, "desc":queryDesc]
                
                print(singlePost)
                posts.append(singlePost)
            }
        }
        else {
            print("Error while collecting data.")
        }
        
        sqlite3_finalize(getStatement)
    }
    
    private func deletePost(id: Int) {
        var deleteStatement: OpaquePointer? = nil
        let query = "DELETE FROM Post WHERE id = " + String(id) + ";"
        
        if sqlite3_prepare_v2(db, query, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Data successfully deleted.")
            }
            else {
                print("Error while sending query to delete data.")
            }
        }
        else {
            print("Error while deleting data.")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    private func insertPost(name: String, phone: String, location: String, desc: String) {
        var insertStatement: OpaquePointer? = nil
        let query = "INSERT INTO Post (name, phone, location, desc) VALUES ('" + name + "','" + phone + "','" + location + "','" + desc + "');"
        
        if sqlite3_prepare_v2(db, query, -1, &insertStatement, nil) == SQLITE_OK {
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Data successfully inserted.")
            }
            else {
                print("Error while sending query to insert data.")
            }
        }
        else {
            print("Error while inserting data.")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    private func refreshData() {
        getPost()
        if dataTable != nil {
            DispatchQueue.main.async {
                self.dataTable.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination
        guard let fc = dest as? FeedController else {
            return
        }
        
        let post : Dictionary<String, String> = posts[selectedRow]
        fc.paramName = post["name"]
        fc.paramPhone = post["phone"]
        fc.paramLocation = post["location"]
        fc.paramDesc = post["desc"]
    }
}

extension ViewController :UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Cell creation breakpoint: " + String(posts.count))
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        let singlePost : Dictionary<String, String> = posts[indexPath.row]
        cell.textLabel?.text = singlePost["name"]! + " (" + singlePost["location"]! + ")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        self.performSegue(withIdentifier: "DataSegue", sender: self)
    }
}
