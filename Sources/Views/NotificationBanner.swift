//
//  NotificationBanner.swift
//  Ello
//
//  Created by Gordon Fontenot on 5/21/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import CRToast

public struct NotificationBanner {
    public static func displayAlertForPayload(payload: PushPayload) {
        configureDefaults()
        CRToastManager.showNotificationWithMessage(payload.message) { }
    }
}

private extension NotificationBanner {
    static func configureDefaults() {
        CRToastManager.setDefaultOptions(
            [
                kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
                kCRToastNotificationPresentationTypeKey: CRToastPresentationType.Cover.rawValue,

                kCRToastTextColorKey: UIColor.whiteColor(),
                kCRToastBackgroundColorKey: UIColor.blackColor(),

                kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Top.rawValue,

                kCRToastAnimationInTimeIntervalKey: DefaultAnimationDuration,
                kCRToastAnimationOutTimeIntervalKey: DefaultAnimationDuration,

                kCRToastFontKey: UIFont.typewriterFont(12.0),
                kCRToastTextAlignmentKey: NSTextAlignment.Left.rawValue,
            ]
        )

    }
}