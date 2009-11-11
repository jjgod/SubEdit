//
//  SubRipTimeTransformer.m
//  SubEdit
//
//  Created by Jiang Jiang on 11/11/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import "SubRipTimeTransformer.h"
#import "RegexKitLite.h"
#import "SESubtitle.h"

extern NSUInteger TimeFromArray(NSArray *timeArray);

@implementation SubRipTimeTransformer

+ (Class) transformedValueClass
{
    return [NSString class];
}

+ (BOOL) allowsReverseTransformation
{
    return YES;
}

- (id) transformedValue:(id)value
{
    if (value == nil) return nil;
    
    return [SESubtitle stringFromTime: [value unsignedIntValue]];
}

- (id) reverseTransformedValue: (id) value
{
    NSUInteger total;
    NSArray *components;
    
    if (value == nil) return nil;

    components = [(NSString *) value captureComponentsMatchedByRegex: @"(\\d+):(\\d+):(\\d+),(\\d+)"];
    if (! components || [components count] != 5)
        return nil;
    
    total = TimeFromArray([components subarrayWithRange: NSMakeRange(1, 4)]);
    return [NSNumber numberWithUnsignedInteger: total];
}

@end
