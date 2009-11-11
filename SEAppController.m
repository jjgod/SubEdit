//
//  SEAppController.m
//  SubEdit
//
//  Created by Jiang Jiang on 11/11/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import "SEAppController.h"
#import "SubRipTimeTransformer.h"

@implementation SEAppController

+ (void) initialize
{
    SubRipTimeTransformer *transformer;

    // create an autoreleased instance of our value transformer
    transformer = [[[SubRipTimeTransformer alloc] init] autorelease];
    
    // register it with the name that we refer to it with
    [NSValueTransformer setValueTransformer: transformer
                                    forName: @"SubRipTimeTransformer"];
}

- (BOOL) applicationShouldOpenUntitledFile: (NSApplication *) sender
{
    return NO;
}

@end
