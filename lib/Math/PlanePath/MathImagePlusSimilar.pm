# Copyright 2010, 2011 Kevin Ryde

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


# math-image --path=MathImagePlusSimilar --lines --scale=10
# math-image --path=MathImagePlusSimilar --output=numbers

package Math::PlanePath::MathImagePlusSimilar;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use vars '$VERSION', '@ISA';
$VERSION = 65;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;

#     10        7
#         2  8  5  6
#      3  0  1  9
#         4

my @X = (0,1,0,-1,0);
my @Y = (0,0,1,0,-1);
my @oX = (0,2,-1,-2,1);
my @oY = (0,1,2,-1,-2);

sub n_to_xy {
  my ($self, $n) = @_;
  ### PlusSimilar n_to_xy(): $n
  if ($n < 0 || _is_infinite($n)) {
    return;
  }

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }


  my $x = 0;
  my $y = 0;
  my $len_even = 1;
  my $len_odd = 1;
  my $odd = 1;
  while ($n) {
    my $digit = ($n % 5);

    ### even ...
    ### $digit
    $x += $len_even * $X[$digit];
    $y += $len_even * $Y[$digit];
    $len_even *= 5;

    $n = int($n/5) || last;
    $digit = ($n % 5);
    $n = int($n/5);

    ### odd ...
    ### $digit
    $x += $len_odd * $oX[$digit];
    $y += $len_odd * $oY[$digit];
    $len_odd *= 5;
  }

  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  return undef;
  ### PlusSimilar xy_to_n(): "$x, $y"
}

# level 1   s=0            snext=5*s+2
#       3   s=2            base 5  22...
#       5   s=12
#       7   s=62
#       9   s=312
#
# level 2   s=1            snext=5*s+1
#       4   s=6            base 5  11...
#       6   s=31
#       8   s=156
#      10   s=781
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  my $level = 2 * ceil (log(max(36,
                                abs($x1),abs($x2),
                                abs($y1),abs($y2))) / log(6));
  return (0, 5 ** $level - 1);
}

1;
__END__

=for stopwords eg Ryde OEIS

=head1 NAME

Math::PlanePath::MathImagePlusSimilar -- self-similar path traversal

=head1 SYNOPSIS

 use Math::PlanePath::MathImagePlusSimilar;
 my $path = Math::PlanePath::MathImagePlusSimilar->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

                12

            13  10  11       7

                14   2   8   5   6

            17   3   0   1   9                             <-  y=0

        18  15  16   4  22

            19      23  20  21

                        24

      x=-4 -3 -2 -1  0  1  2  3  4  5  6  7  8  9 10 11

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImagePlusSimilar-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::ZOrderCurve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

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
