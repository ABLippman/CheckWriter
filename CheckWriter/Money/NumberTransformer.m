//
//  NumberTransformer.m
//  hello
//
//  Created by lip on 5/30/13.
//  Copyright (c) 2013 Andrew Lippman. All rights reserved.
//


/*  Transforms dollars typed in a money into the text representation
 *  Dont know when the reverse is used.
 *  Need check for null string, since money fails on that...
 *  Try changing "money" to "numOnly" and watch that work also
 */

#import "NumberTransformer.h"

@implementation NumberTransformer
char *money (char *m );
char *numOnly(char *s);


+ (Class) transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}


- (id)transformedValue:(id)value
{
    NSLog(@"Entered the transformer");
    if ([value length]==0) return @"No Dollars";
    char * numValue = money((char *)[value cStringUsingEncoding:NSUTF8StringEncoding]);
    return [NSString stringWithCString:numValue encoding:NSUTF8StringEncoding];
}

- (id)reverseTransformedValue:(id)value // Not sure when this is used.
{
    return [value lowercaseString];
}


@end
