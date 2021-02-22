//
//  AssociatedObject.swift
//  Picsew
//
//  Created by Steven Mok on 2020/8/26.
//  Copyright © 2020 sugarmo. All rights reserved.
//

import ObjectiveC

final class AssociationKey<Value> {
    enum Policy {
        case retain
        case copy
        case assign

        var rawValue: objc_AssociationPolicy {
            switch self {
            case .retain:
                return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            case .copy:
                return .OBJC_ASSOCIATION_COPY_NONATOMIC
            case .assign:
                return .OBJC_ASSOCIATION_ASSIGN
            }
        }
    }

    let policy: Policy

    init(policy: Policy) {
        self.policy = policy
    }
}

protocol Associable: AnyObject {
    func setAssociated<Value>(_ value: Value?, for key: AssociationKey<Value>)
    func associatedValue<Value>(for key: AssociationKey<Value>) -> Value?
    func associatedValue<Value>(for key: AssociationKey<Value>, default defaultValue: () -> Value) -> Value
}

extension Associable {
    func setAssociated<Value>(_ value: Value?, for key: AssociationKey<Value>) {
        let ptr = Pointer.bridge(obj: key)
        return objc_setAssociatedObject(self, ptr, value, key.policy.rawValue)
    }

    func associatedValue<Value>(for key: AssociationKey<Value>) -> Value? {
        let ptr = Pointer.bridge(obj: key)
        return objc_getAssociatedObject(self, ptr) as? Value
    }

    func associatedValue<Value>(for key: AssociationKey<Value>, default defaultValue: @autoclosure () -> Value) -> Value {
        let ptr = Pointer.bridge(obj: key)

        if let result = objc_getAssociatedObject(self, ptr) as? Value {
            return result
        }

        let result = defaultValue()
        setAssociated(result, for: key)
        return result
    }

    subscript<T>(key: AssociationKey<T>) -> T? {
        get {
            return associatedValue(for: key)
        }
        set {
            setAssociated(newValue, for: key)
        }
    }

    // 其实 subscript 是默认没有 argument label 的，除非显式地添加
    subscript<T>(key: AssociationKey<T>, default defaultValue: @autoclosure () -> T) -> T {
        associatedValue(for: key, default: defaultValue)
    }
}

extension NSObject: Associable {}
