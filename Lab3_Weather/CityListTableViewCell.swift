//
//  CityListTableViewCell.swift
//  Lab3_Weather
//
//  Created by Jerry Lee on 12/7/17.
//  Copyright © 2017 Jerry Lee. All rights reserved.
//

import UIKit

class CityListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityWeaterLabel: UILabel!
    @IBOutlet weak var cityTempLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
