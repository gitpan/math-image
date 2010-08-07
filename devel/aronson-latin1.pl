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
use Encode;
use Unicode::Normalize 'normalize';

use Smart::Comments;

my $from = '';
my $to = '';
foreach my $i (0x80 .. 0xFF) {
  my $str = chr($i);
  $str = Encode::decode ('latin-1', $str);

  # perl 5.10 thinks all non-ascii is alpha, or some such
  next unless $str =~ /[[:alpha:]]/;

  my $nfd = normalize('D',$str);
  ### $str
  ### $nfd

  if ($nfd =~ /^([[:ascii:]])/) {
    $from .= sprintf '\\x{%02X}', $i;
    $to   .= $1;
  }
}

print "tr/$from/$to/\n";

exit 0;
