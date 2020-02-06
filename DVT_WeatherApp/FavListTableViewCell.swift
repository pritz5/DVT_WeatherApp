//
//  FavListTableViewCell.swift
//  DVT_WeatherApp
//
//  Created by Priteshsingh Chandel on 06/02/20.
//  Copyright © 2020 Priteshsingh Chandel. All rights reserved.
//

import UIKit

class FavListTableViewCell: UITableViewCell {

    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var deleteBtn: UIButton!
    
    var delegateCustom: reloadVC?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteActn(_ sender: UIButton) {
        let selectQuery = "select name,lat,lon from FavLocations"
        let select = DBWrapper.sharedObj.selectAllTask(query: selectQuery)
        let name = select as? [String]
        let deleteQuery = "delete from FavLocations where name='\(name![sender.tag])'"
        print(sender.tag)
        if DBWrapper.sharedObj.executeQuery(query: deleteQuery) {
            print("delete successful")
        }
        else{
            print("delete unsuccessful")
        }
        self.delegateCustom?.reload()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}



