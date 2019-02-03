//
//  LipScrollView.h
//  Scroll_Test
//
//  Created by Andrew Lippman on 12/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface LipScrollView : NSView

@property (unsafe_unretained) NSString *p;


- (void)printWithNoPanel:(id)sender;
- (void)setContent:(NSString *)data;
@end
