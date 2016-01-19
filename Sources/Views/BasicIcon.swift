//
//  BasicIcon.swift
//  Ello
//
//  Created by Sean on 4/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class BasicIcon: UIView {

    private var _enabled = false
    private var _selected = false
    private var _highlighted = false

    private let normalIconView: UIView
    private let selectedIconView: UIView
    private let disabledIconView: UIView?

    // MARK: Initializers

    public init(normalIconView: UIView, selectedIconView: UIView, disabledIconView: UIView? = nil) {
        self.normalIconView = normalIconView
        self.selectedIconView = selectedIconView
        self.disabledIconView = disabledIconView

        let frame = CGRect(
            x: 0,
            y: 0,
            width: normalIconView.frame.size.width,
            height: normalIconView.frame.size.height
        )
        super.init(frame: frame)
        addSubview(self.normalIconView)
        addSubview(self.selectedIconView)
        self.selectedIconView.hidden = true

        if let view = disabledIconView {
            addSubview(view)
            view.hidden = true
        }
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private
    func updateIcon(selected selected: Bool, enabled: Bool) {
        if let disabledIconView = disabledIconView {
            normalIconView.hidden = !(enabled && !selected)
            selectedIconView.hidden = !(enabled && selected)
            disabledIconView.hidden = enabled
        }
        else {
            normalIconView.hidden = selected
            selectedIconView.hidden = !selected
        }
    }
}

extension BasicIcon: ImageLabelAnimatable {

    public var enabled: Bool {
        get { return _enabled }
        set {
            _enabled = newValue
            updateIcon(selected: _selected, enabled: newValue)
        }
    }

    public var selected: Bool {
        get { return _selected }
        set {
            _selected = newValue
            updateIcon(selected: newValue, enabled: _enabled)
        }
    }

    public var highlighted: Bool {
        get { return _highlighted }
        set {
            _highlighted = newValue
            if selected { return }
            updateIcon(selected: newValue, enabled: _enabled)
        }
    }

    public var view: UIView { return self }
}
