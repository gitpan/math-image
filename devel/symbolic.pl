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
use Math::Symbolic;

use Smart::Comments;

use lib 'devel/lib';

my $tree = Math::Symbolic->parse_from_string('');
### $tree
$tree = $tree->simplify;

### signature: [$tree->signature]

my ($code) = Math::Symbolic::Compiler->compile_to_code($tree, ['x']);
### $code 

my ($subr) = $tree->to_sub (x => 0);
# ### $subr

foreach my $i (0 .. 10) {
  say $i, ' ', $subr->($i);
}
exit 0;
