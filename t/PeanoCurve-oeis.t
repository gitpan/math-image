#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.

use 5.004;
use strict;
use warnings;
use Test::More tests => 20;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use App::MathImage::PlanePath::PeanoCurve;
use Math::PlanePath::Diagonals;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $peano  = App::MathImage::PlanePath::PeanoCurve->new;
my $diagonal = Math::PlanePath::Diagonals->new;

#------------------------------------------------------------------------------
# A163334 -- diagonals same axis
SKIP: {
  my $anum = 'A163334';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $diagonal->n_to_xy ($n);
    ($x, $y) = ($y, $x);
    my $n = $peano->xy_to_n ($x, $y);
    ### diagonals same: "$x,$y is $n"
    push @got, $n;
  }
  is_deeply (\@got, $bvalues);
}

#------------------------------------------------------------------------------
# A163335 -- diagonals same axis, inverse
SKIP: {
  my $anum = 'A163335';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (0 .. $#$bvalues) {
    my ($x, $y) = $peano->n_to_xy ($n);
    ($x, $y) = ($y, $x);
    my $n = $diagonal->xy_to_n ($x, $y);
    push @got, $n - 1;
  }
  is_deeply (\@got, $bvalues);
}

#------------------------------------------------------------------------------
# A163336 -- diagonals opposite axis
SKIP: {
  my $anum = 'A163336';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $diagonal->n_to_xy ($n);
    my $n = $peano->xy_to_n ($x, $y);
    push @got, $n;
  }
  is_deeply (\@got, $bvalues);
}

#------------------------------------------------------------------------------
# A163337 -- diagonals same axis, inverse
SKIP: {
  my $anum = 'A163337';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (0 .. $#$bvalues) {
    my ($x, $y) = $peano->n_to_xy ($n);
    my $n = $diagonal->xy_to_n ($x, $y);
    push @got, $n - 1;
  }
  is_deeply (\@got, $bvalues);
}

#------------------------------------------------------------------------------
# A163342 -- diagonal sums
# no b-file as of Jan 2011
SKIP: {
  my $anum = 'A163342';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $d (0 .. $#$bvalues) {
    my $sum = 0;
    foreach my $x (0 .. $d) {
      my $y = $d - $x;
      $sum += $peano->xy_to_n ($x, $y);
    }
    push @got, $sum;
  }
  is_deeply (\@got, $bvalues, 'A163342 -- diagonal sums');
}

# A163479 -- diagonal sums div 6
SKIP: {
  my $anum = 'A163479';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $d (0 .. $#$bvalues) {
    my $sum = 0;
    foreach my $x (0 .. $d) {
      my $y = $d - $x;
      $sum += $peano->xy_to_n ($x, $y);
    }
    push @got, int($sum/6);
  }
  is_deeply (\@got, $bvalues, 'A163479 -- diagonal sums');
}

#------------------------------------------------------------------------------
# A163343 -- central diagonal
SKIP: {
  my $anum = 'A163343';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $x (0 .. $#$bvalues) {
    my $n = $peano->xy_to_n ($x, $x);
    push @got, $n;
  }
  is_deeply (\@got, $bvalues, 'A163343 -- central diagonal');
}

# A163344 -- central diagonal div 4
SKIP: {
  my $anum = 'A163344';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $x (0 .. $#$bvalues) {
    my $n = $peano->xy_to_n ($x, $x);
    push @got, int($n/4);
  }
  is_deeply (\@got, $bvalues, "$anum -- central diagonal div 4");
}

#------------------------------------------------------------------------------
# A163528 -- X coordinate
SKIP: {
  my $anum = 'A163528';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (0 .. $#$bvalues) {
    my ($x, $y) = $peano->n_to_xy ($n);
    push @got, $x;
  }
  is_deeply (\@got, $bvalues, "$anum -- X coordinate");
}

#------------------------------------------------------------------------------
# A163529 -- Y coordinate
SKIP: {
  my $anum = 'A163529';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (0 .. $#$bvalues) {
    my ($x, $y) = $peano->n_to_xy ($n);
    push @got, $y;
  }
  is_deeply (\@got, $bvalues, "$anum -- Y coordinate");
}

#------------------------------------------------------------------------------
# A163530 -- coord sum X+Y
SKIP: {
  my $anum = 'A163530';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (0 .. $#$bvalues) {
    my ($x, $y) = $peano->n_to_xy ($n);
    my $sum = $x + $y;
    push @got, $sum;
  }
  is_deeply (\@got, $bvalues, "$anum -- sum coords X+Y");
}

#------------------------------------------------------------------------------
# A163531 -- square of distance, ie. x^2+y^2
SKIP: {
  my $anum = 'A163531';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (0 .. $#$bvalues) {
    my ($x, $y) = $peano->n_to_xy ($n);
    my $sqr = $x*$x + $y*$y;
    push @got, $sqr;
  }
  is_deeply (\@got, $bvalues, "$anum -- square of distance");
}

#------------------------------------------------------------------------------
# A163532 -- delta X
# first entry is for N=0 no change
SKIP: {
  my $anum = 'A163532';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my ($prev_x, $prev_y) = (0, 0);
  my @got;
  foreach my $n (0 .. $#$bvalues) {
    my ($x, $y) = $peano->n_to_xy ($n);
    my $dx = $x - $prev_x;
    push @got, $dx;
    ($prev_x, $prev_y) = ($x, $y);
  }
  is_deeply (\@got, $bvalues, "$anum -- delta X (transpose)");
}

