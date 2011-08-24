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


# math-image --path=MathImageComplexIplus1 --lines --scale=10
# math-image --path=MathImageComplexIplus1 --all --output=numbers_dash --size=80x50

package Math::PlanePath::MathImageComplexIplus1;
use 5.004;
use strict;
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 68;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

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
  elsif ($arms > 2) { $arms = 2; }
  $self->{'arms'} = $arms;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageComplexIplus1 n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  {
    my $int = int($n);
    ### $int
    ### $n
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  ### $rot
  # $n += ($arms-1);

  my $x = 0;
  my $y;
  my $dx;
  my $dy = 0;

  my $arms = $self->{'arms'};
  ### $arms
  if ($n % $arms) {
    $y = 1;
    $dx = -1;
  } else {
    $y = 0;
    $dx = 1;
  }
  $n = int($n/$arms);

  while ($n) {
    my $digit = $n % 2;
    $n = int($n/2);
    ### at: "$x,$y"
    ### $digit

    $x += $dx * $digit;
    $y += $dy * $digit;
    ($dx,$dy) = ($dx-$dy, $dx+$dy);  # *(i+1)
  }

  ### final: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ComplexIplus1 xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if (_is_infinite($x)) { return ($x); }
  if (_is_infinite($y)) { return ($y); }

  my $radix = $self->{'radix'};
  my $n = 0;
  my $power = 1;
  while ($x || $y) {
    ### at: "$x,$y  digit ".($x % $radix)
    if (($x+$y) % 2) {
      $x -= 1;
      $n += $power;
    }

    # divide i+1 = mul (i-1)/2
    ($x,$y) = (($y-$x)/2, ($y+$x)/-2);
    $power *= $radix;
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageComplexIplus1 rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = abs($x1);
  $y1 = abs($y1);
  $x2 = abs($x2);
  $y2 = abs($y2);
  my $xm = ($x1 > $x2 ? $x1 : $x2);
  my $ym = ($y1 > $y2 ? $y1 : $y2);
  my $max = ($xm > $ym ? $xm : $ym);
  my $level = 2*ceil(log($max || 1) / log(2)) + 3;
  ### $level
  return (0, $self->{'arms'} * 2**$level - 1);
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageComplexIplus1 -- points in quater-imaginary base 2i

=head1 SYNOPSIS

 use Math::PlanePath::MathImageComplexIplus1;
 my $path = Math::PlanePath::MathImageComplexIplus1->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This is 
               ^
    -2   -1   X=0   1    2    3    4    5

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageComplexIplus1-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>

=cut
