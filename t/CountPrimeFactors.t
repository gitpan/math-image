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
use Test::More tests => 6;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use App::MathImage::NumSeq::PrimeFactorCount;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 65;
  is ($App::MathImage::NumSeq::PrimeFactorCount::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::NumSeq::PrimeFactorCount->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::NumSeq::PrimeFactorCount->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::NumSeq::PrimeFactorCount->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# characteristic()

{
  my $values_obj = App::MathImage::NumSeq::PrimeFactorCount->new
    (lo => 1,
     hi => 30);

  is ($values_obj->characteristic('count'), 1, 'characteristic(count)');
}


#------------------------------------------------------------------------------
# values

{
  my $values_obj = App::MathImage::NumSeq::PrimeFactorCount->new
    (lo => 0,
     hi => 30);
  my $want_arrayref = [ [1,0],  # 1
                        [2,1],  # 2
                        [3,1],  # 3
                        [4,2],  # 4
                        [5,1],  # 5
                        [6,2],  # 6
                        [7,1],  # 7
                        [8,3],  # 8
                        [9,2],  # 9
                        [10,2],  # 10
                        [11,1],  # 11
                        [12,3],  # 12
                        [13,1],  # 13
                        [14,2],  # 14
                        [15,2],  # 15
                        [16,4],  # 16
                        [17,1],  # 17
                        [18,3],  # 18
                        [19,1],  # 19
                        [20,3],  # 20
                        [21,2],  # 21
                        [22,2],  # 22
                        [23,1],  # 23
                        [24,4],  # 24
                        [25,2],  # 25
                        [26,2],  # 26
                        [27,3],  # 27
                        [28,3],  # 28
                        [29,1],  # 29
                        [30,3],  # 30
                      ];
  my $got_arrayref = [ map {[$values_obj->next]} 1..30 ];
  is_deeply ($got_arrayref, $want_arrayref,
             'PrimeFactorCount 1 to 30 iterator');

  # my %got_hashref;
  # foreach my $n (2 .. 17) {
  #   if ($gen->is_iter_arrayref($n)) {
  #     $got_hashref{$n} = undef;
  #   }
  # }
  # is_deeply ($got_arrayref, $want_arrayref,
  #            'PrimeFactorCount 2 to 17 is_iter_arrayref()');
}

exit 0;


