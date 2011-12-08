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


package Math::PlanePath::MathImageStaircaseAlternating;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 83;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;



use constant x_negative => 0;
use constant y_negative => 0;

# 5-2=3
# 25-14=11
# 61-42=19

# [ 0, 1, 2, 3 ]
# [ 0, 6, 26, 60 ]

# [ 0, 1, 2, 3 ]
# [ 1, 13, 41, 85 ]
# N = (8 d^2 + 4 d + 1)
#   = (8*$d**2 + 4*$d + 1)
#   = ((8*$d + 4)*$d + 1)
# d = -1/4 + sqrt(1/8 * $n + -1/16)
#   = (-1 + 4*sqrt(1/8 * $n + -1/16)) / 4
#   = (-1 + sqrt(2*$n - 1)) / 4

# [ 0, 1, 2 ]
# [ 5, 25, 61 ]
# N = (8 d^2 + 12 d + 5)
#   = (8*$d**2 + 12*$d + 5)
#   = ((8*$d + 12)*$d + 5)
#
# [ 0, 1, 2, 3 ]
# [ 2,14,42,86 ]
# N = (8 d^2 + 4 d + 2)
#   = (8*$d**2 + 4*$d + 2)
#   = ((8*$d + 4)*$d + 2)


sub n_to_xy {
  my ($self, $n) = @_;
  #### MathImageStaircaseAlternating n_to_xy: $n

  if (2*$n < 1) { return; }

  my $d = int ((-1 + sqrt(2*int($n)-1)) / 4);
  #### $d
  #### d frac: ((-1 + sqrt(2*int($n)-1)) / 4)
  #### base: ((8*$d + 4)*$d + 1)

  $n -= ((8*$d + 4)*$d + 1);
  ### rem: $n

  if ($n < 1) {
    ### initial horizontal ...
    return ($n + 4*$d,
            0);
  }
  $n -= 1;
  ### $n

  if ($n < 8*$d+3) {
    ### upwards diagonal: $n

    my $int = int($n);
    my $frac = $n - $int;
    my $r = int($int/2);
    my $x = 4*$d + 1 - $r;
    if ($int % 2) {
      ### horizontal ...
      return (-$frac + $x,
              $r + 1);
    } else {
      ### vertical ...
      return ($x,
              $frac + $r);
    }
  }
  $n -= 8*$d+3;

  if ($n < 1) {
    ### vertical single ...
    return (0,
            $n + 4*$d + 2);
  }
  $n -= 1;

  ### downwards diagonal: $n

  my $int = int($n);
  my $frac = $n - $int;
  my $r = int($int/2);
  my $y = 4*$d + 3 - $r;
  ### $r
  ### $y

  if ($int % 2) {
    ### vertical ...
    return ($r+1,
            $frac + $y);
  } else {
    ### horizontal ...
    return (-$frac + $r,
            $y);
  }
}


#         62--63
#          |   |
#         61  64--65
#          |       |
#         60--59  66--67
#              |
#             58  57  68
#
#  7      26--27  56      70
#          |   |
#  6      25  28--29  54      72
#          |       |
#  5      24--23  30--31  52      74
#              |       |
#  4       .  22--21  32--33  50      76
#                  |       |
#  3       6-- 7  20--19  34--35  48.-47  78
#          |   |       |       |       |
#  2       5   8-- 9  18--17  36--37  46--45  80--81
#          |       |       |       |       |       |
#  1       4-- 3  10--11  16--15  38--39  44--43  82--83
#              |       |       |       |       |       |
# y=0 ->   1-- 2   .  12--13--14   .  40--41--42   .  84--85--86
#
#          ^
#         x=0  1   2   3   4   5   6   7   8   9
#

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MathImageStaircaseAlternating xy_to_n(): "$x,$y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }

  my $d = int(($x + $y + 1) / 2);
  ### $d

  if ($d == 0) {
    return ($d,$d);
  }

  if ($d % 2) {
    ### diagonal upwards ...

    # [ 1,3,5 ]
    # [ 1,13,41]
    # N = (2 d^2 - 2 d + 1)
    #   = (2*$d**2 - 2*$d + 1)
    #   = ((2*$d - 2)*$d + 1)

    my $n = $y+2*$d-$x;
    if ($n == 0) {
      return undef;
    }
    return ((2*$d - 2)*$d + 1) + $n;
  } else {
    ### diagonal downwards ...

    # [ 2,4,6 ]
    # [ 5,25,61]
    # N = (2 d^2 - 2 d + 1)
    #   = (2*$d**2 - 2*$d + 1)
    #   = ((2*$d - 2)*$d + 1)

    my $n = $x+2*$d-$y;
    if ($n == 0) {
      return undef;
    }
    return ((2*$d - 2)*$d + 1) + $n;
  }
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageStaircaseAlternating rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }  # x2 > x1
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }  # y2 > y1
  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);   # nothing in first quadrant
  }

  $x2 += $y2 + 2;
  return (1,
          $x2*($x2+1)/2);



  if ($x1 < 0) { $x1 *= 0; }
  if ($y1 < 0) { $y1 *= 0; }
  my $y_min = $y1;

  if ((($x1 ^ $y1) & 1) && $y1 < $y2) {  # y2==y_max
    $y1++;
    ### y1 inc: $y1
  }
  if (! (($x2 ^ $y2) & 1) && $y2 > $y_min) {
    $y2--;
    ### y2 dec: $y2
  }
  return ($self->xy_to_n($x1,$y1),
          $self->xy_to_n($x2,$y2));
}

1;
__END__

=for stopwords SquareSpiral eg MathImageStaircaseAlternating PlanePath Ryde Math-PlanePath HexSpiralSkewed ascii Legendre's

=head1 NAME

Math::PlanePath::MathImageStaircaseAlternating -- integer points in stair-step diagonal stripes

=head1 SYNOPSIS

 use Math::PlanePath::MathImageStaircaseAlternating;
 my $path = Math::PlanePath::MathImageStaircaseAlternating->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a staircase pattern down from the Y axis to the X,

     7      26--27
             |   |
     6      25  28--29
             |       |
     5      24--23  30--31
                 |       |
     4       .  22--21  32--33
                     |       |
     3       6-- 7  20--19  34--35   ..-47
             |   |       |       |       |
     2       5   8-- 9  18--17  36--37  46--45
             |       |       |       |       |
     1       4-- 3  10--11  16--15  38--39  44--43
                 |       |       |       |       |
    y=0 ->   1-- 2   .  12--13--14   .  40--41--42

             ^  
            x=0  1   2   3   4   5   6   7   8   9

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageStaircaseAlternating-E<gt>new ()>

Create and return a new staircase path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Staircase>,
L<Math::PlanePath::DiagonalsAlternating>

=cut


# Local variables:
# compile-command: "math-image --path=MathImageStaircaseAlternating --lines --scale=20"
# End:
#
# math-image --path=MathImageStaircaseAlternating --all --output=numbers_dash --size=70x30
