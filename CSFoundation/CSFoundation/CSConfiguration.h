//
//  Configuration.h
//  RS2
//
//  Created by Marco Brambilla on 10/06/11.
//  Copyright 2011 Marco Brambilla. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CSConfiguration : NSObject {
    
}

@property (nonatomic,retain) NSMutableDictionary* data;

- (NSString*) configFilePath;
- (id)GetValueForKey:(NSString*)key;
- (void)SetValue:(id)val ForKey:(NSString*)key;

- (void)save;

+ (CSConfiguration *) sharedInstance;

@end
