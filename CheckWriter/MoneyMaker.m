//
//  MoneyMaker.m
//  test_C
//
//  Created by lip on 1/25/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

#import "MoneyMaker.h"
#import "money.h"

#include <stdio.h>
#include <strings.h>
#include <stdlib.h>



@implementation MoneyMaker
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        NSLog (@"Moneymaker");
    }
    
    return self;
}

-(NSString *)makeMoney:(NSString *)m {
    char *dollarText = money((char *)[m cStringUsingEncoding:NSUTF8StringEncoding]);
    return [NSString stringWithCString:dollarText  encoding:NSUTF8StringEncoding];
}

@end
