//
//  LipScrollView.m
//  Scroll_Test
//
//  Created by Andrew Lippman on 12/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*
 *  Old code to print.  Added Printer selection from Prefs...
 *
 *
 */

#import "LipScrollView.h"

@implementation LipScrollView

@synthesize p;


NSString * addressee;



- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSFont *scriptFont = [NSFont fontWithName:@"Helvetica" size:11];
    NSFont *romanFont = [NSFont fontWithName:@"Helvetica" size:11];
    
    NSPoint numberStart = NSMakePoint(7*72,9.75*72);
    NSPoint amountStart = NSMakePoint(7*72,9.25*72);
    NSPoint payeeStart = NSMakePoint(1*72, 9.25*72 );
    NSPoint numTextStart = NSMakePoint(1*72,8.875*72);
    NSPoint memo1Start = NSMakePoint(1*72,5.5*72);
    
    
//    NSString *helloWorldString = [NSString stringWithString:@"Date goes here"];
    NSString *number = [NSString stringWithString:@"1006"];
    NSString *amount = [NSString stringWithString:@"$42.50"];
    NSString *payee = [NSString stringWithString:@"Andrew Anybody"];
    NSString *numText = [NSString stringWithString:@"Fourty-Two Dollars and 00/100"];
    NSString *memo1 = [NSString stringWithString:@"Full payment on account"];
    NSString *memo2 = [NSString stringWithString:@"Political"];
    
    [number drawAtPoint:NSPointFromCGPoint(CGPointMake(7*72, 9.75*72)) withAttributes:[NSDictionary dictionaryWithObject:scriptFont forKey:NSFontAttributeName]];
    [amount drawAtPoint:NSPointFromCGPoint(CGPointMake(7*72, 9.250*72)) withAttributes:[NSDictionary dictionaryWithObject:romanFont forKey:NSFontAttributeName]];
    [payee drawAtPoint:NSPointFromCGPoint(CGPointMake(1*72, 9.250*72)) withAttributes:[NSDictionary dictionaryWithObject:romanFont forKey:NSFontAttributeName]];
    [numText drawAtPoint:NSPointFromCGPoint(CGPointMake(1*72, 8.875*72)) withAttributes:[NSDictionary dictionaryWithObject:romanFont forKey:NSFontAttributeName]];
    [memo1 drawAtPoint:NSPointFromCGPoint(CGPointMake(1*72, 7.875*72)) withAttributes:[NSDictionary dictionaryWithObject:romanFont forKey:NSFontAttributeName]];
    [memo2 drawAtPoint:NSPointFromCGPoint(CGPointMake(1*72, 5.5*72)) withAttributes:[NSDictionary dictionaryWithObject:romanFont forKey:NSFontAttributeName]];
    
    NSBezierPath* thePath = [NSBezierPath bezierPath];
    [thePath moveToPoint:NSMakePoint(0,0)];
    [thePath lineToPoint:NSMakePoint(8.*72,0)];
    [thePath lineToPoint:NSMakePoint(8.*72,10.5*72)];
    [thePath lineToPoint:NSMakePoint(0,10.5*72)];
    [thePath lineToPoint:NSMakePoint(0,0)];
    [thePath stroke];
}

- (void)printWithNoPanel:(id)sender {
    
    NSSize paperSize;
    paperSize.width=8.5*72.0;
    paperSize.height= 11*72.0;
    
    NSPrintOperation *op;
    NSPrintInfo *printSpecs = [[NSPrintInfo alloc] init ];
    NSPrinter *chosenPrinter = [NSPrinter printerWithName:@"Lip_Upstairs"];
    
    [printSpecs setTopMargin:0.0];
    [printSpecs setBottomMargin:0];
    [printSpecs setRightMargin:0];
    [printSpecs setLeftMargin:0];
    [printSpecs setPaperSize:paperSize];
    [printSpecs setPrinter:chosenPrinter];
    op = [NSPrintOperation printOperationWithView:self printInfo:printSpecs];
    [op setShowsPrintPanel:YES];  // Use NO normally, YES for debugging. 
    [op runOperation];
}

- (void)setContent:(NSString *)data {
    NSLog(@"sent data is %@",data );
    addressee = [NSString stringWithString:data];
}

@end
