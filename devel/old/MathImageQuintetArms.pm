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


# math-image --path=MathImageQuintetArms --lines --scale=20
# math-image --path=MathImageQuintetArms --all --output=numbers


package Math::PlanePath::MathImageQuintetArms;
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

use Math::PlanePath::MathImageQuintetCurve;

use constant n_start => 0;
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 4) { $arms = 4; }
  $self->{'arms'} = $arms;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### QuintetCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  {
    my $int = int($n);
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my $arms = $self->{'arms'};
  my $rot = ($n % $arms);
  ### $arms
  ### $rot
  $n += ($arms-1);
  $n = int($n/$arms);

  my ($x,$y) = Math::PlanePath::MathImageQuintetCurve->n_to_xy($n);
  if ($rot & 2) {
    $x = -$x;
    $y = -$y;
  }
  if ($rot & 1) {
    ($x,$y) = (-$y,$x);
  }
  # if ($rot >= 2) {
  #   $y -= 1;
  # }
  # if ($rot == 1 || $rot == 2) {
  #   $x -= 1;
  # }
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  my $n;
  ($x,$y) = (-$y,$x);
  my $arms = $self->{'arms'};
  foreach my $mod (-$arms+1 .. 0) {
    ($x,$y) = ($y,-$x);
    my $m = Math::PlanePath::MathImageQuintetCurve->xy_to_n($x,$y);
    if (defined $m) {
      $m = $arms*$m + $mod;
      if (! defined $n || $m < $n) {
        $n = $m;
      }
    }
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### QuintetCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my ($n_lo,$n_hi) = Math::PlanePath::MathImageQuintetCurve->rect_to_n_range($x1,$y1, $x2,$y2);
  if ($n_lo) {
    $n_lo -= 1;
  }
  return (4*$n_lo, 4*$n_hi);
}

1;
__END__
