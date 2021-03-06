//
//  CompletableScene.swift
//  ModuleCore
//
//  Created by alexej_ne on 06/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import RxSwift
import RxCocoa

open class CompletableReactor<T>: BaseReactor  {
    
    private let _onComplete = PublishSubject<T>()
    public lazy var onComplete: Observable<T> = { return _onComplete.share().asObservable() }()
    
    public func complete(_ result: T) {
        _onComplete.onNext(result)
    }
    
    public func finish() {
        _onComplete.onCompleted()
    }
    
    public func interrupt(_ error: Error = InterruptedError()) {
        _onComplete.onError(error)
    }
    
    public func interruptByUser() {
        _onComplete.onError(UserInterruptedError())
    }
}

extension CompletableReactor where T == Void {
    public func complete() {
        complete(())
    }
}
