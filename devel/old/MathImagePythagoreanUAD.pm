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


# math-image --path=MathImagePythagoreanUAD --lines --scale=200

# Breadth-first advances $x slowly in the worst case


package Math::PlanePath::MathImagePythagoreanUAD;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);
use Math::Libm 'hypot';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 56;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

my @uad = (
           [ 1,-2,2,   2,-1,2,   2,-2,3],  # U
           [ 1, 2,2,   2, 1,2,   2,2,3 ],  # A
           [-1, 2,2,  -2, 1,2,  -2,2,3 ],  # D
          );

sub n_to_xy {
  my ($self, $n) = @_;
  ### PythagoreanUAD n_to_xy(): $n
  return if $n < 1;

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }

  my $x = 3;
  my $y = 4;
  my $z = 5;

  my $h = 2*($n-1)+1;
  my $level = int(log($h)/log(3));
  my $range = 3**$level;
  my $base = ($range - 1)/2 + 1;
  my $rem = $n - $base;

  if ($rem < 0) {
    $rem += $range/3;
    $level--;
    $range /= 3;
  }
  if ($rem >= $range) {
    $rem -= $range;
    $level++;
    $range *= 3;
  }

  ### $n
  ### $h
  ### $level
  ### $range
  ### $base
  ### $rem

  my @digits;
  while ($level--) {
    push @digits, $rem%3;
    $rem = int($rem/3);
  }
  ### @digits;

  foreach my $digit (reverse @digits) {
    ### at: "$x, $y, $z   digit $digit"
    my $aref = $uad[$digit];
    ($x, $y, $z) = ($x * $aref->[0]
                    + $y * $aref->[1]
                    + $z * $aref->[2],

                    $x * $aref->[3]
                    + $y * $aref->[4]
                    + $z * $aref->[5],

                    $x * $aref->[6]
                    + $y * $aref->[7]
                    + $z * $aref->[8]);
  }

  ### final: "$x, $y, $z"
  return (max($x,$y), min($x,$y));
  return $x,$y;
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  return undef;
  ### PythagoreanUAD xy_to_n(): "$x, $y"
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### rect_to_n_range()

  $x1 = floor($x1 + 0.5);
  $y1 = floor($y1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### $x2
  ### $y2

  if ($x2 <= 3 || $y2 <= 0) {
    return (1,0);
  }

  my $x_level;
  if ($x2 <= 4) {
    $x_level = 0;
  } else {
    $x_level = int (-1/6 + sqrt(2/3 * $x2 + 1/36));
  }

  my $y_level;
  if ($y2 <= 3) {
    $y_level = 0;
  } else {
    $y_level = int(($y2-1)/2);
  }

  my $level = min($x_level,$y_level);
  ### $x_level
  ### $y_level
  ### pow: (3**$level-1)/2
  return (0, (3**$level-1)/2);

  # return (0, $x2*$x2 + 10000);
  # return (0, hypot (max(abs($x1),abs($x2)), max(abs($y1),abs($y2))));
}

1;
__END__

=for stopwords eg Ryde OEIS

=head1 NAME

Math::PlanePath::MathImagePythagoreanUAD -- primitive pythagorean triples by U,A,D

=head1 SYNOPSIS

 use Math::PlanePath::MathImagePythagoreanUAD;
 my $path = Math::PlanePath::MathImagePythagoreanUAD->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This path is the x,y coordinates of primitive Pythagorean triples taken as a
breadth-first traversal of Barning's U/A/D generators.

As a method of visiting all triples near the origin this isn't very
practical, since the UAD tree goes out to very distant points while some
quite close to the origin remain.

In general at tree depth k, which means visiting N=1 through N=(3^k-1)/2,
the smallest x visited is 2*k*(k+1).  So going up to say x=364 requires some
800,000 points, the vast majority of which are out at higher x.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImagePythagoreanUAD-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.  Integer positions are always just 1 apart either
horizontally or vertically, so the effect is that the fraction part appears
either added to or subtracted from X or Y.

=back

=head1 SEE ALSO

L<Math::PlanePath>

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
