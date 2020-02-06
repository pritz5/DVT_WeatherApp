//
//  ForecastTableViewCell.swift
//  DVT_WeatherApp
//
//  Created by Priteshsingh Chandel on 03/02/20.
//  Copyright © 2020 Priteshsingh Chandel. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {

    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var tempLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
