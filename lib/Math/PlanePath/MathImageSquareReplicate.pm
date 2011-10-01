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


# math-image --path=MathImageSquareReplicate --lines --scale=10
# math-image --path=MathImageSquareReplicate --all --output=numbers_dash --size=80x50

package Math::PlanePath::MathImageSquareReplicate;
use 5.004;
use strict;
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 73;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;


# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;

# 4 3 2
# 5 0 1
# 6 7 8

my @digit_to_x = (0,1, 1,0,-1, -1, -1,0,1);
my @digit_to_y = (0,0, 1,1,1,  0, -1,-1,-1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageSquareReplicate n_to_xy(): $n

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
    my $digit = $n % 9;
    $n = int($n/9);
    ### at: "$x,$y"
    ### $digit

    $x += $digit_to_x[$digit] * $len;
    $y += $digit_to_y[$digit] * $len;
    $len *= 3;
  }

  ### final: "$x,$y"
  return ($x,$y);
}

# (x mod 3) + 3*(y mod 3)
#
#  5 3 4   4 3 2
#  2 0 1   5 0 1
#  8 6 7   6 7 8
#
my @mod_to_digit = (0,1,5, 3,2,4, 7,8,6);

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### SquareReplicate xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  my ($len,$level_limit);
  {
    my $xa = abs($x);
    my $ya = abs($x);
    ($len,$level_limit) = _round_down_pow (2*($xa > $ya ? $xa : $ya) || 1, 3);
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
    my $m = ($x % 3) + 3*($y % 3);
    my $digit = $mod_to_digit[$m];
    ### at: "$x,$y  m=$m digit=$digit"

    $x -= $digit_to_x[$digit];
    $y -= $digit_to_y[$digit];
    ### subtract: "$digit_to_x[$digit],$digit_to_y[$digit] to $x,$y"

    ### assert: $x % 3 == 0
    ### assert: $y % 3 == 0
    $x /= 3;
    $y /= 3;
    $n += $digit * $power;
    $power *= 9;
  }
  return $n;
}

# level   N    Xmax
#   1   9^1-1    1
#   2   9^2-1    1+3
#   3   9^3-1    1+3+9
# X <= 3^0+3^1+...+3^level-1
# X <= (3^level - 1)/2
# 2*X+1 <= 3^level
# log3(2*X+1) <= level
# level = log3(2X+1)
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageSquareReplicate rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = abs($x1);
  $y1 = abs($y1);
  $x2 = abs($x2);
  $y2 = abs($y2);
  my $xm = ($x1 > $x2 ? $x1 : $x2);
  my $ym = ($y1 > $y2 ? $y1 : $y2);
  my $max = ($xm > $ym ? $xm : $ym);
  my $level = ceil(log(2*$max+1 || 1) / log(3));
  ### $level
  return (0, 9**$level - 1);
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageSquareReplicate -- replicating squares

=head1 SYNOPSIS

 use Math::PlanePath::MathImageSquareReplicate;
 my $path = Math::PlanePath::MathImageSquareReplicate->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This path is a self-similar replicating square,

    40--39--38  31--30--29  22--21--20         4
     |       |   |       |   |       |
    41  36--37  32  27--28  23  18--19         3
     |           |           |
    42--43--44  33--34--35  24--25--26         2

    49--48--47   4-- 3-- 2  13--12--11         1
     |       |   |       |   |       |
    50  45--46   5   0-- 1  14   9--10     <- Y=0
     |           |           |
    51--52--53   6-- 7-- 8  15--16--17        -1

    58--57--56  67--66--65  76--75--74        -2
     |       |   |       |   |       |
    59  54--55  68  63--64  77  72--73        -3
     |           |           |
    60--61--62  69--70--71  78--79--80        -4

                     ^
    -4  -3  -2  -1  X=0  1   2   3   4

The base shape is the initial N=0 to N=8 section,

   4  3  2
   5  0  1
   6  7  8

It then repeats with 3x3 blocks arranged in the same pattern, then 9x9
blocks, etc.

=head2 Level Ranges

A given replication extends to

    Nlevel = 9^level - 1
    - (3^level - 1) <= X <= (3^level - 1)
    - (3^level - 1) <= Y <= (3^level - 1)

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageSquareReplicate-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoCurve>

=cut
