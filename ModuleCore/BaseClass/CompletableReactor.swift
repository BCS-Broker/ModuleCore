//
//  CompletableScene.swift
//  ModuleCore
//
//  Created by alexej_ne on 06/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import RxSwift
import RxCocoa

public class CompletableReactor<T>  {
    
    private let _onComplete = PublishSubject<T>()
    public lazy var onComplete: Single<T> = { return _onComplete.asSingle() }()
    
    public func complete(_ result: T) {
        _onComplete.onNext(result)
    }
    
    public func interrupt(_ error: Error = InterruptedError()) {
        _onComplete.onError(error)
    }
}

extension CompletableReactor where T == Void {
    public func complete() {
        complete(())
    }
}
