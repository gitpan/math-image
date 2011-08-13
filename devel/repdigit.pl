#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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
use Math::Libm 'log10';

# uncomment this to run the ### lines
use Smart::Comments;


{
  require App::MathImage::NumSeq::RepdigitAnyBase;
  require App::MathImage::NumSeq::RepdigitBase;
  my $rany = App::MathImage::NumSeq::RepdigitAnyBase->new (hi => 9999);
  my $rb = App::MathImage::NumSeq::RepdigitBase->new (hi => 9999);
  foreach (1 .. 20) {
    my ($i,$value) = $rany->next;
    $value = $i;
    my $base = $rb->ith($value);
    print "$base,";
  }
  print "\n";
  exit 0;
}

{
  require App::MathImage::Generator;
  my $gen = App::MathImage::Generator->new (fraction => '5/29',
                                            polygonal => 3);
  my $iter = $gen->values_make_repdigit_any_base(1,10000000);
  my @hist;
  while (defined (my $n = $iter->())) {
    $hist[int(log10($n))]++;
  }
  my $prev_log = 0;
  foreach my $count (@hist) {
    my $log = log10($count);
    my $diff = $log - $prev_log;
    print "$count  $log   $diff\n";
    $prev_log = $log;
  }
  exit 0;
}

