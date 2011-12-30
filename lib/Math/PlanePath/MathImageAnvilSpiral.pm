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


# math-image --path=MathImageAnvilSpiral --all --output=numbers_dash

package Math::PlanePath::MathImageAnvilSpiral;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 88;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;



# pentagonal N = (3k-1)*k/2
# preceding
# Np = (3k-1)*k/2 - 1
#    = (3k^2 - k - 2)/2
#    = (3k+2)(k-1)/2
#      

# use Math::PlanePath::SquareSpiral;
# *parameter_info_array = \&Math::PlanePath::SquareSpiral::parameter_info_array;

sub new {
  my $self = shift->SUPER::new (@_);
  $self->{'wider'} ||= 0;  # default
  return $self;
}

# [1,2,3,4],[1,12,35,70]
# N = (6 d^2 - 7 d + 2)
#   = (6*$d**2 - 7*$d + 2)
#   = ((6*$d - 7)*$d + 2)
# d = 7/12 + sqrt(1/6 * $n + 1/144)
#   = (7 + 12*sqrt(1/6 * $n + 1/144))/12
#   = (7 + sqrt(144/6*$n + 1))/12
#   = (7 + sqrt(24*$n + 1))/12
#
sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageAnvilSpiral n_to_xy(): $n

  if ($n < 1) { return; }
  my $w = $self->{'wider'};
  my $w_right = int($w/2);
  my $w_left = $w - $w_right;
  ### $w
  ### $w_left
  ### $w_right

  if ($n < $w+1) {
    ### centre horizontal
    return ($n-1 - $w_left,  # n=1 at $w_left
            0);
  }

  my $d = int((sqrt(int(24*$n) + ($w+2)*$w + 1) +7 - $w) / 12);
  $n -= ((6*$d - 7)*$d + 2);

  ### $d
  ### base: ((6*$d - 7)*$d + 2)
  ### remainder: $n

  if ($n <= 5*$d+$w-1) {
    if ($n <= $d) {
      ### upper right slope ...
      return ($n + $d - $w_left - 1,
              $n);
    } else {
      ### top ...
      return (-$n + 3*$d - $w_left - 1,
              $d);
    }
  }

  $n -= 7*$d + 2*$w - 1;

  if ($n < 0) {
    ### left slopes: $n
    return (-abs($n+$d) - $d - $w_left,
            -$n - $d);
  }

  $n -= 4*$d;
  if ($n < 0) {
    ### bottom ...
    return ($n + 2*$d + $w_right,
            -$d);
  } else {
    ### right lower ...
    return (-$n + 2*$d + $w_right,
            $n - $d + 0);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  my $w = $self->{'wider'};
  my $w_right = int($w/2);
  my $w_left = $w - $w_right;

  my $abs_y = abs($y);
  if ($x >= 2*$abs_y) {
    ### right slopes ...
    my $d = $x - $abs_y;
    return ((6*$d + 5)*$d + 1
            + $y);
  }

  if ($x <= -2*$abs_y) {
    ### left slopes ...
    my $d = $x + $abs_y; # negative
    return ((6*$d + 1)*$d + 1
            - $y);
  }

  if ($y > 0) {
    ### top horizontal ...
    return ((6*$y - 4)*$y + 1
            - $x - $w_right);
  } else {
    ### bottom horizontal ...
    return ((6*$y - 2)*$y + 1
            + $x + $w_left);
  }
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageAnvilSpiral rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my $w = $self->{'wider'};
  my $w_right = int($w/2);
  my $w_left = $w - $w_right;

  $x1 = _round_nearest($x1);
  $x2 = _round_nearest($x2);
  $y1 = _round_nearest($y1);
  $y2 = _round_nearest($y2);

  my $x_zero = (($x1<0) != ($x2<0));
  my $y_zero = (($x1<0) != ($x2<0));

  if ($x1 < 0) { $x1 = -$x1 - 1; }
  if ($x2 < 0) { $x2 = -$x2 - 1; }
  $y1 = abs($x1);
  $y2 = abs($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x_zero) { $x1 = 0; }
  if ($y_zero) { $y1 = 0; }

  ### abs: "$x1,$y1  $x2,$y2"

  my $d1 = ($x1 > 2*$y1
            ? $x1-$y1  # first octant slope
            : $y1);
  my $d2 = 2 + ($x2 > 2*$y2
                ? $x2-$y2  # first octant slope
                : $y2);
  ### $d1
  ### $d2
  ### d2 first oct: $x2 > 2*$y2

  if ($d1 == 0) { $d1 = 1; }

  return (((6*$d1 - 7)*$d1 + 2),
          ((6*$d2 - 7)*$d2 + 2));
}

1;
__END__

=for stopwords MathImageAnvilSpiral HexSpiral SquareSpiral DiamondSpiral PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageAnvilSpiral -- integer points around an "anvil" shape

=head1 SYNOPSIS

 use Math::PlanePath::MathImageAnvilSpiral;
 my $path = Math::PlanePath::MathImageAnvilSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a spiral around an anvil shape.

                           ...-78-77-76-75-74       4
                                          /
    49-48-47-46-45-44-43-42-41-40-39-38 73          3
      \                             /  /
       50 21-20-19-18-17-16-15-14 37 72             2
         \  \                 /  /  /
          51 22  5--4--3--2 13 36 71                1
            \  \  \     /  /  /  /
             52 23  6  1 12 35 70              <- Y=0
            /  /  /        \  \  \
          53 24  7--8--9-10-11 34 69               -1
         /  /                    \  \
       54 25-26-27-28-29-30-31-32-33 68            -2
      /                                \
    55-56-57-58-59-60-61-62-63-64-65-66-67         -3

                       ^
    -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7

The pentagonal numbers 1,5,12,22,etc, P(k) = (3k-1)*k/2 fall alternately on
the X axis XE<gt>0, and on the Y=1 horizontal XE<lt>0.

Those pentagonals are always composites, from the factorization shown, and
as noted in L<Math::PlanePath::PyramidRows/Step 3 Pentagonals>, the
immediately preceding P(k)-1 and P(k)-2 are also composites.  So if plotting
the primes on the spiral there's a 3-high horizontal blank line at Y=0,-1,-2
XE<gt>0 and Y=1,2,3 XE<lt>0 (after the first couple of k's).

Each loop around the spiral is 12 longer than the preceding.  Because this
is 4* more than the step=3 PyramidRows, straight lines on such a PyramidRows
are straight lines here, but split into two parts.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageAnvilSpiral-E<gt>new ()>

Create and return a new hexagon spiral object.  An optional C<wider>
parameter widens the spiral path, it defaults to 0 which is no widening.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::OctagramSpiral>,
L<Math::PlanePath::HexSpiral>

=cut
