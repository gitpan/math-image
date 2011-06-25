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


# math-image --path=MathImageGosperSide --lines --scale=10
# math-image --path=MathImageGosperSide --output=numbers

package Math::PlanePath::MathImageGosperSide;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);
use Math::PlanePath::SacksSpiral;

use vars '$VERSION', '@ISA';
$VERSION = 61;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### GosperSide n_to_xy(): $n
  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  my $x;
  my $y = 0;
  { my $whole = int($n);
    $x = $n - $whole;
    $n = $whole;
  }
  my $xend = 2;
  my $yend = 0;

  while ($n) {
    my $digit = ($n % 3);
    $n = int($n/3);
    my $xend_offset = 3*($xend-$yend)/2;   # end and end +60
    my $yend_offset = ($xend+3*$yend)/2;

    ### at: "$x,$y"
    ### $digit
    ### $xend
    ### $yend
    ### $xend_offset
    ### $yend_offset

    if ($digit == 1) {
      ($x,$y) = (($x-3*$y)/2  + $xend,   # rotate +60
                 ($x+$y)/2    + $yend);
    } elsif ($digit == 2) {
      $x += $xend_offset;   # offset and offset +60
      $y += $yend_offset;
    }
    $xend += $xend_offset;   # offset and offset +60
    $yend += $yend_offset;
  }

  ### final: "$x,$y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  ### GosperSide xy_to_n(): "$x, $y"
  return undef;
}

sub _round_up_pow2 {
  my ($x) = @_;
  my $exp = ceil (log(max(1, $x)) / log(2));
  my $pow = 2 ** $exp;
  if ($pow < $x) {
    return (2*$pow, $exp+1)
  } else {
    return ($pow, $exp);
  }
}

# x,y at N=3^level is
#     log(hypot) = 1.7 + 0.9730*(level-1)
#     log(hypot) = .69304 + 0.9730*level
#     0.9730*level = log(hypot) - .69304;
#     level = (log(hypot) - .69304) / 0.9730;
#     level = (log(hypot) - .69304) * 1.027749

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  $y1 *= sqrt(3);
  $y2 *= sqrt(3);
  my ($r_lo, $r_hi) = Math::PlanePath::SacksSpiral::_rect_to_radius_range
    ($x1,$y1, $x2,$y2);
  my $level = ceil (log($r_hi) - .69304) * 1.027749;
  return (0, 3 ** $level - 1);
}

1;
__END__

=for stopwords eg Ryde

=head1 NAME

Math::PlanePath::MathImageGosperSide -- one side of the gosper island

=head1 SYNOPSIS

 use Math::PlanePath::MathImageGosperSide;
 my $path = Math::PlanePath::MathImageGosperSide->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageGosperSide-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::KochCurve>

L<Math::Fractal::Curve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
