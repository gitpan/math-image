#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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
plan tests => 6;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use Math::NumSeq::MathImageDeletablePrimes;

# uncomment this to run the ### lines
#use Smart::Comments;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 96;
  ok ($Math::NumSeq::MathImageDeletablePrimes::VERSION, $want_version,
      'VERSION variable');
  ok (Math::NumSeq::MathImageDeletablePrimes->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::NumSeq::MathImageDeletablePrimes->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::NumSeq::MathImageDeletablePrimes->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# pred()

foreach my $group ([ 2,
                     [ 67, 0 ],
                   ],
                   [ 10,
                     [ 2003, 0 ],
                   ]) {
  my ($radix, @elems) = @$group;
  my $seq = Math::NumSeq::MathImageDeletablePrimes->new (radix => $radix);
  foreach my $elem (@elems) {
    my ($value, $want) = @$elem;
    ok ($seq->pred($value), $want,
        "value=$value");
  }
}

exit 0;
