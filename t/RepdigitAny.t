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
plan tests => 6;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }

use App::MathImage::NumSeq::RepdigitAny;

# uncomment this to run the ### lines
#use Smart::Comments;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 75;
  ok ($App::MathImage::NumSeq::RepdigitAny::VERSION, $want_version, 'VERSION variable');
  ok (App::MathImage::NumSeq::RepdigitAny->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::NumSeq::RepdigitAny->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::NumSeq::RepdigitAny->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# next()

sub collect {
  my ($seq, $count) = @_;
  my @i;
  my @values;
  foreach (1 .. ($count||11)) {
    my ($i, $value) = $seq->next
      or last;
    push @i, $i;
    push @values, $value;
  }
  return join(',',@i) . ' -- ' . join(',',@values);
}
    
{
  my $seq = App::MathImage::NumSeq::RepdigitAny->new;
  ok ($seq->oeis_anum, 'A167782');
  ok (collect($seq), '1,2,3,4,5,6,7,8,9,10,11 -- 0,7,13,15,21,26,31,40,42,43,57');
}

exit 0;
