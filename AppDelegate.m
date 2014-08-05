//
//  AppDelegate.m
//  PDFEdit
//
//  Created by João Vitor on 04/08/14.
//  Copyright (c) 2014 Avnoconn. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self pdf1];
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



- (NSString *)pathToPatientPhotoFolder {
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *patientPhotoFolder = [documentsDirectory stringByAppendingPathComponent:@"pdfFolder"];
    
    // Create the folder if necessary
    BOOL isDir = NO;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:patientPhotoFolder
                           isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"pdfFolder"] withIntermediateDirectories:NO attributes:nil error:nil];
        
    }
    
    
    return patientPhotoFolder;
}

-(void)pdf1{
    
    NSString *resourceDocPath = [[NSString alloc] initWithString:[[[[NSBundle mainBundle]  resourcePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Documents"]];
    
    
    
    
    NSString *targetPath = [resourceDocPath stringByAppendingPathComponent:@"101"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
        
        
        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"101"
                                                             ofType:@"pdf"];
        
        
        NSString *filePath =[self pathToPatientPhotoFolder];
        
        NSData *dbFile = [[NSData alloc] initWithContentsOfFile:sqLiteDb];
        
        BOOL done = [dbFile writeToFile:[NSString stringWithFormat:@"%@/101.pdf",filePath] options:NSDataWritingAtomic error:nil];
        
        
    }
}

@end
