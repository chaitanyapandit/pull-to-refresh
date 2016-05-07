//
//  ESRefreshComponent.swift
//
//  Created by egg swift on 16/4/7.
//  Copyright (c) 2013-2015 ESPullToRefresh (https://github.com/eggswift/pull-to-refresh)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

public typealias ESRefreshHandler = () -> ()

public class ESRefreshComponent: UIView {
    
    private static var context = "ESRefreshKVOContext"
    private static let offsetKeyPath = "contentOffset"
    private static let contentSizeKeyPath = "contentSize"
    
    public weak var scrollView: UIScrollView?
    /// 刷新事件的回调函数
    public var handler: ESRefreshHandler?
    /// @param animator 刷新控件的动画处理视图，自定义必须遵守以下两个协议
    public var animator: protocol<ESRefreshProtocol, ESRefreshAnimatorProtocol>!
    /// 设置是否为加载状态
    public var animating: Bool = false
    public var loading: Bool = false {
        didSet {
            if loading != oldValue {
                if loading {
                    startAnimating()
                } else {
                    stopAnimating()
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.FlexibleLeftMargin, .FlexibleWidth, .FlexibleRightMargin]
    }
    
    convenience public init(frame: CGRect, handler: ESRefreshHandler) {
        self.init(frame: frame)
        self.handler = handler
        self.animator = ESRefreshAnimator.init()
    }
    
    convenience public init(frame: CGRect, handler: ESRefreshHandler, customAnimator animator: protocol<ESRefreshProtocol, ESRefreshAnimatorProtocol>) {
        self.init(frame: frame)
        self.handler = handler
        self.animator = animator
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver()
    }
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        /// Remove observer from superview
        removeObserver()
        /// Add observer to new superview
        addObserver(newSuperview)
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.scrollView = self.superview as? UIScrollView
        if let _ = animator {
            let v = animator.animatorView
            if v.superview == nil {
                let inset = animator.animatorInsets
                self.addSubview(v)
                v.frame = CGRect.init(x: inset.left,
                                      y: inset.right,
                                      width: self.bounds.size.width - inset.left - inset.right,
                                      height: self.bounds.size.height - inset.top - inset.bottom)
                v.autoresizingMask = [.FlexibleLeftMargin,
                                      .FlexibleWidth,
                                      .FlexibleRightMargin,
                                      .FlexibleTopMargin,
                                      .FlexibleHeight,
                                      .FlexibleBottomMargin]
            }
        }
    }
    
}

extension ESRefreshComponent /* KVO methods */ {
    
    private func addObserver(view: UIView?) {
        if let scrollView = view as? UIScrollView {
            scrollView.addObserver(self, forKeyPath: ESRefreshComponent.offsetKeyPath, options: [.Initial, .New], context: &ESRefreshComponent.context)
            scrollView.addObserver(self, forKeyPath: ESRefreshComponent.contentSizeKeyPath, options: [.Initial, .New], context: &ESRefreshComponent.context)
        }
    }
    
    private func removeObserver() {
        if let scrollView = superview as? UIScrollView {
            scrollView.removeObserver(self, forKeyPath: ESRefreshComponent.offsetKeyPath, context: &ESRefreshComponent.context)
            scrollView.removeObserver(self, forKeyPath: ESRefreshComponent.contentSizeKeyPath, context: &ESRefreshComponent.context)
        }
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &ESRefreshComponent.context {
            guard userInteractionEnabled == true && hidden == false else {
                return
            }
            if keyPath == ESRefreshComponent.contentSizeKeyPath {
                sizeChangeAction(object: object, change: change)
            } else if keyPath == ESRefreshComponent.offsetKeyPath {
                offsetChangeAction(object: object, change: change)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
}

extension ESRefreshComponent /* Action */ {

    func startAnimating() -> Void {
        animating = true
    }
    
    func stopAnimating() -> Void {
        animating = false
    }

    //  ScrollView contentSize change action
    func sizeChangeAction(object object: AnyObject?, change: [String : AnyObject]?) {
        
    }
    
    //  ScrollView offset change action
    func offsetChangeAction(object object: AnyObject?, change: [String : AnyObject]?) {
        
    }
    
}
