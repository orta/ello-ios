// Playground - noun: a place where people can play

import UIKit
import QuartzCore

var sean:[String:AnyObject] = ["name" : "sean", "id" : 5]
var jim:[String:AnyObject] = ["name" : "jim", "id" : 10]
var people = [sean, jim]


//find(people, "playground") == 1


//UIView *view = [[UIView alloc] initWithFrame:CGRectMake ];  view.backgroundColor = [UIColor blueColor];  view.layer.cornerRadius = 50;    [self.view addSubview:view];    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];  scaleAnimation.duration = 0.2;  scaleAnimation.repeatCount = HUGE_VAL;  scaleAnimation.autoreverses = YES;  scaleAnimation.fromValue = [NSNumber numberWithFloat:1.2];  scaleAnimation.toValue = [NSNumber numberWithFloat:0.8];    [view.layer addAnimation:scaleAnimation forKey:@"scale"];




class PulsingCircle: UIView {

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        self.layer.cornerRadius = rect.width/2
        self.backgroundColor = UIColor.grayColor()
    }
}

let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
container.backgroundColor = UIColor.whiteColor()

let circle = PulsingCircle(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

container.addSubview(circle)