// Playground - noun: a place where people can play

import Foundation

extension NSDate {

    func distanceOfTimeInWords(date:NSDate) -> String {

        let SECONDS_PER_MINUTE = 60.0
        let SECONDS_PER_HOUR   = 3600.0
        let SECONDS_PER_DAY    = 86400.0
        let SECONDS_PER_MONTH  = 2592000.0
        let SECONDS_PER_YEAR   = 31536000.0


        let Ago      = NSLocalizedString("", comment:"Denotes past dates")
        let FromNow  = NSLocalizedString("", comment:"Denotes future dates")
        let LessThan = NSLocalizedString("<", comment:"Indicates a less-than number")
        let About    = NSLocalizedString("~", comment:"Indicates an approximate number")
        let Over     = NSLocalizedString("+", comment:"Indicates an exceeding number")
        let Almost   = NSLocalizedString("<", comment:"Indicates an approaching number")
        let Seconds  = NSLocalizedString("s", comment:"More than one second in time")
        let Minute   = NSLocalizedString("m", comment:"One minute in time")
        let Minutes  = NSLocalizedString("m", comment:"More than one minute in time")
        let Hour     = NSLocalizedString("h", comment:"One hour in time")
        let Hours    = NSLocalizedString("h", comment:"More than one hour in time")
        let Day      = NSLocalizedString("d", comment:"One day in time")
        let Days     = NSLocalizedString("d", comment:"More than one day in time")
        let Month    = NSLocalizedString("m", comment:"One month in time")
        let Months   = NSLocalizedString("m", comment:"More than one month in time")
        let Year     = NSLocalizedString("y", comment:"One year in time")
        let Years    = NSLocalizedString("y", comment:"More than one year in time")

        let sinceInterval:NSTimeInterval = self.timeIntervalSinceDate(date)
        let direction = sinceInterval <= 0.0 ? Ago : FromNow
        let since:Double = abs(sinceInterval)

        let seconds   = Int(since)
        let minutes   = Int(since / SECONDS_PER_MINUTE)
        let hours     = Int(since / SECONDS_PER_HOUR)
        let days      = Int(since / SECONDS_PER_DAY)
        let months    = Int(since / SECONDS_PER_MONTH)
        let years     = Int(since / SECONDS_PER_YEAR)
        let offset    = Int(floor(Double(years) / 4.0) * 1440.0)
        let remainder = (minutes - offset) % 525600

        var number = 0
        var measure = ""
        var modifier = ""


        switch (minutes) {
        case 0 ... 1:
            measure = Seconds
            switch (seconds) {
            case 0 ... 4:
                number = 5
                modifier = LessThan
            case 5 ... 9:
                number = 10
                modifier = LessThan
            case 10 ... 19:
                number = 20
                modifier = LessThan
            case 20 ... 39:
                number = 30
                modifier = About
            case 40 ... 59:
                number = 1
                measure = Minute
                modifier = LessThan
            default:
                number = 1
                measure = Minute
                modifier = About
            }
        case 2 ... 44:
            number = minutes
            measure = Minutes
        case 45 ... 89:
            number = 1
            measure = Hour
            modifier = About
        case 90 ... 1439:
            number = hours
            measure = Hours
            modifier = About
        case 1440 ... 2529:
            number = 1
            measure = Day
        case 2530 ... 43199:
            number = days
            measure = Days
        case 43200 ... 86399:
            number = 1
            measure = Month
            modifier = About
        case 86400 ... 525599:
            number = months
            measure = Months
        default:
            number = years
            measure = number == 1 ? Year : Years
            if remainder < 131400 {
                modifier = About
            }
            else if remainder < 394200 {
                modifier = Over
            }
            else {
                ++number
                measure = Years
                modifier = Almost
            }
        }
        if countElements(modifier) > 0 {
            modifier += ""
        }

        return "\(modifier)\(number)\(measure)\(direction)"
    }
    
}





let now = NSDate()
let then = NSDate(timeIntervalSinceNow: -99999999)

let words = then.distanceOfTimeInWords(now)