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


# math-image --path=MathImageCornerReplicate --lines --scale=10
# math-image --path=MathImageCornerReplicate --all --output=numbers_dash --size=80x50

package Math::PlanePath::MathImageCornerReplicate;
use 5.004;
use strict;
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 69;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;


# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

my @digit_to_x = (0,0,1,1);
my @digit_to_y = (0,1,1,0);

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageCornerReplicate n_to_xy(): $n

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

  my $x = 0;
  my $y = 0;
  my $len = 1;

  while ($n) {
    my $digit = $n % 4;
    $n = int($n/4);
    ### at: "$x,$y"
    ### $digit

    $x += $digit_to_x[$digit] * $len;
    $y += $digit_to_y[$digit] * $len;
    $len *= 2;
  }

  ### final: "$x,$y"
  return ($x,$y);
}

# (x mod 2) + 2*(y mod 2)
#
#  2 3    1 2
#  0 1    0 3
#
my @mod_to_digit = (0,3,1,2);

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### CornerReplicate xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  my ($len,$level_limit);
  {
    my $xa = abs($x);
    my $ya = abs($x);
    ($len,$level_limit) = _round_down_pow (2*($xa > $ya ? $xa : $ya) || 1, 2);
    ### $level_limit
    ### $len
  }
  $level_limit += 2;
  if (_is_infinite($level_limit)) {
    return $level_limit;
  }

  my $n = 0;
  my $power = 1;
  while ($x != 0 || $y != 0) {
    if ($level_limit-- < 0) {
      ### oops, level limit reached ...
      return undef;
    }
    my $m = ($x % 2) + 2*($y % 2);
    my $digit = $mod_to_digit[$m];
    ### at: "$x,$y  m=$m digit=$digit"

    $x -= $digit_to_x[$digit];
    $y -= $digit_to_y[$digit];
    ### subtract: "$digit_to_x[$digit],$digit_to_y[$digit] to $x,$y"

    ### assert: $x % 2 == 0
    ### assert: $y % 2 == 0
    $x /= 2;
    $y /= 2;
    $n += $digit * $power;
    $power *= 4;
  }
  return $n;
}

# level   N    Xmax
#   1   4^1-1    1
#   2   4^2-1    1+2
#   3   4^3-1    1+3+4
# X <= 2^0+2^1+...+2^(level-1)
# X <= 2^level - 1
# X+1 <= 2^level
# log2(X+1) <= level
# level = log2(X+1)
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageCornerReplicate rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    return (1,0);
  }

  my $max = ($x2 > $y2 ? $x2 : $y2);
  my $level = ceil(log(($max+1) || 1) / log(2));
  ### $level
  return (0, 4**$level - 1);
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageCornerReplicate -- replicating squares

=head1 SYNOPSIS

 use Math::PlanePath::MathImageCornerReplicate;
 my $path = Math::PlanePath::MathImageCornerReplicate->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This path is a self-similar replicating corner fill,


    21-22 25-26 37-38 41-42       7
     |  |  |  |  |  |  |  |
    20 23-24 27 36 39-40 43       6

    17-18 29-30 33-34 45-46       5
     |  |  |  |  |  |  |  |
    16 19 28 31-32 35 44 47       4

     5--6  9-10 53-54 57-58       3
     |  |  |  |  |  |  |  |
     4  7--8 11 52 55-56 59       2

     1--2 13-14 49-50 61-62       1
     |  |  |  |  |  |  |  |
     0  3 12 15 48 51 60 63   <- Y=0

     ^
    X=0 1  2  3  4  5  6  7

The base shape is the initial N=0 to N=3 section,

   1  2
   0  3

It then repeats as 2x2 blocks arranged in the same pattern, then 4x4 blocks,
etc.

=head2 Level Ranges

A given replication extends to

    Nlevel = 4^level - 1
    - (2^level - 1) <= X <= (2^level - 1)
    - (2^level - 1) <= Y <= (2^level - 1)

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageCornerReplicate-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoCurve>

=cut
