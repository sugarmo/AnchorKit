//
//  ConstantRelatable.swift
//  AnchorPal
//
//  Created by Steven Mok on 2021/2/11.
//

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

public protocol ConstraintConstantRelatable: ConstraintSubjectable {
    static func constraints(_ receiver: Self, relation: ConstraintRelation, to constant: ConstraintConstantValuable) -> [NSLayoutConstraint]
}

extension LayoutDimensionable {
    public static func constraints(_ receiver: Self, relation: ConstraintRelation, to constant: ConstraintConstantValuable) -> [NSLayoutConstraint] {
        let p = position(for: receiver)
        let cv = constant.constraintConstantValue(for: p)
        return [dimension(for: receiver).constraint(relation, toConstant: cv, position: p)]
    }
}

extension LayoutDimension: ConstraintConstantRelatable {}
@available(iOS 10, tvOS 10, macOS 10.12, *)
extension CustomLayoutDimension: ConstraintConstantRelatable {}

extension LayoutInset: ConstraintConstantRelatable {
    public static func constraints(_ receiver: LayoutInset<T>, relation: ConstraintRelation, to constant: ConstraintConstantValuable) -> [NSLayoutConstraint] {
        let p = receiver.attribute.position
        let cv = constant.constraintConstantValue(for: p)
        return [receiver.trailing.constraint(relation, to: receiver.leading, constant: cv, position: p)]
    }
}

extension Array: ConstraintConstantRelatable where Element: ConstraintConstantRelatable {
    public static func constraints(_ receiver: Array<Element>, relation: ConstraintRelation, to constant: ConstraintConstantValuable) -> [NSLayoutConstraint] {
        receiver.flatMap { Element.constraints($0, relation: relation, to: constant) }
    }
}

extension AnchorPair: ConstraintConstantRelatable where F: ConstraintConstantRelatable, S: ConstraintConstantRelatable {
    public static func constraints(_ receiver: AnchorPair<F, S>, relation: ConstraintRelation, to constant: ConstraintConstantValuable) -> [NSLayoutConstraint] {
        F.constraints(receiver.first, relation: relation, to: constant) +
            S.constraints(receiver.second, relation: relation, to: constant)
    }
}

extension ConstraintConstantRelatable {
    func state(_ relation: ConstraintRelation, to constant: ConstraintConstantValuable) -> ConstraintModifier<ConstraintConstantTarget> {
        ConstraintModifier(subjectProvider: self) { (_, c) -> [NSLayoutConstraint] in
            Self.constraints(self, relation: relation, to: c)
        }._constant(constant)
    }

    @discardableResult
    public func lessEqualTo(_ constant: ConstraintConstantValuable) -> ConstraintModifier<ConstraintConstantTarget> {
        state(.lessEqual, to: constant)
    }

    @discardableResult
    public func equalTo(_ constant: ConstraintConstantValuable) -> ConstraintModifier<ConstraintConstantTarget> {
        state(.equal, to: constant)
    }

    @discardableResult
    public func greaterEqualTo(_ constant: ConstraintConstantValuable) -> ConstraintModifier<ConstraintConstantTarget> {
        state(.greaterEqual, to: constant)
    }
}

extension ConstraintConstantRelatable {
    func state(_ relation: ConstraintRelation, to dynamicConstant: @escaping DynamicConstraintConstant.Getter) -> ConstraintModifier<ConstraintConstantTarget> {
        ConstraintModifier(subjectProvider: self) { (_, c) -> [NSLayoutConstraint] in
            Self.constraints(self, relation: relation, to: c)
        }._constant(DynamicConstraintConstant(getter: dynamicConstant))
    }

    @discardableResult
    public func lessEqualTo(_ dynamicConstant: @escaping DynamicConstraintConstant.Getter) -> ConstraintModifier<ConstraintConstantTarget> {
        state(.lessEqual, to: dynamicConstant)
    }

    @discardableResult
    public func equalTo(_ dynamicConstant: @escaping DynamicConstraintConstant.Getter) -> ConstraintModifier<ConstraintConstantTarget> {
        state(.equal, to: dynamicConstant)
    }

    @discardableResult
    public func greaterEqualTo(_ dynamicConstant: @escaping DynamicConstraintConstant.Getter) -> ConstraintModifier<ConstraintConstantTarget> {
        state(.greaterEqual, to: dynamicConstant)
    }
}
