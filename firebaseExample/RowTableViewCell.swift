//
//  RowTableViewCell.swift
//  firebaseExample
//
//  Created by nakadoribooks on 2017/07/24.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import RxSwift

class RowTableViewCell: UITableViewCell {
    
    private var rowData:RowData? = nil
    private var disposeBag:DisposeBag? = nil
    
    func reload(rowData:RowData){
        self.disposeBag = nil
        
        let disposeBag = DisposeBag()
        
        self.rowData = rowData
        rowData.changed.asObservable().subscribe { [weak self] event in
            
            guard let s = self, let data = event.element else{
                return
            }
            
            s.updateViews(rowData: data)
        }.addDisposableTo(disposeBag)
        self.disposeBag = disposeBag
    }
    
    func updateViews(rowData:RowData){
        
        textLabel?.text = rowData.title
        detailTextLabel?.text = "\(rowData.like) like"
        
        self.setSelected(true, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.setSelected(false, animated: true)
        }
    }

}