#------------------------------------------------------------------------------
# A163533 -- delta Y
# first entry is for N=0 no change
SKIP: {
  my $anum = 'A163533';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my ($prev_x, $prev_y) = (0, 0);
  my @got;
  foreach my $n (0 .. $#$bvalues) {
    my ($x, $y) = $peano->n_to_xy ($n);
    my $dy = $y - $prev_y;
    push @got, $dy;
    ($prev_x, $prev_y) = ($x, $y);
  }
  is_deeply (\@got, $bvalues, "$anum -- delta Y (transpose)");
}

#------------------------------------------------------------------------------
# A163534 -- absolute direction 0=east, 1=south, 2=west, 3=north
# Y coordinates reckoned down the page, so south is Y increasing

SKIP: {
  my $anum = 'A163534';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my ($prev_x, $prev_y) = $peano->n_to_xy (0);
  my @got;
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $peano->n_to_xy ($n);
    my $dx = $x - $prev_x;
    my $dy = $y - $prev_y;
    push @got, MyOEIS::dxdy_to_direction ($dx, $dy);
    ($prev_x,$prev_y) = ($x,$y);
  }
  is_deeply (\@got, $bvalues, "$anum -- absolute direction");
}

#------------------------------------------------------------------------------
# A163535 -- absolute direction transpose 0=east, 1=south, 2=west, 3=north

SKIP: {
  my $anum = 'A163535';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my ($prev_x, $prev_y) = $peano->n_to_xy (0);
  my @got;
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $peano->n_to_xy ($n);
    my $dx = $x - $prev_x;
    my $dy = $y - $prev_y;
    push @got, MyOEIS::dxdy_to_direction ($dy, $dx);
    ($prev_x,$prev_y) = ($x,$y);
  }
  is_deeply (\@got, $bvalues, "$anum -- absolute direction transpose");
}

#------------------------------------------------------------------------------
# A163536 -- relative direction 0=ahead, 1=right, 2=left
# Y coordinates reckoned down the page
SKIP: {
  my $anum = 'A163536';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my ($n0_x, $n0_y) = $peano->n_to_xy (0);
  my ($p_x, $p_y) = $peano->n_to_xy (1);
  my ($p_dx, $p_dy) = ($p_x - $n0_x, $p_y - $n0_y);
  my @got;
  foreach my $n (2 .. @$bvalues + 1) {
    my ($x, $y) = $peano->n_to_xy ($n);
    my $dx = ($x - $p_x);
    my $dy = ($y - $p_y);

    if ($p_dx) {
      if ($dx) {
        push @got, 0;  # ahead horizontally
      } elsif ($dy == $p_dx) {
        push @got, 1;  # right
      } else {
        push @got, 2;  # left
      }
    } else {
      # p_dy
      if ($dy) {
        push @got, 0;  # ahead horizontally
      } elsif ($dx == $p_dy) {
        push @got, 2;  # left
      } else {
        push @got, 1;  # right
      }
    }
    ### $n
    ### $p_dx
    ### $p_dy
    ### $dx
    ### $dy
    ### is: "$got[-1]   at idx $#got"

    ($p_dx,$p_dy) = ($dx,$dy);
    ($p_x,$p_y) = ($x,$y);
  }
  is_deeply (\@got, $bvalues, "$anum -- relative direction");
}

#------------------------------------------------------------------------------
# A163537 -- relative direction 0=ahead, 1=right, 2=left
# Y coordinates reckoned down the page

sub transpose {
  my ($x, $y) = @_;
  return ($y, $x);
}
SKIP: {
  my $anum = 'A163537';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my ($n0_x, $n0_y) = transpose ($peano->n_to_xy (0));
  my ($p_x, $p_y) = transpose ($peano->n_to_xy (1));
  my ($p_dx, $p_dy) = ($p_x - $n0_x, $p_y - $n0_y);
  my @got;
  foreach my $n (2 .. @$bvalues + 1) {
    my ($x, $y) = transpose ($peano->n_to_xy ($n));
    my $dx = ($x - $p_x);
    my $dy = ($y - $p_y);

    if ($p_dx) {
      if ($dx) {
        push @got, 0;  # ahead horizontally
      } elsif ($dy == $p_dx) {
        push @got, 1;  # right
      } else {
        push @got, 2;  # left
      }
    } else {
      # p_dy
      if ($dy) {
        push @got, 0;  # ahead horizontally
      } elsif ($dx == $p_dy) {
        push @got, 2;  # left
      } else {
        push @got, 1;  # right
      }
    }
    ### $n
    ### $p_dx
    ### $p_dy
    ### $dx
    ### $dy
    ### is: "$got[-1]   at idx $#got"

    ($p_dx,$p_dy) = ($dx,$dy);
    ($p_x,$p_y) = ($x,$y);
  }
  is_deeply (\@got, $bvalues, "$anum -- relative direction tranposed");
}

#------------------------------------------------------------------------------
# A163480 -- row at Y=0
SKIP: {
  my $anum = 'A163480';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $x (0 .. $#$bvalues) {
    push @got, $peano->xy_to_n ($x, 0);
  }
  is_deeply (\@got, $bvalues, "$anum -- row at Y=0");
}

#------------------------------------------------------------------------------
# A163481 -- column at X=0
SKIP: {
  my $anum = 'A163481';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $y (0 .. $#$bvalues) {
    push @got, $peano->xy_to_n (0, $y);
  }
  is_deeply (\@got, $bvalues, "$anum -- column X=0");
}

exit 0;
