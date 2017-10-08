//
//  ViewController.swift
//  GVRefreshControlDemo
//
//  Created by Gabriel Bezerra Valério on 08/10/17.
//  Copyright © 2017 Gabriel Bezerra Valério. All rights reserved.
//

import UIKit
import GVRefreshControl

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var model = ["0"]
    let refreshControl = GVRefreshControl()
    weak var refreshingView:UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureRefreshControl()
        configureRefreshView()
    }
    
    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(self.mustUpdateData(_:)), for: .valueChanged)
        refreshControl.dataSource = self
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    
    private func configureRefreshView() {
        let vw = UIView()
        vw.backgroundColor = .red
        
        refreshControl.addSubview(vw)
        
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.leftAnchor.constraint(equalTo: refreshControl.contentView!.leftAnchor).isActive = true
        vw.rightAnchor.constraint(equalTo: refreshControl.contentView!.rightAnchor).isActive = true
        vw.topAnchor.constraint(equalTo: refreshControl.contentView!.topAnchor).isActive = true
        vw.bottomAnchor.constraint(equalTo: refreshControl.contentView!.bottomAnchor).isActive = true
        
        refreshingView = vw
    }
    
    @objc func mustUpdateData(_ sender:Any) {
        UIView.animate(withDuration: 3) {
            self.refreshingView.backgroundColor = self.refreshingView.backgroundColor == .red ? .blue : .red
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.model.insert("\(self.model.count)", at: 0)
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }

}

extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = model[indexPath.row]
        return cell
    }
    
}

extension ViewController : GVRefreshControlDataSource {
    
    func refreshControlHeight(_ refreshControl:GVRefreshControl) -> CGFloat {
        return tableView.bounds.height / 3
    }
    
    func refreshControl(_ refreshControl:GVRefreshControl, viewBehaviourFor progress:CGFloat) -> GVRefreshControlViewBehaviour {
        return .stretches
    }
    
}

