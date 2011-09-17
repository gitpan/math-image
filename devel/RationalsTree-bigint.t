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
use Test;
use Math::BigInt;

# uncomment this to run the ### lines
#use Devel::Comments '###';

use lib 't';
use MyTestHelpers;

my $test_count = 6;
plan tests => $test_count;

MyTestHelpers::diag ('Math::BigInt version ', Math::BigInt->VERSION);
{
  my $n = Math::BigInt->new(2) ** 256;
  my $int = int($n);
  if (! ref $int) {
    MyTestHelpers::diag ('skip due to Math::BigInt no "int" operator');
    foreach (1 .. $test_count) {
      skip ('due to no Math::BigInt "**" operator', 1, 1);
    }
    exit 0;
  }
}

MyTestHelpers::nowarnings();


exit 0;
