//
//  LipScrollView.h
//  Scroll_Test
//
//  Created by Andrew Lippman on 12/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface LipScrollView : NSView

@property (unsafe_unretained) NSString *p;  //  THis is the printer
@property (unsafe_unretained) NSString * number;
@property (unsafe_unretained) NSString * amount;
@property (unsafe_unretained) NSString * payee;
@property (unsafe_unretained) NSString * numText;
@property (unsafe_unretained) NSString * memo1;
@property (unsafe_unretained) NSString * date;


- (void)printWithNoPanel:(id)sender;
- (void)setContent:(NSString *)data;
@end
