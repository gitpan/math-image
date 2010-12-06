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

use 5.004;
use strict;
use warnings;
use Test::More tests => 5;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use App::MathImage::Values::CountPrimeFactors;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 36;
  is ($App::MathImage::Values::CountPrimeFactors::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::Values::CountPrimeFactors->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::Values::CountPrimeFactors->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Values::CountPrimeFactors->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# values

{
  my $values_obj = App::MathImage::Values::CountPrimeFactors->new (lo => 1,
                                                                   hi => 30);
  my $want_arrayref = [ 1,  # 1
                        1,  # 2
                        1,  # 3
                        2,  # 4
                        1,  # 5
                        2,  # 6
                        1,  # 7
                        3,  # 8
                        2,  # 9
                        2,  # 10
                        1,  # 11
                        3,  # 12
                        1,  # 13
                        2,  # 14
                        2,  # 15
                        4,  # 16
                        1,  # 17
                        3,  # 18
                        1,  # 19
                        3,  # 20
                        2,  # 21
                        2,  # 22
                        1,  # 23
                        4,  # 24
                        2,  # 25
                        2,  # 26
                        3,  # 27
                        3,  # 28
                        1,  # 29
                        3,  # 30
                      ];
  my $got_arrayref = [ map {($values_obj->next)[1]} 1..30 ];
  is_deeply ($got_arrayref, $want_arrayref,
             'CountPrimeFactors 1 to 30 iterator');

  # my %got_hashref;
  # foreach my $n (2 .. 17) {
  #   if ($gen->is_iter_arrayref($n)) {
  #     $got_hashref{$n} = undef;
  #   }
  # }
  # is_deeply ($got_arrayref, $want_arrayref,
  #            'CountPrimeFactors 2 to 17 is_iter_arrayref()');
}

exit 0;


