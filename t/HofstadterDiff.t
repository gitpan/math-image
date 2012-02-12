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
plan tests => 5;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use Math::NumSeq::MathImageHofstadterDiff;

# uncomment this to run the ### lines
#use Smart::Comments;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 93;
  ok ($Math::NumSeq::MathImageHofstadterDiff::VERSION, $want_version,
      'VERSION variable');
  ok (Math::NumSeq::MathImageHofstadterDiff->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::NumSeq::MathImageHofstadterDiff->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::NumSeq::MathImageHofstadterDiff->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# next() all integers

{

  my $seq = Math::NumSeq::MathImageHofstadterDiff->new;
  my $hi = 10000;
  my $bad = 0;

 OUTER: foreach my $rewind (0 .. 1) {
    my @seen;
    my $prev_value = 1;
    my $prev_i = 0;
    for (;;) {
      my ($i,$value) = $seq->next;
      if ($i != $prev_i+1) {
        MyTestHelpers::diag("oops i=$i, prev_i=$prev_i");
        last OUTER if $bad++ > 10;
      }

      if ($value < 0) {
        MyTestHelpers::diag("oops negative value=$value");
        $bad++;
        last;
      }
      if ($value <= $hi) {
        if ($seen[$value]) {
          MyTestHelpers::diag("value=$value already seen ($seen[$value])");
          last OUTER if $bad++ > 10;
        }
        $seen[$value] = $i;
      }

      my $diff = $value - $prev_value;
      if ($diff > $hi) {
        last;
      }
      if ($seen[$diff]) {
        MyTestHelpers::diag("diff=$diff already seen ($seen[$diff]), at i=$i value=$value prev_value=$prev_value");
        last if $bad++ > 10;
      }
      $seen[$diff] = -$i;

      $prev_i = $i;
      $prev_value = $value;
    }

    foreach my $i (1 .. $hi) {
      if (! $seen[$i]) {
        MyTestHelpers::diag("$i not seen");
        last if $bad++ > 10;
      }
    }
    MyTestHelpers::diag("rewind");
    $seq->rewind;
  }
  ok ($bad, 0);
}

exit 0;

