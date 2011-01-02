#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
use strict;
use warnings;
use Math::Expression::Evaluator;

use Smart::Comments;

{
  my $me = Math::Expression::Evaluator->new;
  $me->parse ('phi=(1+sqrt(5))/2; z=3; z*x^2 + x + 2');
  # $me->optimize;
  ### variables: $me->variables
  ### val: $me->val({x => 4})

  my $comp = $me->compiled;
  ### $comp
  ### comp: &$comp({x=>4})
  ### ast: $me->_ast_to_perl($me->{ast})

  exit 0;
}
