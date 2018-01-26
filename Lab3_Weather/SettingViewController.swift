//
//  SettingViewController.swift
//  Lab3_Weather
//
//  Created by FishLeaf on 17/12/2017.
//  Copyright © 2017 Jerry Lee. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var ButtonC: UIButton!
    @IBOutlet weak var ButtonF: UIButton!
    
    @IBAction func CelButton(_ sender: Any) {
        Celcius = true;
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
    }
    
    @IBAction func FerButton(_ sender: Any) {
        Celcius = false;
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ButtonC.titleLabel?.textColor = UIColor.blue
        ButtonF.titleLabel?.textColor = UIColor.gray
        
        
        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  

}
