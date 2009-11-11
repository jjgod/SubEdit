//
//  SubtitleDocument.h
//  SubEdit
//
//  Created by Jiang Jiang on 11/11/09.
//

#import <Cocoa/Cocoa.h>

@interface SubtitleDocument : NSDocument
{
    NSMutableArray *subtitles;
    NSStringEncoding originalEncoding;
}

@property (copy) NSMutableArray *subtitles; 

@end
