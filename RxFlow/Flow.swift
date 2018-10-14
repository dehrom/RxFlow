//
//  Flow.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-23.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxSwift
import UIKit

private var subjectContext: UInt8 = 0

/// A Flow defines a clear navigation area. Combined to a Step it leads to a navigation action
public protocol Flow: Presentable {
    /// Resolves NextFlowItems according to the Step, in the context of this very Flow
    ///
    /// - Parameters:
    ///   - step: the Step emitted by one of the Steppers declared in the Flow
    /// - Returns: the NextFlowItems matching the Step. These NextFlowItems determines the next navigation steps (Presentables to display / Steppers to listen)
    func navigate(to step: Step) -> NextFlowItems

    /// the Presentable on which rely the navigation inside this Flow. This method must always give the same instance
    var root: Presentable { get }
}

extension Flow {
    /// Inner/hidden Rx Subject in which we push the "Ready" event
    var flowReadySubject: PublishSubject<Bool> {
        return synchronized {
            if let subject = objc_getAssociatedObject(self, &subjectContext) as? PublishSubject<Bool> {
                return subject
            }
            let newSubject = PublishSubject<Bool>()
            objc_setAssociatedObject(self, &subjectContext, newSubject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newSubject
        }
    }

    /// the Rx Obsersable that will be triggered when the first presentable of the Flow is ready to be used
    var rxFlowReady: Single<Bool> {
        return flowReadySubject.take(1).asSingle()
    }
}

/// Utility functions to synchronize Flows readyness
public class Flows {
    private static let disposeBag = DisposeBag()

    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flows: Flow(s) to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func whenReady<RootType: UIViewController>(flows: [Flow],
                                                             block: @escaping ([RootType]) -> Void) {
        let flowObservables = flows.map { transform($0, type: RootType.self) }
        Observable.zip(flowObservables)
            .bind(onNext: { block($0) })
            .disposed(by: Flows.disposeBag)
    }

    // swiftlint:disable next function_parameter_count
    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - flow3: third Flow to be observed
    ///   - flow4: fourth Flow to be observed
    ///   - flow5: fifth Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func whenReady<
        RootType1: UIViewController,
        RootType2: UIViewController,
        RootType3: UIViewController,
        RootType4: UIViewController,
        RootType5: UIViewController
    >(
        flow1: Flow,
        flow2: Flow,
        flow3: Flow,
        flow4: Flow,
        flow5: Flow,
        block: @escaping (
            _ flow1Root: RootType1,
            _ flow2Root: RootType2,
            _ flow3Root: RootType3,
            _ flow4Root: RootType4,
            _ flow5Root: RootType5
        ) -> Void
    ) {
        Observable.zip(
            transform(flow1, type: RootType1.self),
            transform(flow2, type: RootType2.self),
            transform(flow3, type: RootType3.self),
            transform(flow4, type: RootType4.self),
            transform(flow5, type: RootType5.self)
        ).bind(onNext: { block($0, $1, $2, $3, $4) })
            .disposed(by: Flows.disposeBag)
    }

    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - flow3: third Flow to be observed
    ///   - flow4: fourth Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func whenReady<
        RootType1: UIViewController,
        RootType2: UIViewController,
        RootType3: UIViewController,
        RootType4: UIViewController
    >(
        flow1: Flow,
        flow2: Flow,
        flow3: Flow,
        flow4: Flow,
        block: @escaping (_ flow1Root: RootType1, _ flow2Root: RootType2, _ flow3Root: RootType3, _ flow4Root: RootType4) -> Void
    ) {
        Observable.zip(
            transform(flow1, type: RootType1.self),
            transform(flow2, type: RootType2.self),
            transform(flow3, type: RootType3.self),
            transform(flow4, type: RootType4.self)
        ).bind(onNext: { block($0, $1, $2, $3) })
            .disposed(by: Flows.disposeBag)
    }

    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - flow3: third Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func whenReady<
        RootType1: UIViewController,
        RootType2: UIViewController,
        RootType3: UIViewController
    >(
        flow1: Flow,
        flow2: Flow,
        flow3: Flow,
        block: @escaping (_ flow1Root: RootType1, _ flow2Root: RootType2, _ flow3Root: RootType3) -> Void
    ) {
        Observable.zip(
            transform(flow1, type: RootType1.self),
            transform(flow2, type: RootType2.self),
            transform(flow3, type: RootType3.self)
        ).bind(onNext: { block($0, $1, $2) })
            .disposed(by: Flows.disposeBag)
    }

    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func whenReady<RootType1: UIViewController, RootType2: UIViewController>(
        flow1: Flow,
        flow2: Flow,
        block: @escaping (_ flow1Root: RootType1, _ flow2Root: RootType2) -> Void
    ) {
        Observable.zip(
            transform(flow1, type: RootType1.self),
            transform(flow2, type: RootType2.self)
        ).bind(onNext: { block($0, $1) })
            .disposed(by: Flows.disposeBag)
    }

    /// Allow to be triggered only when Flow given as parameters is ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: Flow to be observed
    ///   - block: block to execute whenever the Flow is ready to use
    public static func whenReady<RootType: UIViewController>(flow1: Flow, block: @escaping (_ flowRoot1: RootType) -> Void) {
        transform(flow1, type: RootType.self)
            .bind(onNext: { block($0) })
            .disposed(by: Flows.disposeBag)
    }

    private static func transform<RootType: UIViewController>(_ flow: Flow, type _: RootType.Type) -> Observable<RootType> {
        return flow.rxFlowReady
            .asObservable()
            .take(1)
            .do(onNext: { _ in
                assert(flow.root is RootType, "Type mismatch, Flow root type do not match the type awaited in the block")
            })
            .flatMap { _ in Observable.from(optional: flow.root as? RootType) }
    }
}
