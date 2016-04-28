//
//  DrawerPopControl.swift
//  Ello
//
//  Created by Colin Gray on 2/15/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

public class DrawerPopControl: UIControl {
    var presentingController: UIViewController?

    public init() {
        super.init(frame: .zero)
        addTarget(self, action: #selector(DrawerPopControl.pop), forControlEvents: .TouchDown)
    }

    func pop() {
        presentingController?.dismissViewControllerAnimated(true, completion: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
