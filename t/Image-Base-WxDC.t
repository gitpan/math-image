#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012 Kevin Ryde

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

use 5.004;
use strict;
use Test;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

# uncomment this to run the ### lines
#use Devel::Comments;

my $test_count = (tests => 2465)[1];
plan tests => $test_count;

if (! eval { require Wx; 1 }) {
  MyTestHelpers::diag ('Wx not available -- ',$@);
  foreach (1 .. $test_count) {
    skip ('Wx not available', 1, 1);
  }
  exit 0;
}
MyTestHelpers::diag ("Perl-Wx VERSION ",Wx->VERSION);
MyTestHelpers::diag ("Wx VERSION ",Wx::wxVERSION_STRING());

require App::MathImage::Image::Base::Wx::DC;

my $bitmap = Wx::Bitmap->new (20,10);
my $dc = Wx::MemoryDC->new;
$dc->SelectObject($bitmap);


#------------------------------------------------------------------------------
# VERSION

my $want_version = 101;
ok ($App::MathImage::Image::Base::Wx::DC::VERSION, $want_version,
    'VERSION variable');
ok (App::MathImage::Image::Base::Wx::DC->VERSION, $want_version,
    'VERSION class method');

ok (eval { App::MathImage::Image::Base::Wx::DC->VERSION($want_version); 1 },
    1,
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { App::MathImage::Image::Base::Wx::DC->VERSION($check_version); 1 },
    1,
    "VERSION class check $check_version");


#------------------------------------------------------------------------------
# new() clone ????

# {
#   my $i1 = App::MathImage::Image::Base::Wx::DC->new
#     (-width => 11, -height => 22);
#   my $i2 = $i1->new;
#   # no resize yet ...
#   # $i2->set (-width => 33, -height => 44);
#
#   ok ($i1->get('-width'), 11, 'clone original width');
#   ok ($i1->get('-height'), 22, 'clone original height');
#   ok ($i2->get('-width'), 11, 'clone new width');
#   ok ($i2->get('-height'), 22, 'clone new height');
# }

#------------------------------------------------------------------------------
# xy

{
  my $image = App::MathImage::Image::Base::Wx::DC->new (-dc => $dc);
  $image->xy (2,2, '#000');
  ok ($image->xy (2,2), '#000000', 'xy() #000');

  $image->xy (3,3, "#010203");
  ok ($image->xy (3,3), '#010203', 'xy() rgb');

  $image->xy (0,0, '#FFFF00000000');
  ok ($image->xy(0,0), '#FF0000');
}


#------------------------------------------------------------------------------
# check_image

{
  my $image = App::MathImage::Image::Base::Wx::DC->new (-dc => $dc);
  ok ($image->get('-width'), 20);
  ok ($image->get('-height'), 10);

  require MyTestImageBase;
  $MyTestImageBase::black = '#000000';
  $MyTestImageBase::white = '#FFFFFF';
  $MyTestImageBase::black = '#000000';
  $MyTestImageBase::white = '#FFFFFF';
  MyTestImageBase::check_image ($image,
                                big_fetch_expect => '#FFFFFF');
  MyTestImageBase::check_diamond ($image);
}

exit 0;
