//
//  CSDataAccess.m
//  Metra
//
//  Created by Marco Brambilla on 27/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CSDataAccess.h"

/*
@interface NSSet(PredicateSupport)
- (NSSet *) filterUsingPredicate:(NSPredicate *)filter;
@end

@implementation NSSet(PredicateSupport)
- (NSSet *) filterUsingPredicate:(NSPredicate *)filter{
    
	// create a worst case set
	NSMutableSet *filteredSet = [NSMutableSet setWithCapacity:
                                 [self count]];
	id obj;
	NSEnumerator *iter = [self objectEnumerator];
	while ((obj = [iter nextObject])){
		// Check if the object matches the predicate - if it does
        // put it in the filtered set
		if ([filter evaluateWithObject:obj]){
			[filteredSet addObject:obj];
		}
	}
	// Return an immutable copy
	return [[filteredSet copy] autorelease];
}
@end
*/

@implementation CSDataAccess

+(NSManagedObjectContext*)managedObjectContext;
{
    return [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectContext)];
//    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
}

+ (NSArray*)LoadObjects:(NSString*)entityName withPredicate:(NSPredicate*)predicate sortBy:(NSString*)sort error:(NSError **)error;    
{
    NSManagedObjectContext *moc = [CSDataAccess managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                                entityForName:entityName inManagedObjectContext:moc];
    // carica dati famiglia
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    
    if (predicate != nil)
    {
        [request setPredicate:predicate];
    }
    
    if (sort != nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:sort ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    
    NSArray *array = [moc executeFetchRequest:request error:error];  
    
    return array;
}

+ (NSArray*)LoadDistinctValues:(NSString*)propertyName forEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate;
{
    NSMutableArray* results = [NSMutableArray array];
    NSError* error;
    NSManagedObjectContext *moc = [CSDataAccess managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityName inManagedObjectContext:moc];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];    
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObject:propertyName]];
    
    if (predicate != nil)
    {
        [request setPredicate:predicate];
    }
        
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:propertyName ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSArray *array = [moc executeFetchRequest:request error:&error];  

    if (array == nil)
    {
        NSLog(@"ERROR: %@", [error localizedDescription]);
    }

    for (int i = 0; i < [array count]; i++) {
        [results addObject:
            [(NSDictionary*)[array objectAtIndex:i] valueForKey:propertyName]
        ];
    }
    
    return results;
}

+(id)GetMaxValue:(NSString*)propertyName forEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate;
{
    NSManagedObjectContext *moc = [CSDataAccess managedObjectContext];

    // setup request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];

    [request setEntity:entity];
                        
    if (predicate != nil)
    {
        [request setPredicate:predicate];
    }
    
    // need to use dictionary to access values
    [request setResultType:NSDictionaryResultType];

    // build expression (must do this for each value you want to retrieve)
    NSExpression *attributeToFetch = [NSExpression expressionForKeyPath:propertyName];

    NSExpression *functionToPerformOnAttribute = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:attributeToFetch]];

    NSExpressionDescription *propertyToFetch = [[NSExpressionDescription alloc] init];
    [propertyToFetch setName:@"max"]; // name used to access value in dictionary
    [propertyToFetch setExpression:functionToPerformOnAttribute];
   
    NSAttributeDescription* attributeDescription = [[entity attributesByName] valueForKey: propertyName];

    [propertyToFetch setExpressionResultType:[attributeDescription attributeType]];
   
    // modify request to fetch only the attribute
    [request setPropertiesToFetch:[NSArray arrayWithObject:propertyToFetch]];

    // execute fetch
    NSArray *results = [moc executeFetchRequest:request error:nil];

    // get value
    if ([results count] > 0) {
       return [[results objectAtIndex:0] valueForKey:@"max"];
    }
    else {
       return nil;
    }
}

+(id)GetSumValue:(NSString*)propertyName forEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate;
{
    NSManagedObjectContext *moc = [CSDataAccess managedObjectContext];
    
    // setup request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    
    [request setEntity:entity];
    
    if (predicate != nil)
    {
        [request setPredicate:predicate];
    }
    
    // need to use dictionary to access values
    [request setResultType:NSDictionaryResultType];
    
    // build expression (must do this for each value you want to retrieve)
    NSExpression *attributeToFetch = [NSExpression expressionForKeyPath:propertyName];
    
    NSExpression *functionToPerformOnAttribute = [NSExpression expressionForFunction:@"sum:" arguments:[NSArray arrayWithObject:attributeToFetch]];
    
    NSExpressionDescription *propertyToFetch = [[NSExpressionDescription alloc] init];
    [propertyToFetch setName:@"sum"]; // name used to access value in dictionary
    [propertyToFetch setExpression:functionToPerformOnAttribute];
    
    NSAttributeDescription* attributeDescription = [[entity attributesByName] valueForKey: propertyName];
    
    [propertyToFetch setExpressionResultType:[attributeDescription attributeType]];
    
    // modify request to fetch only the attribute
    [request setPropertiesToFetch:[NSArray arrayWithObject:propertyToFetch]];
    
    // execute fetch
    NSArray *results = [moc executeFetchRequest:request error:nil];
    
    // get value
    if ([results count] > 0) {
        return [[results objectAtIndex:0] valueForKey:@"sum"];
    }
    else {
        return nil;
    }
}


+ (void) deleteAllObjects: (NSString *) entityDescription  {
    
    NSManagedObjectContext *moc = [CSDataAccess managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [moc executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        [moc deleteObject:managedObject];
    }
    if (![moc save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}

+(NSManagedObject*)createObjectForEntity:(NSString*)entityName {
    
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[CSDataAccess managedObjectContext]];
}

/*
+ (NSString *)createUUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = [(NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject) autorelease];
    
    // If needed, here is how to get a representation in bytes, returned as a structure
    // typedef struct {
    //   UInt8 byte0;
    //   UInt8 byte1;
    //   ...
    //   UInt8 byte15;
    // } CFUUIDBytes;
    //CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidObject);
    
    CFRelease(uuidObject);
    
    return uuidStr;
}*/

@end
