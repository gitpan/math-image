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

use 5.004;
use strict;
use warnings;
use Math::BigInt try => 'GMP';

#my $bits = 100;

# my $factor = Math::BigInt->new(1);
# $factor <<= $bits;
# print $factor->as_hex,"\n";


my $str = ln3_binary(200);
$,="\n";
print binary_positions(ln3_binary(200));




