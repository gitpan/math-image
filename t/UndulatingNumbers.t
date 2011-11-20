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
use Test::More tests => 5;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use App::MathImage::NumSeq::UndulatingNumbers;

# uncomment this to run the ### lines
#use Smart::Comments;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 81;
  is ($App::MathImage::NumSeq::UndulatingNumbers::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::NumSeq::UndulatingNumbers->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::NumSeq::UndulatingNumbers->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::NumSeq::UndulatingNumbers->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# values

{
  my $hi = 13000;
  my $values_obj = App::MathImage::NumSeq::UndulatingNumbers->new
    (lo => 1,
     hi => $hi);
  my @next = (0) x ($hi+1);
  while (my ($i, $value) = $values_obj->next) {
    last if ($value > $hi);
    $next[$value] = 1;
  }
  # $values_obj->finish;

  my $good = 1;
  foreach my $value (1 .. $hi) {
    my $pred = ($values_obj->pred($value)?1:0);
    my $next = $next[$value];
    if ($pred != $next) {
      diag "value=$value wrong pred=$pred next=$next";
      $good = 0;
      last;
    }
  }
  ok ($good, "good");
}

exit 0;


