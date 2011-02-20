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
use Test::More tests => 7;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use App::MathImage::Values::Emirps;

# uncomment this to run the ### lines
#use Smart::Comments;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 44;
  is ($App::MathImage::Values::Emirps::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::Values::Emirps->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::Values::Emirps->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Values::Emirps->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# _reverse_in_radix()

{
  ## no critic (ProtectPrivateSubs)
  is (App::MathImage::Values::Emirps::_reverse_in_radix(123,10),
      321);
  is (App::MathImage::Values::Emirps::_reverse_in_radix(0xAB,16),
      0xBA);
  is (App::MathImage::Values::Emirps::_reverse_in_radix(6,2),
      3);
}

exit 0;


