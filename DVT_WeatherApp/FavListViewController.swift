//
//  FavListViewController.swift
//  DVT_WeatherApp
//
//  Created by Priteshsingh Chandel on 06/02/20.
//  Copyright © 2020 Priteshsingh Chandel. All rights reserved.
//

import UIKit

class FavListViewController: UIViewController, reloadVC {

    //MARK: IB OUTLETS
    @IBOutlet var favListTableView: UITableView!
    @IBOutlet var favLbl: UILabel!
    
    //MARK: VARIABLES
    var favName = [String]()
    var latArr = [String]()
    var lonArr = [String]()
    var index = Int()
    var weather = String()
    let color: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    
    //MARK: INITIALIZATION METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        // Do any additional setup after loading the view.
    }
    
    func initialize(){
        favListTableView.register(UINib(nibName: "FavListTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.view.backgroundColor = color
        favLbl.backgroundColor = UIColor.clear
        favLbl.textColor = UIColor.white
        let selectQuery = "select name,lat,lon from FavLocations"
        let selectAll = DBWrapper.sharedObj.selectAllTask(query:selectQuery)
        favName = (selectAll as? [String])!
        
        //newArray = DBWrapper.sharedObj.taskNameArray
        latArr = DBWrapper.sharedObj.latArr
        lonArr = DBWrapper.sharedObj.lonArr
        print("Favourites:\(favName)")
        favListTableView.delegate = self
        favListTableView.dataSource = self
        favListTableView.backgroundColor = UIColor.clear
    }
    
    
    //MARK: SEGUE METHOD
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFav"{
            let vc = segue.destination as! ViewController
            let index = (sender as! IndexPath).row
            vc.lat = Double(latArr[index])!
            vc.lon = Double(lonArr[index])!
            vc.placeName = favName[index]
        }
    }
    
    //MARK: TOUCH CONTROL METHOD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != favListTableView {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: PROTOCOL METHOD
    func reload(){
        DispatchQueue.main.async {
            self.initialize()
            self.favListTableView.reloadData()
        }
    }
    
}

//MARK: TABLEVIEW DELEGATE AND DATASOURCE METHODS
extension FavListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FavListTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.delegateCustom = self
        cell.cellBGView.layer.cornerRadius = 10
        cell.cellBGView.layer.masksToBounds = true
        cell.cellBGView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
        cell.cellBGView.layer.borderColor = UIColor.clear.cgColor
        cell.cellBGView.layer.borderWidth = 1
        cell.nameLbl.text = "  \(favName[indexPath.row])"
        cell.nameLbl.textAlignment = .left
        cell.nameLbl.textColor = UIColor.black
        cell.deleteBtn.backgroundColor = UIColor.clear
        cell.deleteBtn.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "showFav", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

//MARK: PROTOCOL TO RELOAD FAV LIST VC
protocol reloadVC {
    func reload();
}
