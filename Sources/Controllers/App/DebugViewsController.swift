//
//  DebugViewsController.swift
//  Ello
//
//  Created by Colin Gray on 10/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

#if DEBUG

class DebugViewsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let relationships: [RelationshipPriority] = [
            .None,
            .Following,
            .Starred,
            .Mute,
        ]
        let controls: [RelationshipControl] = relationships.map { priority in
            let control = RelationshipControl()
            control.translatesAutoresizingMaskIntoConstraints = false
            control.relationshipPriority = priority
            self.view.addSubview(control)
            self.view.backgroundColor = .whiteColor()

            return control
        }
        var prevControl: RelationshipControl? = nil

        if #available(iOS 9.0, *) {
            for control in controls {
                control.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor, constant: 0).active = true

                if let prevControl = prevControl {
                    control.topAnchor.constraintEqualToAnchor(prevControl.bottomAnchor, constant: 8).active = true
                }
                else {
                    control.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor, constant: 0).active = true
                }

                prevControl = control
            }
        } else {
            // Fallback on earlier versions
        }
    }

}

#endif
