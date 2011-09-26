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
$VERSION = 72;

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

  my $x = my $y = ($n & 0);  # inherit bignum 0
  my $len = $x + 1;          # inherit bignum 1

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

  my ($len, $level) = _round_down_pow (($x > $y ? $x : $y) || 1,
                                       2);
  if (_is_infinite($level)) {
    return $level;
  }

  my $n = ($x & 0 & $y);  # inherit bignum 0
  while ($level-- >= 0) {
    ### $level
    ### $len
    ### n: sprintf '0x%X', $n
    ### $x
    ### $y

    $n *= 4;
    if ($x < $len) {
      # left
      if ($y >= $len) {
        $n += 1;  # top left
        $y -= $len;
      }
    } else {
      # right
      $x -= $len;
      if ($y < $len) {
        $n += 3;  # bottom right
      } else {
        $n += 2;  # top right
        $y -= $len;
      }
    }
    $len /= 2;
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageCornerReplicate rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### rect: "X = $x1 to $x2, Y = $y1 to $y2"

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0); # rectangle outside first quadrant
  }

  my ($len, $level) = _round_down_pow (($x2 > $y2 ? $x2 : $y2),
                                       2);
  ### $len
  ### $level
  if (_is_infinite($level)) {
    return (0,$level);
  }

  my $n_min = my $n_max
    = my $x_min = my $y_min
      = my $x_max = my $y_max
        = ($x1 & 0 & $x2 & $y1 & $y2); # inherit bignum 0

  my $i_min = my $i_max = ($level & 1) << 2;
  while ($level-- >= 0) {
    ### $len
    ### $level
    {
      my $x_cmp = $x_max + $len;
      my $y_cmp = $y_max + $len;

      my $digit;
      if ($x2 < $x_cmp) {
        # left only
        if ($y2 < $y_cmp) {
          $digit = 0;  # bottom left
        } else {
          $digit = 1;  # top left
          $y_max += $len;
        }
      } else {
        # right included
        $x_max += $len;
        if ($y1 >= $y_cmp) {
          # top only
          $digit = 2;  # top right
          $y_max += $len;
        } else {
          # bottom included
          $digit = 3;  # bottom right
        }
      }

      $n_max = 4*$n_max + $digit;
      ### max ...
      ### $digit
      ### n_max: sprintf "%#X", $n_max
      ### $x_max
      ### $y_max
      ### len:  sprintf "%#X", $len
    }
    {
      my $x_cmp = $x_min + $len;
      my $y_cmp = $y_min + $len;

      my $digit;
      if ($x1 >= $x_cmp) {
        # right only
        $x_min += $len;
        if ($y2 < $y_cmp) {
          # bottom only
          $digit = 3;  # bottom right
        } else {
          # top included
          $digit = 2;  # top right
          $y_min += $len;
        }
      } else {
        # left included
        if ($y1 >= $y_cmp) {
          # top only
          $digit = 1;  # top left
          $y_min += $len;
        } else {
          # bottom included
          $digit = 0;  # bottom left
        }
      }

      $n_min = 4*$n_min + $digit;
      ### min ...
      ### $digit
      ### n_min: sprintf "%#X", $n_min
      ### $x_min
      ### $y_min
      ### len:  sprintf "%#X", $len
    }
    $len /= 2;
  }

  return ($n_min, $n_max);
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
L<Math::PlanePath::HilbertCurve>

=cut
