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
use Test::More tests => 14;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use App::MathImage::NumSeq::Totient;

# uncomment this to run the ### lines
#use Smart::Comments;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 67;
  is ($App::MathImage::NumSeq::Totient::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::NumSeq::Totient->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::NumSeq::Totient->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::NumSeq::Totient->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# characteristic()

{
  my $values_obj = App::MathImage::NumSeq::Totient->new
    (lo => 1,
     hi => 30);

  is ($values_obj->characteristic('count'), 1, 'characteristic(count)');
}


#------------------------------------------------------------------------------
# _totient()

# {
#   my $values_obj = App::MathImage::NumSeq::Totient->new;
#   foreach my $elem ([0, 0],
#                     [1, 1],
#                     [2, 1],
#                     [3, 2],
#                     [4, 2],
#                     [5, 4],
#                    ) {
#     my ($i, $want) = @$elem;
#     my $got = App::MathImage::NumSeq::Totient::_totient($i);
#     is ($got, $want, "_totient() i=$i got $got want $want");
#   }
# }

#------------------------------------------------------------------------------
# _totient_by_sieve()

{
  my $values_obj = App::MathImage::NumSeq::Totient->new;
  foreach my $elem ([0, 0],
                    [1, 1],
                    [2, 1],
                    [3, 2],
                    [4, 2],
                    [5, 4],

                    [9, 6],   # coprime 1,2,4,5,7,8
                    [10, 4],  # coprime 1,3,7,9
                    [11, 10],
                   ) {
    my ($i, $want) = @$elem;
    my $got = App::MathImage::NumSeq::Totient::_totient_by_sieve($values_obj,$i);
    is ($got, $want, "_totient_by_sieve() i=$i got $got want $want");
  }
}

exit 0;


