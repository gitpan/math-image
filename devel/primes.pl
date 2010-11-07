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

use Smart::Comments;
use blib "$ENV{HOME}/perl/bit-vector/Bit-Vector-7.1/blib";
{
  require Bit::Vector;
  my $size = 0xFF; # F00000;
  my $vector = Bit::Vector->new($size);
  $vector->Primes();
  print $vector->bit_test(0),"\n";
  print $vector->bit_test(1),"\n";
  print $vector->bit_test(2),"\n";
  print $vector->bit_test(3),"\n";
  print $vector->bit_test(4),"\n";
  print $vector->bit_test(5),"\n";
  print $vector->bit_test(1928099),"\n";
  foreach my $i (0 .. 100) {
    if ($vector->bit_test($i)) {
      print ",$i";
    }
  }
  print "\n";


  # require Math::Prime::XS;
  # foreach my $i (65536 .. $size-1) {
  #   my $v = 0 + $vector->bit_test($i);
  #   my $x = 0 + Math::Prime::XS::is_prime($i);
  #   if ($v != $x) {
  #     print "$i $v $x\n";
  #   }
  # }
  exit 0;
}

{
  require Math::Prime::XS;
  local $, = "\n";
  print Math::Prime::XS::sieve_primes(2,3);
  exit 0;
}
