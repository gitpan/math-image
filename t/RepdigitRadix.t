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
use Test;
plan tests => 1504;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }

use App::MathImage::NumSeq::RepdigitRadix;

# uncomment this to run the ### lines
#use Smart::Comments;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 81;
  ok ($App::MathImage::NumSeq::RepdigitRadix::VERSION, $want_version, 'VERSION variable');
  ok (App::MathImage::NumSeq::RepdigitRadix->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::NumSeq::RepdigitRadix->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::NumSeq::RepdigitRadix->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# next() and ith()

sub is_a_repdigit {
  my ($n, $radix) = @_;
  my $digit = $n % $radix;
  for (;;) {
    $n = int($n/$radix);
    if ($n) {
      if (($n % $radix) != $digit) {
        return 0;
      }
    } else {
      return 1;
    }
  }
}

{
  my $seq = App::MathImage::NumSeq::RepdigitRadix->new;
  foreach my $i ($seq->i_start .. 500) {
    my ($got_i, $radix) = $seq->next;
    ok ($got_i, $i);
    ok ($radix == 0 || is_a_repdigit($i,$radix));

    my $ith_radix = $seq->ith($i);
    ok ($radix, $ith_radix);
  }
}

exit 0;
