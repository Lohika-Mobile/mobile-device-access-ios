//
//  main.m
//  DeviceAccessTool
//
//  Created by Alexander Trishyn on 7/21/15.
//  Copyright (c) 2015 Lohika. The MIT License (MIT).
//

#import <Foundation/Foundation.h>
#import "DeviceAccessManager.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        NSUserDefaults* arguments = [NSUserDefaults standardUserDefaults];
        NSString* option = [arguments stringForKey:@"o"];
        if(!option)
        {
            NSLog(@"Error: Arguments not specified!");
            return -1;
        }

        DeviceAccessManager* manager = [DeviceAccessManager new];
        while(!manager.devices.count && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                                             beforeDate:[NSDate distantFuture]])
        {
        }
        
        AMDevice* device = manager.devices[0];
        if([option isEqualToString:@"udid"])
        {
            NSLog(@"%@", [device udid]);
        } else if ([option isEqualToString:@"coverage"])
        {
            NSString* appId = [arguments stringForKey:@"app"];
            NSString* toDir = [arguments stringForKey:@"to"];
            
            NSLog(@"Will grab the coverage files from Device: %@ to %@", [device udid], toDir);
            
            if (!toDir || !appId) {
                NSLog(@"Error: no toDir | no appId");
                return -1;
            }
            
            AFCApplicationDirectory* appDir = [device newAFCApplicationDirectory:appId];
            
            NSString* prefixToRemove = @"/Documents/Build/Intermediates";
            NSArray* files = [appDir recursiveDirectoryContents:@"/Documents"];
            for (NSString* file in files) {
                if([file hasSuffix:@".gcda"])
                {
                    NSString* filePath = [toDir stringByAppendingPathComponent:
                                          [file substringFromIndex:[prefixToRemove length]]];
                    
                    // create destination folder if it doesn't exist
                    NSString* destinationDirectoryPath = [filePath stringByDeletingLastPathComponent];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationDirectoryPath])
                        [[NSFileManager defaultManager] createDirectoryAtPath:destinationDirectoryPath
                                                  withIntermediateDirectories:YES attributes:nil error:nil];
                    
                    [appDir copyRemoteFile:file toLocalFile:filePath];
                }
            }
        }
    }
    return 0;
}
