//
//  Presentable.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxSwift
import UIKit.UIViewController

/// An abstraction of what can be presented to the screen. For now, UIViewControllers and Flows are Presentable
public protocol Presentable: HasDisposeBag {
    /// Rx Observable that triggers a bool indicating if the current Presentable is being displayed (applies to UIViewController, Warp or UIWindow for instance)
    var rxVisible: Observable<Bool> { get }

    /// Rx Observable (Single trait) triggered when this presentable is displayed for the first time
    var rxFirstTimeVisible: Single<Void> { get }

    /// Rx Observable (Single trait) triggered when this presentable is dismissed
    var rxDismissed: Single<Void> { get }
}

extension Presentable where Self: UIViewController {
    /// Rx Observable that triggers a bool indicating if the current UIViewController is being displayed
    public var rxVisible: Observable<Bool> {
        return rx.displayed
    }

    /// Rx Observable (Single trait) triggered when this UIViewController is displayed for the first time
    public var rxFirstTimeVisible: Single<Void> {
        return rx.firstTimeViewDidAppear
    }

    /// Rx Observable (Single trait) triggered when this UIViewController is dismissed
    public var rxDismissed: Single<Void> {
        return rx.dismissed.map { _ -> Void in Void() }.take(1).asSingle()
    }
}

extension Presentable where Self: Flow {
    /// Rx Observable that triggers a bool indicating if the current Flow is being displayed
    public var rxVisible: Observable<Bool> {
        return root.rxVisible
    }

    /// Rx Observable (Single trait) triggered when this Flow is displayed for the first time
    public var rxFirstTimeVisible: Single<Void> {
        return root.rxFirstTimeVisible
    }

    /// Rx Observable (Single trait) triggered when this Flow is dismissed
    public var rxDismissed: Single<Void> {
        return root.rxDismissed
    }
}

extension Presentable where Self: UIWindow {
    /// Rx Observable (Single trait) triggered when this UIWindow is displayed for the first time
    public var rxFirstTimeVisible: Single<Void> {
        return rx.windowDidAppear.asSingle()
    }

    /// Rx Observable that triggers a bool indicating if the current UIWindow is being displayed
    public var rxVisible: Observable<Bool> {
        return rx.windowDidAppear.asObservable().map { true }
    }

    /// Rx Observable (Single trait) triggered when this UIWindow is dismissed
    public var rxDismissed: Single<Void> {
        return Single.never()
    }
}
