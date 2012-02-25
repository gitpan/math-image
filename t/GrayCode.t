#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012 Kevin Ryde

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
plan tests => 99;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use Math::PlanePath::MathImageGrayCode;

# uncomment this to run the ### lines
#use Smart::Comments;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 95;
  ok ($Math::PlanePath::MathImageGrayCode::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::MathImageGrayCode->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::MathImageGrayCode->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::MathImageGrayCode->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# _to_gray(), _from_gray()

my @gray = (from_binary('00000'),
            from_binary('00001'),
            from_binary('00011'),
            from_binary('00010'),
            from_binary('00110'),
            from_binary('00111'),
            from_binary('00101'),
            from_binary('00100'),

            from_binary('01100'),
            from_binary('01101'),
            from_binary('01111'),
            from_binary('01110'),
            from_binary('01010'),
            from_binary('01011'),
            from_binary('01001'),
            from_binary('01000'),

            from_binary('11000'),
            from_binary('11001'),
            from_binary('11011'),
            from_binary('11010'),
            from_binary('11110'),
            from_binary('11111'),
            from_binary('11101'),
            from_binary('11100'),

            from_binary('10100'),
            from_binary('10101'),
            from_binary('10111'),
            from_binary('10110'),
            from_binary('10010'),
            from_binary('10011'),
            from_binary('10001'),
            from_binary('10000'),
           );
### @gray

foreach my $i (0 .. $#gray) {
  my $gray = $gray[$i];
  if ($i > 0) {
    my $prev_gray = $gray[$i-1];
    my $xor = $gray ^ $prev_gray;
    ok (is_pow2($xor), 1,
       "at i=$i   $gray ^ $prev_gray = $xor");
  }

  my $got_gray = Math::PlanePath::MathImageGrayCode::_to_gray($i);
  ok ($got_gray, $gray);

  my $got_i = Math::PlanePath::MathImageGrayCode::_from_gray($gray);
  ok ($got_i, $i);
}

sub from_binary {
  my ($str) = @_;
  my $ret = 0;
  foreach my $digit (split //, $str) {
    $ret = ($ret << 1) + $digit;
  }
  return $ret;
}

sub is_pow2 {
  my ($n) = @_;
  while (($n & 1) == 0) {
    if ($n == 0) {
      return 0;
    }
    $n >>= 1;
  }
  return ($n == 1);
}

exit 0;
