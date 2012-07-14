//
//  Configuration.m
//  RS2
//
//  Created by Marco Brambilla on 10/06/11.
//  Copyright 2011 Marco Brambilla. All rights reserved.
//

#import "CSConfiguration.h"


@implementation CSConfiguration

static CSConfiguration *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[CSConfiguration alloc] init];        
    }
}

+ (CSConfiguration *) sharedInstance {
    return sharedSingleton;
}

-(id)init {
    if (!(self = [super init]))
        return nil;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[self configFilePath]])
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[self configFilePath]];
        self.data = dict;
    }
    else
    {
        self.data = [NSMutableDictionary dictionary];
        [self save];
    }
        
    
    return self;
}

- (NSString*) configFilePath;
{
    NSString* documentsDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString* configFilePath = [documentsDirPath stringByAppendingPathComponent:@"configuration.data"];

    return configFilePath;
}

- (id)GetValueForKey:(NSString*)key
{
    return [self.data objectForKey:key];
}

- (void)SetValue:(id)val ForKey:(NSString*)key
{
    [self.data setValue:val forKey:key];
}

- (void)save;
{
    [self.data writeToFile:[self configFilePath] atomically:YES];
}

- (void)dealloc
{
    self.data = nil;
}

@synthesize data;

@end
