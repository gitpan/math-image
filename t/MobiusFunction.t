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

use App::MathImage::Values::MobiusFunction;

# uncomment this to run the ### lines
#use Smart::Comments;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 31; 
  is ($App::MathImage::Values::MobiusFunction::VERSION, $want_version, 'VERSION variable');
  is (App::MathImage::Values::MobiusFunction->VERSION,  $want_version, 'VERSION class method');

  ok (eval { App::MathImage::Values::MobiusFunction->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Values::MobiusFunction->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# values

{
  my $values_obj = App::MathImage::Values::MobiusFunction->new (lo => 1,
                                                                hi => 30);
  my $want_arrayref = [ [  1, 2 ],
                        [  2, 1 ],
                        [  3, 1 ],
                        [  4, 0 ],
                        [  5, 1 ],
                        [  6, 2 ],
                        [  7, 1 ],
                        [  8, 0 ],
                        [  9, 0 ],
                        [ 10, 2 ],
                        [ 11, 1 ],
                        [ 12, 0 ],
                        [ 13, 1 ],
                        [ 14, 2 ],
                        [ 15, 2 ],
                        [ 16, 0 ],
                        [ 17, 1 ],
                        [ 18, 0 ],
                        [ 19, 1 ],
                        [ 20, 0 ],
                        [ 21, 2 ],
                        [ 22, 2 ],
                        [ 23, 1 ],
                        [ 24, 0 ],
                        [ 25, 0 ],
                        [ 26, 2 ],
                        [ 27, 0 ],
                        [ 28, 0 ],
                        [ 29, 1 ],
                        [ 30, 1 ],
                      ];
  my $got_arrayref = [ map {[$values_obj->next]} 1..30 ];
  ### $got_arrayref
  is_deeply ($got_arrayref, $want_arrayref,
             'MobiusFunction 1 to 30 iterator');

  # my %got_hashref;
  # foreach my $n (2 .. 17) {
  #   if ($gen->is_iter_arrayref($n)) {
  #     $got_hashref{$n} = undef;
  #   }
  # }
  # is_deeply ($got_arrayref, $want_arrayref,
  #            'MobiusFunction 2 to 17 is_iter_arrayref()');
}

exit 0;

