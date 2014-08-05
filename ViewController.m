//
//  ViewController.m
//  PDFEdit
//
//  Created by João Vitor on 04/08/14.
//  Copyright (c) 2014 Avnoconn. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSURL *pathUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/101.pdf",[self pathToPatientPhotoFolder]]];
    
     CGPDFDocumentRef pdf  = CGPDFDocumentCreateWithURL((CFURLRef)pathUrl);
    
    
    
    const size_t numberOfPages = CGPDFDocumentGetNumberOfPages(pdf);
    
    NSMutableData* data = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(data, CGRectZero, nil);
    
    for(size_t page = 1; page <= numberOfPages; page++)
    {
        //	Get the current page and page frame
        CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, page);
        const CGRect pageFrame = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
        
        UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
        
        //	Draw the page (flipped)
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -pageFrame.size.height);
        CGContextDrawPDFPage(ctx, pdfPage);
        CGContextRestoreGState(ctx);
        
        //	Draw a red box
        [[UIColor redColor] set];
        UIRectFill(CGRectMake(20, 20, 100, 100));
        
        

        //Draw image
        UIImage* logo = [UIImage imageNamed:@"logo"];
        CGRect frame = CGRectMake(50, 100, 80, 100);
        [logo drawInRect:frame];
        
        
        [self drawText:@"teste asdas das " inFrame:CGRectMake(200, 200, 80, 200)];
    }
    
    UIGraphicsEndPDFContext();
    
    CGPDFDocumentRelease(pdf);
    pdf = nil;
    

    [self saveDataToPDF:data];

    
    [self showPDFFile];
}

-(void)drawText:(NSString*)textToDraw inFrame:(CGRect)frameRect
{
    
    CFStringRef stringRef = (__bridge CFStringRef)textToDraw;
    // Prepare the text using a Core Text Framesetter
    
    
    CGColorRef color = [UIColor blueColor].CGColor; // Set Color
    
    CTFontRef font = CTFontCreateWithName((CFStringRef) @"Systemfont", 50.0, NULL); // Set Custom Font
    
    CTTextAlignment theAlignment = kCTCenterTextAlignment; // Set custom Aligment
    
    CFIndex theNumberOfSettings = 1;
    CTParagraphStyleSetting theSettings[1] = {
        { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment),
            &theAlignment }
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);

    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (__bridge id)font, (NSString *)kCTFontAttributeName,color,
                                    (NSString *)kCTForegroundColorAttributeName,paragraphStyle,
                                    (NSString *) kCTParagraphStyleAttributeName,nil]; // atributes Dic

    
    
    
    NSAttributedString* stringToDraw = [[NSAttributedString alloc] initWithString:textToDraw attributes:attributesDict];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)stringToDraw);


    
    
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    // Get the frame that will do the rendering.
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Get the graphics context.
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, frameRect.origin.y*2);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextTranslateCTM(currentContext, 0, (-1)*frameRect.origin.y*2);
    
    
    CFRelease(frameRef);
    CFRelease(stringRef);
    CFRelease(framesetter);
}



-(void)showPDFFile
{
    NSString* pdfFileName = [NSString stringWithFormat:@"%@/101.pdf",[self pathToPatientPhotoFolder]];
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    
    NSURL *url = [NSURL fileURLWithPath:pdfFileName];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView setScalesPageToFit:YES];
    [webView loadRequest:request];
    
    
    
    [self.view addSubview:webView];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)saveDataToPDF:(NSData *)pdfDocumentData
{

    NSData *d =pdfDocumentData;
    [d writeToFile:[NSString stringWithFormat:@"%@/101.pdf",[self pathToPatientPhotoFolder]] atomically:YES];

}
@end
