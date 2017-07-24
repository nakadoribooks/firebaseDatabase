//
//  ViewController.swift
//  firebaseExample
//
//  Created by nakadoribooks on 2017/07/24.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import FirebaseDatabase
import RxSwift
import RxCocoa

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var ref:DatabaseReference!
    private var dataList:[RowData] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference().child("data")
        
        setupTableView()
        setupButton()
        subscribe()
    }
    
    private func subscribe(){
        let query = ref.queryOrdered(byChild: "createdAtReverse")
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let list = snapshot.children.allObjects as? [DataSnapshot]  else{
                print("no list")
                return;
            }
            
            self.dataList = RowData.createList(snapshotList: list)
            self.tableView.reloadData()
            
            // 追加監視
            self.ref.observe(.childAdded, with: { (snapshot) in
                let addedData = RowData(snapshot: snapshot)
                for exists in self.dataList{
                    if addedData.key == exists.key{
                        return
                    }
                }
                
                self.dataList.insert(addedData, at: 0)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            })
            
            // 削除監視
            self.ref.observe(.childRemoved, with: { (snapshot) in
                let removedData = RowData(snapshot: snapshot)
                guard let removedIndex = self.dataList.index(where: { (row) -> Bool in
                    return row.key == removedData.key
                }) else{
                    return
                }
                
                self.dataList.remove(at: removedIndex)
                self.tableView.deleteRows(at: [IndexPath(row: removedIndex, section: 0)], with: .automatic)
            })
            
        }, withCancel: nil)
    }
    
    private func setupTableView(){
        tableView.frame.size = view.frame.size
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 44, 0)
        view.addSubview(tableView)
    }
    
    private func setupButton(){
        let button = UIButton(frame: CGRect(x: 0, y: view.frame.size.height - 44, width: view.frame.size.width, height: 44))
        button.backgroundColor = UIColor.blue
        button.setTitle("追加", for: .normal)
        view.addSubview(button)
        
        button.rx.tap.subscribe { _ in
            button.backgroundColor = UIColor.cyan
            UIView.animate(withDuration: 0.4, animations: {
                button.backgroundColor = UIColor.blue
            })
            let random = Int(arc4random_uniform(UInt32(self.messageList.count)))
            let message = self.messageList[random]
            self.addData(title: message)
        }
    }
    
    private let messageList:[String] = [
        "(^_^)", "(^o^)", "(^^)", "(^-^)", "（●＾o＾●）", "（＾◇＾）", "(*^_^*)", "(*´ｰ`)"
        , "(*´∀｀*)", "(*´ω｀*)", "(*´艸｀*)", "(/ω＼)", "(^_^)V", "(^o^)V", "ヽ(=´▽`=)ﾉ"
        , "o(^o^)o", "＼(^_^ )( ^_^)／", "σ(^_^)", "σ(´∀｀)"
    ]
    
    private func addData(title:String){
        let timestamp:Int = Int(NSDate().timeIntervalSince1970)
        let data:[String:Any] = ["title":title, "like":0
            , "createdAt": timestamp
            , "createdAtReverse": 1 - timestamp
        ]
        ref.childByAutoId().setValue(data)
    }

    // UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle != .delete {
            return
        }
        
        let removedData = dataList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        removedData.delete()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataList[indexPath.row]
        data.addLike()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RowCell"
        var cell:RowTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! RowTableViewCell?
        
        if cell == nil{
            cell = RowTableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        
        let row = dataList[indexPath.row]
        cell?.reload(rowData: row)
        
        return cell!
    }

}

