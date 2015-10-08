//
//  XPhone.m
//  XFramework
//
//  Created by XJY on 15-7-28.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XPhone.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"
#import <AddressBook/AddressBook.h>
#import "XFoundation.h"
#import "XTool.h"
#import "XIOSVersion.h"

@implementation XPhone

+ (NSString *)phoneNumberWithFormatE164:(NSString *)phoneNumber {
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    NBPhoneNumber *number = [phoneUtil parseWithPhoneCarrierRegion:phoneNumber error:&anError];
    NSString *finalNumber = @"";
    if (anError == nil){
        finalNumber = [phoneUtil format:number numberFormat:NBEPhoneNumberFormatE164 error:&anError];
    }
    return finalNumber;
}

+ (NSURL *)getTelUrl:(NSString *)phoneNumber {
    NSString *cleanedString =[[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSString *escapedPhoneNumber = [cleanedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", escapedPhoneNumber]];
    return telURL;
}

+ (NSURL *)getSmsUrl:(NSString *)phoneNumber {
    NSString *cleanedString =[[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSString *escapedPhoneNumber = [cleanedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *smsURL = [NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", escapedPhoneNumber]];
    return smsURL;
}

+ (void)callTelephone:(NSString *)phoneNumber atSuper:(UIView *)superView {
    UIWebView *callWebview = [[UIWebView alloc] init] ;
    [superView addSubview:callWebview];
    NSURL *telURL = [self getTelUrl:phoneNumber];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
}

+ (void)callTelephone:(NSString *)phoneNumber {
    NSURL *telURL = [self getTelUrl:phoneNumber];
    [[UIApplication sharedApplication] openURL:telURL];
}

+ (void)sendSms:(NSString *)phoneNumber {
    NSURL *smsURL = [self getSmsUrl:phoneNumber];
    [[UIApplication sharedApplication] openURL:smsURL];
}

+ (void)openEmail:(NSString *)email {
    NSString *emailStr = @"mailto://";
    emailStr = [emailStr stringByAppendingString:email];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailStr]];
}

+ (void)openBrowserWithString:(NSString *)urlStr {
    if ([XTool isStringEmpty:urlStr] == YES) {
        return;
    }
    if ([urlStr rangeOfString:@"http://"].location == NSNotFound) {
        urlStr = [@"http://" stringByAppendingString:urlStr];
    }
    [self openBrowserWithUrl:[NSURL URLWithString:urlStr]];
}

+ (void)openBrowserWithUrl:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

+ (void)getContact:(void (^)(NSArray *contacts))block {
    ABAddressBookRef addressBooks = nil;
    if ([XIOSVersion systemVersion] >= 6.0) {
        addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
        //Get power to access contact
        ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error) {
            //If granted is YES, parse contacts.
            if (granted == YES) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSArray *addressBooksArr = [self parseAddressBook:addressBooks];
                    if (block != nil) {
                        x_dispatch_main_async(^{
                            block(addressBooksArr);
                        });
                    }
                });
            }
        });
    } else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_5_1
        addressBooks = ABAddressBookCreate();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *addressBooksArr = [self parseAddressBook:addressBooks];
            if (block != nil) {
                x_dispatch_main_async(^{
                    block(addressBooksArr);
                });
            }
        });
#endif
    }
}

+ (NSArray *)parseAddressBook:(ABAddressBookRef)addressBooks {
    NSMutableArray *addressBookArr = [[NSMutableArray alloc] init];
    
    //Get all people in contact
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    //Get count of people
    CFIndex peopleCount = ABAddressBookGetPersonCount(addressBooks);
    //Get information of all people
    for (NSInteger i = 0; i < peopleCount; i++) {
        NSMutableDictionary *addressBookDic = [[NSMutableDictionary alloc] init];
        
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);                      //Get somebody
        CFTypeRef   abFirstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);//His/Her first name
        CFTypeRef   abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);  //His/Her last name
        CFStringRef abFullName = ABRecordCopyCompositeName(person);                     //His/Her full name
        
        NSString *  name = (__bridge NSString *)abFirstName;
        NSString *  lastNameString = (__bridge NSString *)abLastName;
        
        if (abFullName != nil) {
            name = (__bridge NSString *)abFullName;
        } else {
            if ([XTool isStringEmpty:lastNameString] == NO) {
                name = [NSString stringWithFormat:@"%@ %@", name, lastNameString];
            }
        }
        if ([XTool isStringEmpty:name] == YES) {
            name = @"";
        }
        [addressBookDic x_setObject:name forKey:@"name"];

        NSInteger recordID = (NSInteger)ABRecordGetRecordID(person);//His or her recordID
        if (recordID == NSNotFound) {
            recordID = -1;
        }
        NSNumber *recordIDNumber = [NSNumber numberWithInteger:recordID];
        if (recordIDNumber == nil) {
            recordIDNumber = [NSNumber numberWithInteger:-1];
        }
        [addressBookDic x_setObject:recordIDNumber forKey:@"recordID"];
        
        ABPropertyID multiProperties[] = {
            kABPersonPhoneProperty,
            kABPersonEmailProperty
        };
        NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
        for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
            ABPropertyID property = multiProperties[j];
            ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
            NSInteger valuesCount = 0;
            if (valuesRef != nil)
                valuesCount = ABMultiValueGetCount(valuesRef);
            
            if (valuesCount == 0) {
                if (valuesRef != nil) {
                    CFRelease(valuesRef);
                }
                continue;
            }
            //Get phone number and email
            for (NSInteger k = 0; k < valuesCount; k++) {
                CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                switch (j) {
                    case 0: {// Phone number
                        NSString *phone = (__bridge NSString*)value;
                        if ([XTool isStringEmpty:phone] == YES) {
                            phone = @"";
                        }
                        
                        NSMutableArray *phoneArray = nil;
                        id unknown = [addressBookDic objectForKey:@"tel"];
                        if (unknown == nil || [unknown isKindOfClass:[NSArray class]] == NO) {
                            phoneArray = [[NSMutableArray alloc] init];
                        } else {
                            phoneArray = [[NSMutableArray alloc] initWithArray:unknown];
                        }
                        [phoneArray x_addObject:phone];
                        [addressBookDic x_setObject:phoneArray forKey:@"tel"];
                        break;
                    }
                    case 1: {// Email
                        NSString *email = (__bridge NSString*)value;
                        if ([XTool isStringEmpty:email] == YES) {
                            email = @"";
                        }

                        NSMutableArray *emailArray = nil;
                        id unknown = [addressBookDic objectForKey:@"email"];
                        if (unknown == nil || [unknown isKindOfClass:[NSArray class]] == NO) {
                            emailArray = [[NSMutableArray alloc] init];
                        } else {
                            emailArray = [[NSMutableArray alloc] initWithArray:unknown];
                        }
                        [emailArray x_addObject:email];
                        [addressBookDic x_setObject:emailArray forKey:@"email"];
                        break;
                    }
                }
                CFRelease(value);
            }
            CFRelease(valuesRef);
        }
        [addressBookArr x_addObject:addressBookDic];
        
        if (abFirstName)    CFRelease(abFirstName);
        if (abLastName)     CFRelease(abLastName);
        if (abFullName)     CFRelease(abFullName);
    }
    if (allPeople) CFRelease(allPeople);
    return addressBookArr;
}

@end
