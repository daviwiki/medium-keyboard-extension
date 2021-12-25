//
//  ViewController.swift
//  MediumCustomKeyboard
//
//  Created by David Martinez on 19/12/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
}

