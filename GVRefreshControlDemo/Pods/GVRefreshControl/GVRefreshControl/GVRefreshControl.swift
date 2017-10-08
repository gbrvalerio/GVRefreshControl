//
//  GVRefreshControl.swift
//  PullToRefreshDemo
//
//  Created by Gabriel Bezerra Valério on 05/10/17.
//

import UIKit

public class GVRefreshControl : UIRefreshControl {
    
    private var internalUpdateMethod:Method!
    private var subUpdateMethod:Method!
    
    //MARK: - Computed properties
    private var visibleHeight:CGFloat {
        return value(forKey: "_visibleHeight") as? CGFloat ?? 0
    }
    
    private var scrollView:UIScrollView? {
        return value(forKey: "_scrollView") as? UIScrollView
    }
    
    private var dataSourceHeight:CGFloat {
        return dataSource?.refreshControlHeight(self) ?? 100
    }
    
    //MARK: - Properties
    public var contentView:UIView? {
        return value(forKey: "_contentView") as? UIView
    }
    
    public var visiblePercentage:CGFloat {
        guard let scrollView = scrollView else { return 0 }
        let offsetY = scrollView.contentOffset.y
        if offsetY >= 0 || dataSourceHeight == 0 { return 0 }
        return -offsetY / dataSourceHeight
    }
    
    public var dataSource:GVRefreshControlDataSource?
    
    //MARK: - Initializers
    override public init() {
        super.init()
        commonInit()
    }
    
    override public  init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        internalUpdateMethod = class_getInstanceMethod(UIRefreshControl.self, Selector(("_update")))
        subUpdateMethod = class_getInstanceMethod(GVRefreshControl.self, #selector(self.subUpdate))
        
        method_exchangeImplementations(internalUpdateMethod, subUpdateMethod)
        
        //https://github.com/nst/iOS-Runtime-Headers
    }
    
    //MARK: - Lifecycle
    override public func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        let subviewClass = String(describing: type(of: subview))
        if subviewClass == "_UIRefreshControlModernContentView" {
            subview.subviews.forEach { //removing the activity indicator and so
                $0.removeFromSuperview()
            }
            return
        }
        
    }
    
    override public func layoutSubviews() {
        contentView?.frame = CGRect(x: 0, y: 0, width: contentView?.frame.width ?? 0, height: dataSourceHeight)
        
        super.layoutSubviews()
    }
    
    //MARK: - Subview proxying
    //some state logic and layout is present on the _UIRefreshControlModernContentView (ContainerView) class so we proxy the subview inserting to it.
    override public func addSubview(_ view: UIView) {
        guard contentView !== view else { return }
        contentView?.addSubview(view)
    }
    
    override public func insertSubview(_ view: UIView, at index: Int) {
        guard contentView !== view else {
            super.insertSubview(view, at: index)
            return
        }
        contentView?.insertSubview(view, at: index)
    }
    
    override public func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
        guard contentView !== view else { return }
        contentView?.insertSubview(view, aboveSubview: siblingSubview)
    }
    
    override public func insertSubview(_ view: UIView, belowSubview siblingSubview: UIView) {
        guard contentView !== view else { return }
        contentView?.insertSubview(view, belowSubview: siblingSubview)
    }
    
    //MARK: - Reimplementations
    @objc private func subUpdate() {
        let viewBehaviour = dataSource?.refreshControl(self, viewBehaviourFor: self.visiblePercentage) ?? .fixedTop
        DispatchQueue.main.async(execute: handleFrameUpdate(for: viewBehaviour))
        //must pass the subupdatemethod because the implementations are exchanged.
        MethodInvoker.invokeVoidMethod(with: subUpdateMethod, for: self)
    }
    
    @objc private func _refreshControlHeight() -> CGFloat {
        return dataSourceHeight
    }
    
    //MARK: - Business
    private func handleFrameUpdate(for behaviour:GVRefreshControlViewBehaviour) -> (() -> Void) {
        switch behaviour {
        case .fixedBottom:
            return fixedBottomBehaviour
        case .stretches:
            return stretchBehaviour
        case .fixedTop:
            return fixedTopBehaviour
        }
    }
    
    //MARK: - Behaviours
    private func stretchBehaviour() {
        let scaleY = max(self.visiblePercentage, 0.01)
        self.transform = CGAffineTransform(scaleX: 1.0, y: scaleY)
    }
    
    private func fixedBottomBehaviour() {
        self.frame.origin.y = -self.dataSourceHeight
        self.transform = .identity
    }
    
    private func fixedTopBehaviour() {
        guard let scrollView = scrollView else { return }
        
        if visiblePercentage < 1 {
            stretchBehaviour()
        } else {
            self.frame.origin.y = scrollView.contentOffset.y
            self.transform = .identity
        }
    }
}
