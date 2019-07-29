//
//  Code39.m
//  Code39Test
//
//  Created by Lin Patrick on 10/17/15.
//

#import "Code39.h"

@implementation Code39

+ (UIImage *)code39ImageFromString:(NSString *)strSource    // Source string
                             Width:(CGFloat)barcodew        // Barcode Width
                            Height:(CGFloat)barcodeh        // Barcode Height
{
    int intSourceLength = (int)strSource.length;
    CGFloat x = 1; // Left Margin
    CGFloat y = 0; // Top Margin
    // Width = ((WidLength * 3 + NarrowLength * 7) * (intSourceLength + 2)) + (x * 2)
    CGFloat NarrowLength = (barcodew/(intSourceLength + 2)) / 13.0; // Length of narrow bar
    CGFloat WidLength = NarrowLength * 2; // Length of Wide bar
    NSString *strEncode = @"010010100"; // Encoding string for starting and ending mark *
    NSString * AlphaBet = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*"; // Code39 alphabets
    NSString* Code39[] = //Encoding strings for Code39 alphabets
    {
        /* 0 */ @"000110100",
        /* 1 */ @"100100001",
        /* 2 */ @"001100001",
        /* 3 */ @"101100000",
        /* 4 */ @"000110001",
        /* 5 */ @"100110000",
        /* 6 */ @"001110000",
        /* 7 */ @"000100101",
        /* 8 */ @"100100100",
        /* 9 */ @"001100100",
        /* A */ @"100001001",
        /* B */ @"001001001",
        /* C */ @"101001000",
        /* D */ @"000011001",
        /* E */ @"100011000",
        /* F */ @"001011000",
        /* G */ @"000001101",
        /* H */ @"100001100",
        /* I */ @"001001100",
        /* J */ @"000011100",
        /* K */ @"100000011",
        /* L */ @"001000011",
        /* M */ @"101000010",
        /* N */ @"000010011",
        /* O */ @"100010010",
        /* P */ @"001010010",
        /* Q */ @"000000111",
        /* R */ @"100000110",
        /* S */ @"001000110",
        /* T */ @"000010110",
        /* U */ @"110000001",
        /* V */ @"011000001",
        /* W */ @"111000000",
        /* X */ @"010010001",
        /* Y */ @"110010000",
        /* Z */ @"011010000",
        /* - */ @"010000101",
        /* . */ @"110000100",
        /*' '*/ @"011000100",
        /* $ */ @"010101000",
        /* / */ @"010100010",
        /* + */ @"010001010",
        /* % */ @"000101010",
        /* * */ @"010010100"
    };
    
    strSource = [strSource uppercaseString];
    // calculate graphic size
    CGSize size = CGSizeMake(barcodew, barcodeh + (y * 2));
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // fill background color (white)
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, size.width, size.height));
    
    // beging encoding
    for (int i = 0; i < intSourceLength; i++)
    {
        // check for illegal characters
        char c = [strSource characterAtIndex:i];
        long index = [AlphaBet rangeOfString:[NSString stringWithFormat:@"%c",c]].location;
        if ((index == NSNotFound) || (c == '*'))
        {
            NSLog(@"This string contains illegal characters");
            return nil;
        }
        // get and concat encoding string
        strEncode = [NSString stringWithFormat:@"%@0%@",strEncode, Code39[index]];
    }
    // pad with ending *
    strEncode = [NSString stringWithFormat:@"%@0010010100", strEncode];
    
    int intEncodeLength = (int)strEncode.length; // final encoded data length
    CGFloat fBarWidth;
    // Draw Code39 BarCode according the the encoded data
    for (int i = 0; i < intEncodeLength; i++)
    {
        fBarWidth = ([strEncode characterAtIndex:i] == '1' ? WidLength : NarrowLength);
        // drawing with black color
        if (i % 2 == 0) {
            CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
            CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
        }
        // drawing with white color
        else {
            CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
        }
        CGContextFillRect(context, CGRectMake(x, y, fBarWidth, barcodeh));
        x += fBarWidth;
    }
    // get image from context and return
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

@end
