//
//  SceneBuilder.swift
//  BrokerOpenAccountModule
//
//  Created by alexej_ne on 12/04/2019.
//  Copyright © 2019 BCS. All rights reserved.
// 
public final class StackSceneBuilder {
    
    public enum ViewWidth {
        case `default`
        case `self`
        case insetted(CGFloat)
        case full
    }

    private var backgroundColor: UIColor? {
        didSet{
            scene.scrollView.backgroundColor = backgroundColor
            scene.stackView.backgroundColor = backgroundColor
            scene.view.backgroundColor = backgroundColor
            updateSpaceViewBackgroundColor()
        }
    }
    
    private let scene: StackViewController
    private var viewsWidthDefaultInset: CGFloat?
    private var constraints: [NSLayoutConstraint] = []
    
    public init(viewsWidthDefaultInset: CGFloat? = nil, contentMode: StackViewController.ContentMode = .scrollable) {
        self.scene = StackViewController(contentMode: contentMode)
        self.viewsWidthDefaultInset = viewsWidthDefaultInset
        scene.stackView.spacing = 0
    }
    
    private func updateSpaceViewBackgroundColor() {
        for view in scene.stackView.arrangedSubviews {
            guard let view = view as? FixedHeightView else { continue }
            view.backgroundColor = backgroundColor
        }
    }
    
    private func addWidthConstraintIfNeed(to view: UIView, type: ViewWidth)  {
        let inset: CGFloat?
        
        switch type {
        case .default:
            guard let viewsWidthDefaultInset = viewsWidthDefaultInset else { return }
            inset = viewsWidthDefaultInset
        case .full:
            inset = 0
        case .insetted(let inst):
            inset = inst
        case .self:
            inset = nil
        }
        
        guard let widthInset = inset, let superview = view.superview else { return }
        
        let constraint = view.widthAnchor.constraint(equalTo: superview.widthAnchor, constant: -widthInset)
        constraints.append(constraint)
    }
}



public extension StackSceneBuilder {
    
    func build() -> StackViewController {
        NSLayoutConstraint.activate(constraints)
        return scene
    }
    
    func build<Reactor: SceneReactor>(reactor: Reactor, viewDidLoadAction: Reactor.Action? = nil) -> StackViewController {
        let scene = build()
        scene.reactor = reactor
        if let viewDidLoadAction = viewDidLoadAction {
            scene.onViewDidLoad = { [weak reactor] in reactor?.action.onNext(viewDidLoadAction) }
        }
        return scene
    }
    
    func set(stackAlignment: UIStackView.Alignment) {
        self.scene.stackView.alignment = stackAlignment
    }
    
    func set(backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
    }
    
    func set(contentInset: UIEdgeInsets) {
        scene.scrollView.contentInset = contentInset
    }
    
    func add(view: UIView, width: ViewWidth = .default) {
        scene.stackView.addArrangedSubview(view)
        addWidthConstraintIfNeed(to: view, type: width)
    }
    
    func addSpace(_ height: CGFloat) {
        add(view: FixedHeightView(height: height, backgroundColor: backgroundColor))
    }
}