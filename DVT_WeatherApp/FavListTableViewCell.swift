//
//  FavListTableViewCell.swift
//  DVT_WeatherApp
//
//  Created by Priteshsingh Chandel on 06/02/20.
//  Copyright © 2020 Priteshsingh Chandel. All rights reserved.
//

import UIKit

class FavListTableViewCell: UITableViewCell {

    //MARK: IB OUTLETS
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var deleteBtn: UIButton!
    @IBOutlet var cellBGView: UIView!
    
    //MARK: PROTOCOL DELEGATE METHOD
    var delegateCustom: reloadVC!
    
    //MARK: INITIALIZATION METHOD
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: ACTION METHOD
    @IBAction func deleteActn(_ sender: UIButton) {
        let selectQuery = "select name,lat,lon from FavLocations"
        let select = DBWrapper.sharedObj.selectAllTask(query: selectQuery)
        let name = select as? [String]
        let deleteQuery = "delete from FavLocations where name='\(name![sender.tag])'"
        print(sender.tag)
        
        DispatchQueue.main.async {
            if DBWrapper.sharedObj.executeQuery(query: deleteQuery) {
                
                print("delete successful")
            }
            else{
                print("delete unsuccessful")
            }
            self.delegateCustom?.reload()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}



