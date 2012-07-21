//
//  CSDataAccess.h
//  Metra
//
//  Created by Marco Brambilla on 27/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CSDataAccess : NSObject {
    
}

+(NSManagedObjectContext*)managedObjectContext;

+ (NSArray*)LoadObjects:(NSString*)entityName withPredicate:(NSPredicate*)predicate sortBy:(NSString*)sort error:(NSError **)error;    

+ (NSArray*)LoadDistinctValues:(NSString*)propertyName forEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate;

+(id)GetMaxValue:(NSString*)propertyName forEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate;
+(id)GetSumValue:(NSString*)propertyName forEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate;

+ (void) deleteAllObjects: (NSString *) entityDescription;
+(NSManagedObject*)createObjectForEntity:(NSString*)entityName;

+ (NSString *)createUUID;

@end
