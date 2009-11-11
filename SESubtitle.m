//
//  SESubtitle.m
//  SubEdit
//
//  Created by Jiang Jiang on 11/11/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import "SESubtitle.h"

@implementation SESubtitle

@synthesize startTime=_startTime, endTime=_endTime, text=_text;

+ (NSString *) stringFromTime: (NSUInteger) total
{
    NSUInteger millisecs = total % 1000;
    total /= 1000;
    NSUInteger secs = total % 60;
    total /= 60;
    NSUInteger mins = total % 60;
    NSUInteger hours = total / 60;
    
    return [NSString stringWithFormat: @"%02d:%02d:%02d,%03d", hours, mins, secs, millisecs];    
}

- (id) init
{
    if (self = [super init])
    {
        _startTime = 0;
        _endTime = 0;
        _text = [[NSMutableString alloc] init];
    }

    return self;
}

- (void) dealloc
{
    if (_text)
        [_text release];
    [super dealloc];
}

- (NSString *) description
{
    return [NSString stringWithFormat: @"%d - %d: %@", _startTime, _endTime, _text];
}

- (NSString *) formattedOutput
{
    return [NSString stringWithFormat: @"%@ --> %@\n%@\n\n",
            [SESubtitle stringFromTime: _startTime],
            [SESubtitle stringFromTime: _endTime], _text];
}

// Validate the subtitle by checking:
// 
//    * Has startTime and endTime
//    * startTime < endTime
//    * Has text

- (BOOL) isValid
{
    if (! _startTime || ! _endTime || _startTime >= _endTime || ! _text)
        return NO;
    
    return YES;
}

@end
