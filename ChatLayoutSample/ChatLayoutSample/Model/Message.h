//
//  Message.h
//  ChatLayoutSample
//
//  Created by Stanislav Shpak on 12/14/15.
//  Copyright © 2015 Stanislav Shpak. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    CHMessageTypeInbox,
    CHMessageTypeOutbox,
} CHMessageType;

@interface Message : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) CHMessageType type;

+ (NSArray *)populateMessages:(NSUInteger)count;
+ (Message *)populateSingleMessage;

@end
