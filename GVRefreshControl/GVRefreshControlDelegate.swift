//
//  GVRefreshControlDelegate.swift
//  PullToRefreshDemo
//
//  Created by Gabriel Bezerra Valério on 06/10/17.
//

import UIKit

public enum GVRefreshControlViewBehaviour {
    case stretches
    case fixedBottom
    case fixedTop
}

public protocol GVRefreshControlDataSource : class {
    
    func refreshControlHeight(_ refreshControl:GVRefreshControl) -> CGFloat
    func refreshControl(_ refreshControl:GVRefreshControl, viewBehaviourFor progress:CGFloat) -> GVRefreshControlViewBehaviour
    
}
