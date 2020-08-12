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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        feedName.text = paramName
        feedPhone.text = paramPhone
        feedLocation.text = paramLocation
        feedDesc.text = paramDesc
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
}
