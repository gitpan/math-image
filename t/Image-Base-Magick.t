#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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

use 5.010;
use strict;
use warnings;
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

eval { require Image::Magick }
  or plan skip_all => "due to no Image::Magick -- $@";

plan tests => 7;
use_ok ('App::MathImage::Image::Base::Magick');


#------------------------------------------------------------------------------
# VERSION

my $want_version = 27;
is ($App::MathImage::Image::Base::Magick::VERSION,
    $want_version, 'VERSION variable');
is (App::MathImage::Image::Base::Magick->VERSION,
    $want_version, 'VERSION class method');

ok (eval { App::MathImage::Image::Base::Magick->VERSION($want_version); 1 },
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { App::MathImage::Image::Base::Magick->VERSION($check_version); 1 },
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# new()

{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width  => 20,
     -height => 10);
  is ($image->get('-width'), 20);
  is ($image->get('-height'), 10);

  # not working yet
  #   require MyTestImageBase;
  #   MyTestImageBase::check_image ($image);
}

exit 0;
