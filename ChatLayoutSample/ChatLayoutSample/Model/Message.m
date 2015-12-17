//
//  Message.m
//  ChatLayoutSample
//
//  Created by Stanislav Shpak on 12/14/15.
//  Copyright © 2015 Stanislav Shpak. All rights reserved.
//

#import "Message.h"

@implementation Message

+ (NSArray *)populateMessages:(NSUInteger)count {
    if (count == 0)
        return @[];
    
    // Generate array of random messages
    NSMutableArray *messages = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        [messages addObject:[self populateSingleMessage]];
    }
    return messages;
}

+ (Message *)populateSingleMessage {
    Message *message = [Message new];
    if (arc4random() % 2 == 1) {
        
        // Generate inbox message
        message.type = CHMessageTypeInbox;
        message.name = @"Leia";
    } else {
        
        // Generate outbox message
        message.type = CHMessageTypeOutbox;
        message.name = @"Han Solo";
    }
    
    NSArray *titles = [self titles];
    message.text = titles[arc4random() % titles.count];
    return message;
}

+ (NSArray *)titles {
    // Titles for random message populating
    return @[@"Lorem",
             @"Ipsum dolor",
             @"Lorem ipsum dolor sit amet",
             @"Consectetur adipiscing elit, sed do eiusmod",
             @"Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
             @"Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur"];
}

@end
