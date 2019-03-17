//
//  NumberTransformer.h
//  hello
//
//  Created by lip on 5/30/13.
//  Copyright (c) 2013 Andrew Lippman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NumberTransformer : NSValueTransformer
+ (Class) transformedValueClass;
- (id)transformedValue:(id)value;
- (id)reverseTransformedValue:(id)value; // Not sure when this is used.

@end
