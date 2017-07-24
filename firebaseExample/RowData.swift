//
//  RowData.swift
//  firebaseExample
//
//  Created by nakadoribooks on 2017/07/24.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import FirebaseDatabase
import RxSwift

class RowData: NSObject {

    private var snapshot:DataSnapshot!
    var changed:Variable<RowData>!
    
    init(snapshot:DataSnapshot){
        
        super.init()
        
        self.snapshot = snapshot
        self.changed = Variable<RowData>(self)
        
        observe()
    }
    
    private func observe(){
        self.snapshot.ref.observe(.value, with: { (snapshot) in

            if snapshot.value is NSNull{
                return
            }
            
            self.snapshot = snapshot
            self.changed.value = self
        })
    }
    
    deinit {
        self.snapshot.ref.removeAllObservers()
    }
    
    var key:String{
        get{
            return snapshot.key
        }
    }
    
    var title:String{
        get{
            if let val = snapshot.childSnapshot(forPath: "title").value as? String{
                return val
            }
            
            return "undefined"
        }
    }
    
    var like:Int{
        get{
            if let val = snapshot.childSnapshot(forPath: "like").value as? Int{
                return val
            }
            
            return 0
        }
    }
    
    func addLike(){
        self.snapshot.ref.updateChildValues([
            "like":self.like + 1
        ])
    }
    
    func delete(){
        self.snapshot.ref.removeValue()
    }
    
    static func createList(snapshotList:[DataSnapshot])->[RowData]{
        var results:[RowData] = []
        for snapshot in snapshotList{
            let row = RowData(snapshot: snapshot)
            results.append(row)
        }
        
        return results
    }
    
}
