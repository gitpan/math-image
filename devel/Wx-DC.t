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

use 5.004;
use strict;
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

use Wx;

#  or plan skip_all => 'due to no DISPLAY available';

plan tests => 4408;

use_ok ('App::MathImage::Image::Base::Wx::DC');
diag "Image::Base version ", Image::Base->VERSION;

my $bitmap = Wx::Bitmap->new (21,10);
my $dc = Wx::MemoryDC->new;
$dc->SelectObject($bitmap);
my $pen = $dc->GetPen;
$pen->SetCap(Wx::wxCAP_PROJECTING());
$dc->SetPen($pen);

#------------------------------------------------------------------------------
# VERSION

my $want_version = 83;
is ($App::MathImage::Image::Base::Wx::DC::VERSION,
    $want_version, 'VERSION variable');
is (App::MathImage::Image::Base::Wx::DC->VERSION,
    $want_version, 'VERSION class method');

ok (eval { App::MathImage::Image::Base::Wx::DC->VERSION($want_version); 1 },
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { App::MathImage::Image::Base::Wx::DC->VERSION($check_version); 1 },
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# new()

{
  my $image = App::MathImage::Image::Base::Wx::DC->new
    (-dc => $dc);
  isa_ok ($image, 'Image::Base');
  isa_ok ($image, 'App::MathImage::Image::Base::Wx::DC');

  is ($image->VERSION,  $want_version, 'VERSION object method');
  ok (eval { $image->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $image->VERSION($check_version); 1 },
      "VERSION object check $check_version");

  is ($image->get('-file'), undef, 'get() -file');
  is ($image->get('-width'),  21, 'get() -width');
  is ($image->get('-height'), 10, 'get() -height');
  # cmp_ok ($image->get('-depth'), '>', 0, 'get() -depth');
}

{
  my $image = App::MathImage::Image::Base::Wx::DC->new
    (-dc => $dc);
  isa_ok ($image, 'Image::Base');
  isa_ok ($image, 'App::MathImage::Image::Base::Wx::DC');
  # is ($image->get('-depth'),  1, 'get() -depth');
}


#------------------------------------------------------------------------------
# colour_to_pixel

# {
#   my $image = App::MathImage::Image::Base::Wx::DC->new
#     (-dc => $dc);
#   foreach my $colour ('black', 'white', '#FF00FF', '#0000AAAAbbbb') {
#     my $c1 = $image->colour_to_colorobj($colour);
#     my $c2 = $image->colour_to_colorobj($colour);
#     is ($c1->pixel, $c2->pixel, "colour_to_colorobj() pixels $colour");
#   }
#   {
#     my $c = $image->colour_to_colorobj('set');
#     is ($c->pixel, 1, "colour_to_colorobj() 'set'");
#   }
#   {
#     my $c = $image->colour_to_colorobj('clear');
#     is ($c->pixel, 0, "colour_to_colorobj() 'clear'");
#   }
# }

#------------------------------------------------------------------------------
# line

{
  my $image = App::MathImage::Image::Base::Wx::DC->new
    (-dc => $dc,
     -width => 21, -height => 10);
  $image->rectangle (0,0, 20,9, 'black', 1);
  $image->line (5,5, 7,7, 'white', 0);
  is ($image->xy (4,4), '#000000');
  is ($image->xy (5,5), '#FFFFFF');
  is ($image->xy (5,6), '#000000');
  is ($image->xy (6,6), '#FFFFFF');
  is ($image->xy (7,7), '#FFFFFF');
  is ($image->xy (8,8), '#000000');
  # require MyTestImageBase;
  # MyTestImageBase::dump_image($image);
}
{
  my $image = App::MathImage::Image::Base::Wx::DC->new
    (-dc => $dc,
     -width => 21, -height => 10);
  $image->rectangle (0,0, 20,9, 'black', 1);
  $image->line (0,0, 2,2, 'white', 1);
  is ($image->xy (0,0), '#FFFFFF');
  is ($image->xy (1,1), '#FFFFFF');
  is ($image->xy (2,1), '#000000');
  is ($image->xy (3,3), '#000000');
}

#------------------------------------------------------------------------------
# xy

{
  my $image = App::MathImage::Image::Base::Wx::DC->new
    (-dc => $dc,
     -width => 21, -height => 10);
  $image->rectangle (0,0, 20,9, 'black', 1);
  $image->xy (2,2, 'black');
  $image->xy (3,3, 'white');
  $image->xy (4,4, '#ffffff');
  is ($image->xy (2,2), '#000000', 'xy()  ');
  is ($image->xy (3,3), '#FFFFFF', 'xy() *');
  is ($image->xy (4,4), '#FFFFFF', 'xy() *');
}

#------------------------------------------------------------------------------
# rectangle

{
  my $image = App::MathImage::Image::Base::Wx::DC->new
    (-dc => $dc,
     -width => 21, -height => 10);
  $image->rectangle (0,0, 20,9, 'black', 1);
  $image->rectangle (5,5, 7,7, 'white', 0);
  is ($image->xy (5,5), '#FFFFFF');
  is ($image->xy (6,6), '#000000');
  is ($image->xy (7,6), '#FFFFFF');
  is ($image->xy (8,8), '#000000');
  # require MyTestImageBase;
  # MyTestImageBase::dump_image($image);
}
{
  my $image = App::MathImage::Image::Base::Wx::DC->new
    (-dc => $dc,
     -width => 21, -height => 10);
  $image->rectangle (0,0, 20,9, 'black', 1);
  $image->rectangle (0,0, 2,2, '#FFFFFF', 1);
  is ($image->xy (0,0), '#FFFFFF');
  is ($image->xy (1,1), '#FFFFFF');
  is ($image->xy (2,1), '#FFFFFF');
  is ($image->xy (3,3), '#000000');
}

#------------------------------------------------------------------------------
# diamond()

{
  my $image = App::MathImage::Image::Base::Wx::DC->new
    (-dc => $dc,
     -width => 21, -height => 10);
  $image->rectangle (0,0, 20,9, 'black', 1);
  $image->diamond (0,0, 20,9, 'black', 1);
  $image->diamond (5,5, 7,7, 'white', 0);
}

#------------------------------------------------------------------------------
# ellipse()

{
  my $image = App::MathImage::Image::Base::Wx::DC->new
    (-dc => $dc,
     -width => 21, -height => 10);
  $image->rectangle (0,0, 20,9, 'black', 1);
  $image->ellipse (0,0, 20,9, 'black', 1);
  $image->ellipse (5,5, 7,7, 'white', 0);
}

#------------------------------------------------------------------------------

{
  require MyTestImageBase;
  my $image = App::MathImage::Image::Base::Wx::DC->new
    (-dc => $dc,
     -width => 21, -height => 10);

  local $MyTestImageBase::white = 'white';
  local $MyTestImageBase::black = 'black';

  # require MyTestImageBase;
  # MyTestImageBase::dump_image($image);

  MyTestImageBase::check_image ($image);
  MyTestImageBase::check_diamond ($image);
}

# monochrome
{
  #   require MyTestImageBase;
  #   # my $bitmap = Wx::Pixmap->new ($rootwin,
  #   #                                      21,10, 1);
  #   my $image = App::MathImage::Image::Base::Wx::DC->new
  #     (-dc => $dc,
  #      -width => 21, -height => 10);
  local $MyTestImageBase::white = 1;
  local $MyTestImageBase::black = 0;
  #   MyTestImageBase::check_image ($image);
}

exit 0;
