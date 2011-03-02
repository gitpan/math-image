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


package Math::PlanePath::MathImageHypot;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use Math::Libm 'hypot', 'M_PI';
use POSIX 'floor';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 46;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

my @n_to_x;
my @n_to_y;
my %xy_to_n;
my %hypot_to_n;
my $next_hypot = 0;
my $next_n = 1;
my @y_next_x = (0);
my @y_next_hypot = (0);

sub _extend {
  ### _extend(): "next_n=$next_n"
  my $y = 0;
  my $x = $y_next_x[0];
  my $hypot = $y_next_hypot[0];
  for (my $i = 1; $i < @y_next_x; $i++) {
    if ($hypot > $y_next_hypot[$i]) {
      $y = $i;
      $hypot = $y_next_hypot[$i]
    }
  }
  if ($y == $#y_next_x) {
    $y_next_x[$y+1] = 0;
    $y_next_hypot[$y+1] = ($y+1)**2;
  }

  $x = $y_next_x[$y];
  $n_to_x[$next_n] = $x;
  $n_to_y[$next_n] = $y;
  $xy_to_n{"$x,$y"} = $next_n++;

  $y_next_x[$y]++;
  $y_next_hypot[$y] = $y*$y + $y_next_x[$y]**2;
  ### this: "$x,$y hypot=$hypot n=".($next_n-1)
  ### @y_next_x
  ### @y_next_hypot
}

sub n_to_xy {
  my ($self, $n) = @_;

  if ($n < 1
      || $n-1 == $n) {  # infinity
    return;
  }

  if ($n != int($n)) {
    my $frac = $n;
    $n = int($n);
    $frac -= $n;
    my ($x1, $y1) = $self->n_to_xy($n);
    my ($x2, $y2) = $self->n_to_xy($n+1);
    return ($x2*$frac + $x1*(1-$frac),
            $y2*$frac + $y1*(1-$frac));
  }

  while ($n > $#n_to_x) {
    _extend();
  }

  return ($n_to_x[$n], $n_to_y[$n]);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### Hypot xy_to_n(): "$x, $y"

  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  my $h = $x*$x + $y*$y;

  while ($y_next_x[$y] <= $x) {
    _extend();
  }
  return $xy_to_n{"$x,$y"};
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = floor($x1 + 0.5);
  $y1 = floor($y1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);
  }
  return (1, ($x2+$y2)**2);
}

1;
__END__

=for stopwords Archimedean Ryde Math-Image

=head1 NAME

Math::PlanePath::MathImageHypot -- points by hypotenuse distance

=head1 SYNOPSIS

 use Math::PlanePath::MathImageHypot;
 my $path = Math::PlanePath::MathImageHypot->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progresss ... the current implementation is very slack.>

This path takes integer points XE<lt>0,YE<lt>0 in order of their distance
from the origin 0,0, that distance being the hypotenuse sqrt(X^2+Y^2).

     9      73  75  79  83  85
     8      58  62  64  67  71  81  ...
     7      45  48  52  54  61  69  78  86
     6      35  37  39  43  50  56  65  77  88
     5      26  28  30  33  41  47  55  68  80
     4      17  19  22  25  31  40  49  60  70  84
     3      11  13  15  20  24  32  42  53  66  82
     2       6   8   9  14  21  29  38  51  63  76
     1       3   4   7  12  18  27  36  46  59  74
    Y=0      1   2   5  10  16  23  34  44  57  72

            X=0  1   2   3   4   5   6   7   8   9  ...

For example N=37 is at X=1,Y=6 which is sqrt(1*1+6*6) = sqrt(37) from the
origin.  The next closest to the origin is X=6,Y=2 at sqrt(40).  In general
it's the sums of two squares X^2+Y^2 taken in order from smallest to biggest.

Points X,Y and swapped Y,X are the same distance from the origin.  The one
with bigger X is taken first, then the swapped Y,X (as long as X!=Y).  For
example N=21 is X=4,Y=2 and N=22 is X=2,Y=4.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageHypot-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the first
point at X=0,Y=0 is N=1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square and an C<$x,$y> within that square
returns N.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PixelRings>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Math-Image is Copyright 2011 Kevin Ryde

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
