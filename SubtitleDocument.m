//
//  SubtitleDocument.m
//  SubEdit
//
//  Created by Jiang Jiang on 11/11/09.
//

#import "SubtitleDocument.h"
#import "chardetect.h"
#import "RegexKitLite.h"
#import "SESubtitle.h"

extern NSUInteger TimeFromArray(NSArray *timeArray)
{
    // Hour
    NSUInteger time = [[timeArray objectAtIndex: 0] intValue];
    
    time *= 60;
    // Minutes
    time += [[timeArray objectAtIndex: 1] intValue];
    
    time *= 60;
    // Seconds
    time += [[timeArray objectAtIndex: 2] intValue];
    
    time *= 1000;
    // Milliseconds
    time += [[timeArray objectAtIndex: 3] intValue];
    
    return time;
}

@interface NSData (DetectEncoding)
- (NSStringEncoding) detectedEncoding;
@end

@implementation NSData (DetectEncoding)

#define BUFSIZE 4096

- (NSStringEncoding) detectedEncoding
{
    chardet_t chardetContext;
    char      charset[CHARDET_MAX_ENCODING_NAME];
    const char *bytes;
    int       ret, len, total = [self length];

    CFStringEncoding cfenc;
    CFStringRef      charsetStr;
    
    chardet_create(&chardetContext);
    
    chardet_reset(chardetContext);
    bytes = [self bytes];
    
    do
    {
        len = BUFSIZE > total ? total : BUFSIZE;
        ret = chardet_handle_data(chardetContext, bytes, len);
        bytes += len;
        total -= len;
    } while (ret == CHARDET_RESULT_OK && total != 0);

    chardet_data_end(chardetContext);
    
    ret = chardet_get_charset(chardetContext, charset, CHARDET_MAX_ENCODING_NAME);
    if (ret != CHARDET_RESULT_OK)
        return NSUTF8StringEncoding;
    
    // NSLog(@"charset: %s\n", charset);
    charsetStr = CFStringCreateWithCString(NULL, charset, kCFStringEncodingUTF8);
    cfenc = CFStringConvertIANACharSetNameToEncoding(charsetStr);
    CFRelease(charsetStr);
    
    chardet_destroy(chardetContext);
    
    return CFStringConvertEncodingToNSStringEncoding(cfenc);    
}

@end


@implementation SubtitleDocument

@synthesize subtitles;

- (id)init
{
    self = [super init];
    if (self) {
        subtitles = [[NSMutableArray alloc] initWithCapacity: 1024];
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}

- (void) dealloc
{
    [subtitles release];
    [super dealloc];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"SubtitleDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableData *data = [NSMutableData dataWithCapacity: 4096];
    NSUInteger i = 0;
    
    for (SESubtitle *subtitle in subtitles)
    {
        i++;
        [data appendData: [[NSString stringWithFormat: @"%d\n", i] dataUsingEncoding: originalEncoding]];
        [data appendData: [[subtitle formattedOutput] dataUsingEncoding: originalEncoding]];
    }

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}

	return data;
}

- (BOOL) loadSubRipFromString: (NSString *) contents
{
    NSUInteger length = [contents length];
    NSUInteger start, end;
    NSRange range, lineRange;
    NSString *line;
    NSCharacterSet *newlineCharset = [NSCharacterSet newlineCharacterSet];
    SESubtitle *subtitle = nil;
    NSArray *components;

    for (range = NSMakeRange(0, 0); end < length; range.location = end)
    {
        [contents getLineStart: &start
                           end: &end
                   contentsEnd: NULL
                      forRange: range];

        lineRange = NSMakeRange(start, end - start);
        line = [[contents substringWithRange: lineRange] stringByTrimmingCharactersInSet: newlineCharset];

        if (! [line length])
            continue;
        
        if ([line isMatchedByRegex: @"^\\d+$"])
        {
            if (subtitle)
            {
                if ([subtitle isValid])
                    [subtitles addObject: subtitle];

                [subtitle release];
                subtitle = nil;
            }

            subtitle = [[SESubtitle alloc] init];
        }

        else if (subtitle)
        {
            components = [line captureComponentsMatchedByRegex: @"(\\d+):(\\d+):(\\d+),(\\d+) --> (\\d+):(\\d+):(\\d+),(\\d+)"];
            if (components && [components count] == 9)
            {
                subtitle.startTime = TimeFromArray([components subarrayWithRange: NSMakeRange(1, 4)]);
                subtitle.endTime = TimeFromArray([components subarrayWithRange: NSMakeRange(5, 4)]);
            } else
            {
                if ([subtitle.text length])
                    [subtitle.text appendString: @"\n"];
                [subtitle.text appendString: line];
            }
        }
    }
    
    if (subtitle && [subtitle isValid])
    {
        [subtitles addObject: subtitle];
        [subtitle release];
        subtitle = nil;
    }

    return YES;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    originalEncoding = [data detectedEncoding];
    NSString *contents = [[NSString alloc] initWithData: data encoding: originalEncoding];
    
    if (! contents)
        return NO;
    
    if ([self loadSubRipFromString: contents] == NO)
        return NO;

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

@end
