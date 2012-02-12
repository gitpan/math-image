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
plan tests => 4;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use Math::NumSeq::MathImageUndulatingNumbers;

# uncomment this to run the ### lines
#use Smart::Comments;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 93;
  ok ($Math::NumSeq::MathImageUndulatingNumbers::VERSION, $want_version,
      'VERSION variable');
  ok (Math::NumSeq::MathImageUndulatingNumbers->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::NumSeq::MathImageUndulatingNumbers->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::NumSeq::MathImageUndulatingNumbers->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# values

# foreach my $radix (2 .. 16) {
#   my $hi = 1000;
#   my $seq = Math::NumSeq::MathImageUndulatingNumbers->new (radix => $radix);
#   my @next = (0) x ($hi+1);
#   while (my ($i, $value) = $seq->next) {
#     last if ($value > $hi);
#     $next[$value] = 1;
#   }
# 
#   my $good = 1;
#   foreach my $value (1 .. $hi) {
#     my $pred = ($seq->pred($value)?1:0);
#     my $next = $next[$value];
#     if ($pred != $next) {
#       MyTestHelpers::diag ("radix=$radix value=$value wrong pred=$pred next=$next");
#       $good = 0;
#       last;
#     }
#   }
#   ok ($good, 1, "good");
# }

exit 0;


