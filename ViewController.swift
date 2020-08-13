//
//  ViewController.swift
//  MyFirstApp
//
//  Created by Changhee Han on 2020/07/07.
//

import UIKit
import SQLite3  // SQLite3 데이터베이스를 사용합니다. 앱 파일과 데이터베이스 파일이 따로 존재하고, 두 파일을 연결하여 정보를 주고받는 방식으로 사용됩니다.

class ViewController: UIViewController {
    
    var db: OpaquePointer?                              // db: 데이터베이스 파일을 가리키는 포인터 
    var posts = Array<Dictionary<String, String>>()     // 데이터베이스 테이블에 저장된 데이터를 받아서 저장하는 변수
    var selectedRow: Int = 0                            // 피드(Feed)에서 선택한 게시글의 줄 번호를 저장하는 변ㅅ
    
    @IBOutlet weak var submitName: UITextField!
    @IBOutlet weak var submitPhone: UITextField!
    @IBOutlet weak var submitLocation: UITextField!
    @IBOutlet weak var submitDesc: UITextView!
    @IBOutlet weak var dataTable: UITableView!
    
    // viewDidLoad() 함수는 앱을 실행할 때 호출됩니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        db = openDatabase()
        if db != nil {
            createTable()
            refreshData()
        }
    }
    
    // onSubmit() 함수는 'Submit' 버튼이 눌렸을 때 호출됩니다.
    @IBAction func onSubmit(_ sender: Any) {
        if db != nil {
            insertPost(name: submitName.text!, phone: submitPhone.text!, location: submitLocation.text!, desc: submitDesc.text!)
        }
        clearText()
    }
    
    // onClear() 함수는 'Clear' 버튼이 눌렸을 때 호출됩니다.
    @IBAction func onClear(_ sender: Any) {
        clearText()
    }
    
    private func clearText() {
        submitName.text = ""
        submitPhone.text = ""
        submitLocation.text = ""
        submitDesc.text = "Input further explanation here..."
    }
    
    // 'Petcare.db' 데이터베이스 파일이 존재하지 않다면 생성합니다.
    private var dbPath: String {
        return try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Petcare.db").path
    }
    
    // openDatabase() 함수는 데이터베이스 파일을 가리키는 포인터를 가져오는 역할을 합니다.
    private func openDatabase() -> OpaquePointer? {
        var pointer: OpaquePointer? = nil
        let result = sqlite3_open(self.dbPath, &pointer)
        
        if result == SQLITE_OK {
            return pointer
        }
        return nil
    }
    
    // closeDatabase() 함수는 데이터베이스 파일을 닫습니다.
    private func closeDatabase(_ pointer: OpaquePointer?) {
        if pointer != nil {
            sqlite3_close(pointer!)
        }
    }
    
    // createTable() 함수는 데이터베이스 테이블을 만들 때 사용합니다. 데이터베이스가 엑셀 파일이라면, 테이블은 엑셀에서 실제 데이터를 담는 시트(Sheet)라고 할 수 있습니다.
    // 4개의 함수 createTable(), getPost(), deletePost(...), insertPost(...)는 모두 데이터베이스에 명령을 전달하고 결과를 확인하는 방식으로 작동합니다. 
    private func createTable() {
        var createStatement: OpaquePointer? = nil       // 데이터베이스에 명령할 내용을 담는 포인터입니다. 데이터베이스를 가리키는 포인터인 db와는 다릅니다 :)
        
        // 아래 query 변수는 SQL (데이터베이스 명령문) 언어로 작성되어 테이블 생성과 관련된 내용을 담고 있습니다.
        let query = "CREATE TABLE IF NOT EXISTS Post (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(255) NOT NULL, phone VARCHAR(255), location VARCHAR(255), desc TEXT);"
        
        if sqlite3_prepare_v2(db, query, -1, &createStatement, nil) == SQLITE_OK {      // SQLITE_OK와 SQLITE_DONE을 이용해 명령 처리가 정상적으로 되었는지 확인합니다.
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
        
        sqlite3_finalize(createStatement)       // 데이터베이스를 향한 명령이 끝났음을 알려줍니다.
    }
    
    // getPost() 함수는 테이블에 들어있는 데이터를 가져오는데 사용됩니다.
    // 4개의 함수 createTable(), getPost(), deletePost(...), insertPost(...)는 모두 데이터베이스에 명령을 전달하고 결과를 확인하는 방식으로 작동합니다. 
    private func getPost() {
        var getStatement: OpaquePointer? = nil      // 데이터베이스에 명령할 내용을 담는 포인터입니다. 데이터베이스를 가리키는 포인터인 db와는 다릅니다 :)
        let query = "SELECT * FROM Post;"           // 좌측의 query 변수는 SQL (데이터베이스 명령문) 언어로 작성되어 데이터를 데이터베이스로부터 불러오는 내용을 담고 있습니다.
        
        if sqlite3_prepare_v2(db, query, -1, &getStatement, nil) == SQLITE_OK {     // SQLITE_OK를 이용해 명령 처리가 정상적으로 되었는지 확인합니다.
            posts.removeAll()
            
            while sqlite3_step(getStatement) == SQLITE_ROW {                        // while 반복문 안에서 데이터를 한 줄씩 차례로 불러옵니다.
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
        
        sqlite3_finalize(getStatement)          // 데이터베이스를 향한 명령이 끝났음을 알려줍니다.
    }
    
    // deletePost() 함수는 테이블에 들어있는 특정 데이터를 제거하는데 사용됩니다.
    // 4개의 함수 createTable(), getPost(), deletePost(...), insertPost(...)는 모두 데이터베이스에 명령을 전달하고 결과를 확인하는 방식으로 작동합니다. 
    private func deletePost(id: Int) {
        var deleteStatement: OpaquePointer? = nil                       // 데이터베이스에 명령할 내용을 담는 포인터입니다. 데이터베이스를 가리키는 포인터인 db와는 다릅니다 :)
        let query = "DELETE FROM Post WHERE id = " + String(id) + ";"   // 좌측의 query 변수는 SQL (데이터베이스 명령문) 언어로 작성되어 데이터를 제거하는 내용을 담고 있습니다.
        
        if sqlite3_prepare_v2(db, query, -1, &deleteStatement, nil) == SQLITE_OK {      // SQLITE_OK와 SQLITE_DONE을 이용해 명령 처리가 정상적으로 되었는지 확인합니다.
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
        
        sqlite3_finalize(deleteStatement)       // 데이터베이스를 향한 명령이 끝났음을 알려줍니다.
    }
    
    // insertPost() 함수는 테이블에 데이터를 추가하는데 사용됩니다.
    // 4개의 함수 createTable(), getPost(), deletePost(...), insertPost(...)는 모두 데이터베이스에 명령을 전달하고 결과를 확인하는 방식으로 작동합니다. 
    private func insertPost(name: String, phone: String, location: String, desc: String) {
        var insertStatement: OpaquePointer? = nil           // 데이터베이스에 명령할 내용을 담는 포인터입니다. 데이터베이스를 가리키는 포인터인 db와는 다릅니다 :)
        
        // 아래 query 변수는 SQL (데이터베이스 명령문) 언어로 작성되어 데이터 추가와 관련된 내용을 담고 있습니다.
        let query = "INSERT INTO Post (name, phone, location, desc) VALUES ('" + name + "','" + phone + "','" + location + "','" + desc + "');"
        
        if sqlite3_prepare_v2(db, query, -1, &insertStatement, nil) == SQLITE_OK {      // SQLITE_OK와 SQLITE_DONE을 이용해 명령 처리가 정상적으로 되었는지 확인합니다.
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
        
        sqlite3_finalize(insertStatement)       // 데이터베이스를 향한 명령이 끝났음을 알려줍니다.
    }
    
    private func refreshData() {
        getPost()
        if dataTable != nil {
            DispatchQueue.main.async {`         // DispatchQueue에서 아래 reloadData()를 실행하여 렉이 걸리는 것을 방지합니다.
                self.dataTable.reloadData()
            }
        }
    }
    
    // prepare() 함수는 화면이 전환될 때 (이 앱에서는 피드에 나열된 게시글을 눌렀을 때) 호출됩니다.
    // 게시물의 내용 정보를 FeedController 클래스로 전송합니다.
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
    // tableView(...numberOfRowsInSection) 함수는 데이터베이스에 등록된 게시글이 총 몇 개인지 확인하고 피드를 구성합니다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Cell creation breakpoint: " + String(posts.count))
        return posts.count
    }
    
    // tableView(...cellForRowAt) 함수는 데이터베이스에 등록되어 있는 게시물들의 제목을 가져와서 피드에 표시해줍니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        let singlePost : Dictionary<String, String> = posts[indexPath.row]
        cell.textLabel?.text = singlePost["name"]! + " (" + singlePost["location"]! + ")"
        
        return cell
    }
    
    // tableView(...didSelectRowAt) 함수는 피드에 표시된 게시물을 클릭했을 때 호출되며, 해당 게시물의 상세 정보를 출력하는 화면으로 전환하도록 합니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        self.performSegue(withIdentifier: "DataSegue", sender: self)
    }
}
