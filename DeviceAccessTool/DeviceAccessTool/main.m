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
            NSString* projectTarget = [arguments stringForKey:@"target"];
            NSString* toDir = [arguments stringForKey:@"to"];
            
            NSLog(@"Will grab the coverage files for %@ from Device: %@ to %@", projectTarget, [device udid], toDir);
            
            if (!toDir || !appId || !projectTarget) {
                NSLog(@"Error: no toDir | no appId | no target");
                return -1;
            }
            
            AFCApplicationDirectory* appDir = [device newAFCApplicationDirectory:appId];
            
            NSArray* files = [appDir recursiveDirectoryContents:@"/Documents"];
            for (NSString* file in files) {
                if([file hasSuffix:@".gcda"])
                {
                    NSRange range = [file rangeOfString:[NSString stringWithFormat:@"%@.build", projectTarget]];
                    if(range.length == 0)
                       continue;
                    
                    NSString* filePath = [toDir stringByAppendingPathComponent:
                                          [file substringFromIndex:range.location]];
                    
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
