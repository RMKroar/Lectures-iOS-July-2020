//
//  FeedController.swift
//  MyFirstApp
//
//  Created by Changhee Han on 2020/08/13.
//

import Foundation
import UIKit

class FeedController: UIViewController {
    @IBOutlet weak var feedName: UILabel!
    @IBOutlet weak var feedPhone: UILabel!
    @IBOutlet weak var feedLocation: UILabel!
    @IBOutlet weak var feedDesc: UITextView!
    public var paramName: String?
    public var paramPhone: String?
    public var paramLocation: String?
    public var paramDesc: String?
    
    // viewDidLoad() 함수는 앱이 실행될 때 호출됩니다.
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // viewWillAppear() 함수는 화면이 전환될 때마다 호출되어, ViewController로부터 받아온 게시물 내용 정보를 화면에 띄우는 역할을 합니다.
    override func viewWillAppear(_ animated: Bool) {
        feedName.text = paramName
        feedPhone.text = paramPhone
        feedLocation.text = paramLocation
        feedDesc.text = paramDesc
    }
    
    // onBack() 함수는 'Back' 버튼을 눌렀을 때 호출되며, 이전 화면으로 돌아가는 역할을 수행합니다.
    @IBAction func onBack(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
}
