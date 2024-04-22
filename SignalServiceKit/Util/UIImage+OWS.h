//
// Copyright 2014 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (normalizeImage)

- (UIImage *)normalizedImage;
- (UIImage *)resizedWithQuality:(CGInterpolationQuality)quality rate:(CGFloat)rate;

- (nullable UIImage *)resizedWithMaxDimensionPoints:(CGFloat)maxDimensionPoints;
- (nullable UIImage *)resizedWithMaxDimensionPixels:(CGFloat)maxDimensionPixels;
- (nullable UIImage *)resizedImageToSize:(CGSize)dstSize;
- (UIImage *)resizedImageToFillPixelSize:(CGSize)boundingSize;

+ (nullable NSData *)validJpegDataFromAvatarData:(NSData *)avatarData;

@end

NS_ASSUME_NONNULL_END
