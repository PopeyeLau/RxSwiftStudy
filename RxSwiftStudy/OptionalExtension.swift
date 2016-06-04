//
//  OptionalExtension.swift
//  RxSwiftStudy
//
//  Created by Popeye Lau on 16/5/31.
//  Copyright © 2016年 FavourFree. All rights reserved.
//

import Foundation
public extension Optional {

    @warn_unused_result
    func filter(@noescape predicate: Wrapped -> Bool) -> Optional {

        return map(predicate) == .Some(true) ? self : .None
    }

    @warn_unused_result
    func mapNil(@noescape predicate: Void -> Wrapped) -> Optional {

        return self ?? .Some(predicate())
    }

    @warn_unused_result
    func flatMapNil(@noescape predicate: Void -> Optional) -> Optional {

        return self ?? predicate()
    }

    func then(@noescape f: Wrapped -> Void) {

        if let wrapped = self { f(wrapped) }
    }

    @warn_unused_result
    func maybe<U>(defaultValue: U, @noescape f: Wrapped -> U) -> U {

        return map(f) ?? defaultValue
    }

    @warn_unused_result
    func onSome(@noescape f: Wrapped -> Void) -> Optional {

        then(f)
        return self
    }

    @warn_unused_result
    func onNone(@noescape f: Void -> Void) -> Optional {

        if isNone { f() }
        return self
    }

    var isSome: Bool {

        return self != nil
    }
    
    var isNone: Bool {
        
        return !isSome
    }
}