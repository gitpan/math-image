#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.006;
use strict;
use warnings;
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

BEGIN {
  eval 'use Tk; 1'
    or plan skip_all => "due to Tk not available -- $@";
}
plan tests => 1926;

require App::MathImage::Image::Base::Tk::Canvas;
diag "Tk version ", Tk->VERSION;
diag "Image::Base version ", Image::Base->VERSION;

sub my_bounding_box {
  my ($image, $x1,$y1, $x2,$y2, $black, $white) = @_;
  my ($width, $height) = $image->get('-width','-height');

  my @bad;
  foreach my $y ($y1-1, $y2+1) {
    next if $y < 0 || $y >= $height;
    foreach my $x ($x1-1 .. $x2-1) {
      my $got = $image->xy($x,$y);
      if ($got ne $black) {
        push @bad, "$x,$y=$got";
      }
    }
  }
  foreach my $x ($x1-1, $x2+1) {
    next if $x < 0 || $x >= $width;
    foreach my $y ($y1 .. $y2) {
      my $got = $image->xy($x,$y);
      if ($got ne $black) {
        push @bad, "$x,$y=$got";
      }
    }
  }

  my $found_set;
 Y_SET: foreach my $y ($y1, $y2) {
    next if $y < 0 || $y >= $height;
    foreach my $x ($x1 .. $x2) {
      my $got = $image->xy($x,$y);
      if ($got ne $black) {
        $found_set = 1;
        last Y_SET;
      }
    }
  }
 X_SET: foreach my $x ($x1, $x2) {
    next if $x < 0 || $x >= $width;
    foreach my $y ($y1+1 .. $y2-1) {
      next if $y < $y1 || $y > $y2;
      my $got = $image->xy($x,$y);
      if ($got ne $black) {
        $found_set = 1;
        last X_SET;
      }
    }
  }

  if (! $found_set) {
    push @bad, 'nothing set within';
  }

  return join("\n", @bad);
}

sub my_bounding_box_and_sides {
  my ($image, $x1,$y1, $x2,$y2, $black, $white) = @_;

  my @bad = my_bounding_box(@_);
  if ($bad[0] eq '') {
    pop @bad;
  }

  foreach my $x ($x1, ($x1 == $x2 ? () : ($x2))) {
    my $found = 0;
    foreach my $y ($y1 .. $y2) {
      my $got = $image->xy($x,$y);
      if ($got ne $black) {
        $found = 1;
        last;
      }
    }
    if (! $found) {
    push @bad, "nothing in column x=$x";
    }
  }

  foreach my $y ($y1, ($y1 == $y2 ? () : ($y2))) {
    my $found = 0;
    foreach my $x ($x1 .. $x2) {
      my $got = $image->xy($x,$y);
      if ($got ne $black) {
        $found = 1;
        last;
      }
    }
    if (! $found) {
    push @bad, "nothing in row y=$y";
    }
  }

  return join("\n", @bad);
}


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 65;
  is ($App::MathImage::Image::Base::Tk::Canvas::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::Image::Base::Tk::Canvas->VERSION,  $want_version, 'VERSION class method');

  is (eval { App::MathImage::Image::Base::Tk::Canvas->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  is (! eval { App::MathImage::Image::Base::Tk::Canvas->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $image = App::MathImage::Image::Base::Tk::Canvas->new (-tkcanvas => 'dummy');
  is ($image->VERSION,  $want_version, 'VERSION object method');

  is (eval { $image->VERSION($want_version); 1 },
      1,
      "VERSION object check $want_version");
  is (! eval { $image->VERSION($check_version); 1 },
      1,
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# new()

my $mw = MainWindow->new;
{
  my $image = App::MathImage::Image::Base::Tk::Canvas->new (-for_widget => $mw,
                                           -width => 6,
                                           -height => 7);
  is ($image->get('-file'), undef);
  is ($image->get('-file_format'), undef);
  is ($image->get('-width'), 6);
  is ($image->get('-height'), 7);
  is (defined $image && $image->isa('Image::Base') && 1,
      1,
      'isa Image::Base');
  is (defined $image && $image->isa('App::MathImage::Image::Base::Tk::Canvas') && 1,
      1,
      'isa App::MathImage::Image::Base::Tk::Canvas');
}

# cannot clone yet
# {
#   my $image = App::MathImage::Image::Base::Tk::Canvas->new (-for_widget => $mw,
#                                                            -width => 6,
#                                                            -height => 7);
#   my $i2 = $image->new;
#   is (defined $i2 && $i2->isa('Image::Base') && 1,
#       1,
#       'isa Image::Base');
#   is (defined $i2 && $i2->isa('App::MathImage::Image::Base::Tk::Canvas') && 1,
#       1,
#       'isa App::MathImage::Image::Base::Tk::Canvas');
#   is ($i2->get('-width'),  6, 'copy object -width');
#   is ($i2->get('-height'), 7, 'copy object -height');
#   is ($i2->get('-tkcanvas') != $image->get('-tkcanvas'),
#       1,
#       'copy object different -tkcanvas');
# }

#------------------------------------------------------------------------------
# save() default png

my $test_filename = 'testfile.tmp';

{
  my $image = App::MathImage::Image::Base::Tk::Canvas->new (-for_widget => $mw,
                                                            -width  => 2,
                                                            -height => 1);
  $image->xy (0,0, '#FFFFFF');
  $image->xy (1,0, '#000000');
  $image->save($test_filename);

  is ($image->get('-file'), $test_filename);
}


#------------------------------------------------------------------------------

{
  require MyTestImageBase;
  my $canvas = $mw->Canvas (-background => 'black',
                            -width => 21,
                            -height => 10);
  my $image = App::MathImage::Image::Base::Tk::Canvas->new
    (-tkcanvas => $canvas);
  MyTestImageBase::check_image ($image,
                                image_clear_func => sub {
                                  $canvas->delete($canvas->find('all'));
                                  if ($canvas->find('all')) {
                                    die "oops, canvas not cleared";
                                  }
                                });
}

unlink $test_filename;
exit 0;
