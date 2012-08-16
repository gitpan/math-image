#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
use strict;
use warnings;
use ExactImage;

use Smart::Comments;


# my $image = ExactImage::newImage();
my $image = ExactImage::newImageWithTypeAndSize(1,1,40,20);
{ my $class = ref $image;
  ### $class
}

ExactImage::imageResize($image,40,20);

print "Width: ", ExactImage::imageWidth($image), "\n";
print "Height: ", ExactImage::imageHeight($image), "\n";
print "Xres: ", ExactImage::imageXres($image), "\n";
print "Yres: ", ExactImage::imageYres($image), "\n";
print "Channels: ", ExactImage::imageChannels ($image), "\n";
print "Channel depth: ", ExactImage::imageChannelDepth ($image). "\n";

ExactImage::setForegroundColor(0,0,0,1.0);
ExactImage::setBackgroundColor(1.0,1.0,1.0,1.0);
ExactImage::imageDrawRectangle($image, 0,0, 39,19);

ExactImage::setForegroundColor(1.0,1.0,1.0,1.0);
ExactImage::setBackgroundColor(0,0,0,1.0);
ExactImage::imageDrawLine($image, 2,2, 10,10);

{ my @get = ExactImage::get($image, 0,0);
  ### @get
}

{ my $str = ExactImage::encodeImage ($image, "jpeg", 80, "");
  ### $str
}
{ my $str = ExactImage::encodeImage ($image, "xpm");
  ### $str
}

if (! ExactImage::encodeImageFile ($image, "/tmp/x.xpm", 80, "")) {
  print "error writing ...\n";
}
system ("ls -l /tmp/x.xpm");
#
#
# # setable as well
#
# ExactImage::imageSetXres ($image, 144);
# ExactImage::imageSetYres ($image, 144);
#
# print "Xres: " . ExactImage::imageXres ($image) . "\n";
# print "Yres: " . ExactImage::imageYres ($image) . "\n";
#
# # image data manipulation
# ExactImage::imageRotate ($image, 90);
# ExactImage::imageScale ($image, 4);
# ExactImage::imageBoxScale ($image, .5);
#
# $image_bits = ExactImage::encodeImage ($image, "jpeg", 80, "");
# print "size: " . length($image_bits) . "\n";
#
# if (length($image_bits) > 0)
# {
#         print "image encoded all fine.\n";
# } else {
#         print "something went wrong encoding the image into RAM\n";
#         exit;
# }
#
# # write the file to disc using Perl
# open (IMG, ">perl.jpg");
# print IMG $image_bits;
# close IMG;
#
# # complex all-in-one function
# if (ExactImage::decodeImageFile ($image, "testsuite/tif/4.2.04.tif"))
#   {
#     my $image_copy = ExactImage::copyImage ($image);
#
#     ExactImage::imageOptimize2BW ($image, 0, 0, 170, 3, 2.1);
#     ExactImage::encodeImageFile ($image, "optimize.tif", 0, "");
#
#     my $is_empty = ExactImage::imageIsEmpty ($image, 0.02, 16);
#     if ($is_empty) {
#       print "Image is empty\n";
#     } else {
#       print "Image is not empty, too many pixels ...\n";
#     }
#
#     # the image is bw, now - but we still have a copy
#     ExactImage::encodeImageFile ($image_copy, "copy.tif", 0, "");
#     # and do not forget the free the copy, otherwise it is leaked
#     ExactImage::deleteImage ($image_copy);
#   }
# else
#   {
#     printf "Error loading testsuite/deskew/01.tif\n";
#   }
#
# if (ExactImage::decodeImageFile ($image, "testsuite/empty-page/empty.tif"))
#   {
#     my $is_empty = ExactImage::imageIsEmpty ($image, 0.02, 16);
#     if ($is_empty) {
#       print "Image is empty\n";
#     } else {
#       print "Image is not empty, too many pixels ...\n";
#     }
#   }
# else
#   {
#     printf "Error loading testsuite/empty-page/empty.tif\n";
#   }
#
# # barcode decoding
#
# while (<testsuite/barcodes/Scan-001-4.tif>)
#   {
#     printf "looking for barcodes in $_\n";
#
#     if (ExactImage::decodeImageFile ($image, "$_"))
#       {
# 	my $barcodes =
#           ExactImage::imageDecodeBarcodes ($image,
# 	  				   "code39|CODE128|CODE25|EAN13|EAN8|UPCA|UPCE",
# 					   3, # min length
# 					   10); # max length
#           for (my $i;$i< scalar(@$barcodes);$i+=2) {
#             print "@$barcodes[$i] @$barcodes[$i+1]\n";
#           }
#       }
#     else
#       {
# 	printf "Error loading $_\n";
#       }
#   }
#
# # we do not want to leak memory, always delete the image
# # when you are done with it!
# ExactImage::deleteImage ($image);


