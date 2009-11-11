//
//  SESubtitle.h
//  SubEdit
//
//  Created by Jiang Jiang on 11/11/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SESubtitle : NSObject {
    NSUInteger       _startTime;
    NSUInteger       _endTime;
    NSMutableString *_text;
}

@property (assign) NSUInteger startTime, endTime;
@property (copy) NSMutableString *text;

- (BOOL) isValid;
- (NSString *) formattedOutput;
+ (NSString *) stringFromTime: (NSUInteger) total;

@end
