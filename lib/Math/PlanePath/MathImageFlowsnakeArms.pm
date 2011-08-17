# Copyright 2011 Kevin Ryde

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


# math-image --path=MathImageFlowsnakeArms --lines --scale=20
# math-image --path=MathImageFlowsnakeArms --all --output=numbers


package Math::PlanePath::MathImageFlowsnakeArms;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 67;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::Flowsnake;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 3) { $arms = 3; }
  $self->{'arms'} = $arms;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### Flowsnake n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my $arms = $self->{'arms'};
  my $rot = ($n % 3);
  $n += ($arms-1);
  $n = int($n/3);

  my ($x,$y) = Math::PlanePath::Flowsnake->n_to_xy ($n + $frac);
  if ($rot == 1) {
    ($x,$y) = (($x+3*$y)/-2,  # rotate +120
               ($x-$y)/2);
  } elsif ($rot == 2) {
    ($x,$y) = ((3*$y-$x)/2,   # rotate -120
               ($x+$y)/-2);
  }
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  my $n;
  ($x,$y) = (-$y,$x);
  foreach my $mod (-3, -2, -1, 0) {
    ($x,$y) = ($y,-$x);
    my $m = Math::PlanePath::Flowsnake->xy_to_n($x,$y);
    if (defined $m) {
      $m = 4*$m + $mod;
      if (! defined $n || $m < $n) {
        $n = $m;
      }
    }
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### Flowsnake rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my ($n_lo,$n_hi) = Math::PlanePath::Flowsnake->rect_to_n_range($x1,$y1, $x2,$y2);
  if ($n_lo) {
    $n_lo -= 1;
  }
  return (4*$n_lo, 4*$n_hi);
}

1;
__END__
