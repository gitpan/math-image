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
$VERSION = 38;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### Flowsnake n_to_xy(): $n
  return if $n < 0;

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }

  my $x = 0;
  my $y = 0;
  my $comp = 0;
  my $power = 1;
  for (;;) {
    ### $n
    ### $power
    {
      my $digit = $n % 3;
      if ($digit & 1) {
        $y = $comp - $y;
      }
      $x += $power * $digit;
    }
    $n = int($n/3) || last;
    $comp = (3*$comp + 2);
    {
      my $digit = $n % 3;
      if ($digit & 1) {
        $x = $comp - $x;
      }
      $y += $power * $digit;
    }
    $n = int($n/3) || last;
    $power *= 3;
  }
  return ($x, $y);


  # my (@n);
  # while ($n) {
  #   push @n, $n % 3; $n = int($n/3);
  #   push @n, $n % 3; $n = int($n/3);
  # }
  #
  # my $x = 0;
  # my $y = 0;
  # my $xk = 0;
  # my $yk = 0;
  # while (@n) {
  #   {
  #     my $digit = pop @n;
  #     $xk ^= $digit;
  #     $y = 3*$y + ($yk & 1 ? 2-$digit : $digit);
  #   }
  #   {
  #     my $digit = pop @n;
  #     $yk ^= $digit;
  #     $x = 3*$x + ($xk & 1 ? 2-$digit : $digit);
  #   }
  # }
  #
  # ### is: "$x,$y"
  # return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### Flowsnake xy_to_n(): "$x, $y"

  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  if ($x < 0 || $y < 0) {
    return undef;
  }

  my $power = 1;
  my $comp = 0;
  my $xn = my $yn = ($x & 0); # inherit
  while ($x || $y) {
    {
      my $digit = $x % 3;
      if ($digit & 1) {
        $yn = $comp - $yn;
      }
      $xn += $power * $digit;
      $x = int($x/3);
    }
    $comp = (3*$comp + 2);
    {
      my $digit = $y % 3;
      if ($digit & 1) {
        $xn = $comp - $xn;
      }
      $yn += $power * $digit;
      $y = int($y/3);
    }
    $power *= 3;
  }

  my $n = ($x & 0); # inherit
  $power = 1;
  while ($xn || $yn) {
    $n += ($xn % 3) * $power;
    $power *= 3;
    $n += ($yn % 3) * $power;
    $power *= 3;
    $xn = int($xn/3);
    $yn = int($yn/3);
  }
  return $n;




  # my $pos = 0;
  # my @x;
  # my @y;
  # while ($x || $y) {
  #   push @x, $x % 3; $x = int($x/3);
  #   push @y, $y % 3; $y = int($y/3);
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
  #     $n = ($n * 3) + $digit;
  #   }
  #   {
  #     my $digit = pop @x;
  #     $yk ^= $digit;
  #     if ($xk & 1) {
  #       $digit = 2 - $digit;
  #     }
  #     $n = ($n * 3) + $digit;
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
    $ret *= 3;
    $x2 = int($x2 / 3);
  }
  while ($y2) {
    $ret *= 3;
    $y2 = int($y2 / 3);
  }
  return (0, $ret);
}

1;
__END__

=for stopwords Guiseppe Peano Peano's there'll HilbertCurve eg Sur une courbe qui remplit toute aire Mathematische Annalen Ryde OEIS trit

=head1 NAME

App::MathImage::PlanePath::Flowsnake -- self-similar quadrant traversal

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
