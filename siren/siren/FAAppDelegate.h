//
//  IMAppDelegate.h
//  siren
//
//  Created by Pharaoh on 14-3-20.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAAppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;

@property(readonly, strong, nonatomic)
    NSManagedObjectContext *managedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(readonly, strong, nonatomic)
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
