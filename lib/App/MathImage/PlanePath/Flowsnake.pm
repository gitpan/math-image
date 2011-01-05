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


# http://kilin.clas.kitasato-u.ac.jp/museum/gosperex/343-024.pdf
# http://web.archive.org/web/20070630031400/http://kilin.u-shizuoka-ken.ac.jp/museum/gosperex/343-024.pdf
#     Variations.
#
#  Martin Gardner, In which "monster" curves force redefinition of the word
#  "curve", Scientific American 235 (December issue), 1976, 124-133.
#

package App::MathImage::PlanePath::Flowsnake;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 39;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant y_negative => 0;

# i=0
#       4-->5-->6      y=2
#       ^       ^
#        \       \
#         3-->2   7    y=1
#            /
#           v
#       0-->1          y=0
#
#     x=0 1 2 3 4 5
#
#
# i=1
#         6<--7        y=3
#         ^
#        /
#       5   2          y=2
#       ^   ^\
#      /   /  v
#     4-->3   1        y=1
#             ^
#            /
#           0          y=0
#
#    -3  -1 0 1
#
# i=2
#       7              y=2
#      /
#     v
#     6   2-->1        y=1
#     ^   ^   ^
#      \   \   \
#       5   3   0      y=0
#       ^   ^
#        \ /
#         4            y=-1
#
#    -5  -3  -1 0
#
#
# i=3
#           1<--0      y=0
#           ^
#          /
#     7   2<--3        y=-1
#      \      ^
#       v      \
#       6<--5<-4       y=-2
#
#    -5  -3  -1 0
#
# i=4
#       0            y=0
#      /
#     v
#     1   3<--4      y=-1
#     ^  /   /
#      \v   v
#       2   5        y=-2
#          /
#         v
#     7---6          y=-3
#
#    -1 0 1 2 3
#
# i=5
#     6<--5<--4      y=1
#     ^      /
#    /      v
#   7   0   3        y=0
#        \  ^
#         v  \
#         1<--2      y=-1
#
#  -2   0 1 2 3
#
my @i_to_x = (0,2,3,1,0,2,4,5,
              0,1,0,-1,-3,-2,-1,1,
              0,-1,-3,-2,-3,-4,-5,-4,
              0,-2,-3,-1,0,-2,-4,-5,
              0,-1,0,1,3,2,1,-1,
              0,1,3,2,3,1,-1,1,
             );
my @i_to_y = (0,0,1,1,2,2,2,1,
              0,1,2,1,1,2,3,3,
              0,1,1,0,-1,0,1,2,
              0,0,-1,-1,-2,-2,-2,-1,
              0,-1,-2,-1,-1,-2,-3,-3,
              0,-1,-1,0,1,1,1,0,
             );
my @i_next = (0, 4, 0, 2, 0, 0, 2,
              0, 4, 0, 2, 0, 0, 2,
             );
my @i_inv = (0,1,0,1,0,0,1,0);

sub n_to_xy {
  my ($self, $n) = @_;
  ### Flowsnake n_to_xy(): $n
  return if $n < 0;

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }

  my (@n);
  my $scale = 1;
  while ($n) {
    push @n, $n % 8; $n = int($n/8);
    $scale *= 3;
  }
  ### @n
  ### $scale

  my $i = 0;
  my $x = 0;
  my $y = 0;
  my $inv = 0;
  while (@n) {
    my $digit = pop @n;
    $scale /= 3;
    ### $i
    ### $digit
    ### $scale
    ### dx dy: ($i_to_x[8*$i + $digit]).' '.($i_to_y[8*$i + $digit])
    ### dx dy: ($i_to_x[8*$i + $digit] * $scale).' '.($i_to_y[8*$i + $digit] * $scale)
    my $offset = $digit;
    if ($inv) { $offset = 7-$offset; }
    $offset += 8*$i;
    $x += $i_to_x[$offset] * $scale;
    $y += $i_to_y[$offset] * $scale + $scale-3;
    $i = $i_next[$i+$digit];
    $inv ^= $i_inv[$digit];
  }

  ### is: "$x,$y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### Flowsnake xy_to_n(): "$x, $y"

  return undef;

  # my $pos = 0;
  # my @x;
  # my @y;
  # while ($x || $y) {
  #   push @x, $x % 7; $x = int($x/7);
  #   push @y, $y % 7; $y = int($y/7);
  # }
  # 
  # my $i = 0;
  # my $xk = 0;
  # my $yk = 0;
  # while (@x) {
  #   {
  #     my $digit = pop @y;
  #     $xk ^= $digit;
  #     if ($yk & 1) {
  #       $digit = 2 - $digit;
  #     }
  #     $n = ($n * 7) + $digit;
  #   }
  #   {
  #     my $digit = pop @x;
  #     $yk ^= $digit;
  #     if ($xk & 1) {
  #       $digit = 2 - $digit;
  #     }
  #     $n = ($n * 7) + $digit;
  #   }
  # }
  # 
  # return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = floor($x1 + 0.5);
  $y1 = floor($y1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    return (-1, 0);
  }

  my $ret = 9;
  while ($x2) {
    $ret *= 2;
    $x2 = int($x2 / 2);
  }
  while ($y2) {
    $ret *= 2;
    $y2 = int($y2 / 2);
  }
  return (0, $ret);
}

1;
__END__

=for stopwords eg Ryde OEIS

=head1 NAME

App::MathImage::PlanePath::Flowsnake -- self-similar path traversal

=head1 SYNOPSIS

 use App::MathImage::PlanePath::Flowsnake;
 my $path = App::MathImage::PlanePath::Flowsnake->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path ...

=head1 FUNCTIONS

=over 4

=item C<$path = App::MathImage::PlanePath::Flowsnake-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.  Integer positions are always just 1 apart either
horizontally or vertically, so the effect is that the fraction part appears
either added to or subtracted from X or Y.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square an C<$x,$y> within that square
returns N.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HilbertCurve>
L<Math::PlanePath::PeanoCurve>
L<Math::PlanePath::ZOrderCurve>

Guiseppe Peano, "Sur une courbe, qui remplit toute une aire plane",
Mathematische Annalen, volume 36, number 1, 1890, p157-160

    DOI 10.1007/BF01199438
    http://www.springerlink.com/content/w232301n53960133/

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Math-Image is Copyright 2010, 2011 Kevin Ryde

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
