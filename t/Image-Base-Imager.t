#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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
use warnings;
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

eval { require Imager }
  or plan skip_all => "due to no Imager module -- $@";

plan tests => 1505;
use_ok ('App::MathImage::Image::Base::Imager');


#------------------------------------------------------------------------------
# VERSION

my $want_version = 42;
is ($App::MathImage::Image::Base::Imager::VERSION,
    $want_version, 'VERSION variable');
is (App::MathImage::Image::Base::Imager->VERSION,
    $want_version, 'VERSION class method');

ok (eval { App::MathImage::Image::Base::Imager->VERSION($want_version); 1 },
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { App::MathImage::Image::Base::Imager->VERSION($check_version); 1 },
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# new()

{
  my $image = App::MathImage::Image::Base::Imager->new
    (-width  => 20,
     -height => 10);
  is ($image->get('-width'), 20);
  is ($image->get('-height'), 10);

  $image->xy (0,0, 'red');
  is ($image->xy(0,0), '#FF0000');

  require MyTestImageBase;
  MyTestImageBase::check_image ($image);
}

exit 0;
