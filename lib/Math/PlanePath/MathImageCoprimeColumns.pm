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


# math-image --path=MathImageCoprimeColumns --all --scale=10

package Math::PlanePath::MathImageCoprimeColumns;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 59;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

my @x_to_n = (0);
my $next_n = 1;

sub n_to_xy {
  my ($self, $n) = @_;
  return if $n < 0;
  ### CoprimeColumns n_to_xy(): $n

  if ($n < 1
      || $n-1 == $n) {   # infinity
    return;
  }

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }
  my $x = 1;
  for (;;) {
    while ($x > $#x_to_n) {
      _extend();
    }
    if ($x_to_n[$x] > $n) {
      $x--;
      last;
    }
    $x++;
  }
  $n -= $x_to_n[$x];
  ### $x
  ### n base: $x_to_n[$x]
  ### n next: $x_to_n[$x+1]
  ### remainder: $n

  my $y = 1;
  for (;;) {
    if (_coprime($x,$y)) {
      if (--$n < 0) {
        return ($x,$y);
      }
    }
    if (++$y >= $x) {
      ### oops, not enough in this column
      return;
    }
  }
}

sub _extend {
  my $x = @x_to_n;
  ### _extend(): "$x is $next_n"
  push @x_to_n, $next_n;

  if ($x > 2) {
    if (($x & 3) == 2) {
      $x >>= 1;
      $next_n += $x_to_n[$x] - $x_to_n[$x-1];
    } else {
      $next_n += _totient_count($x);
    }
  }
  ### $next_n
}
sub _totient_count {
  my ($x) = @_;
  my $count = (1                            # y=1 always
               + ($x > 2 && ($x&1))         # y=2 if $x odd
               + ($x > 3 && ($x % 3) != 0)  # y=3
               + ($x > 4 && ($x&1))         # y=4 if $x odd
              );
  for (my $y = 5; $y < $x; $y++) {
    $count += _coprime($x,$y);
  }
  return $count;
}
sub _coprime {
  my ($x, $y) = @_;
  ### _coprime(): "$x,$y"
  if ($y >= $x) {
    return 0;
  }
  for (;;) {
    if ($y <= 1) {
      return ($y == 1);
    }
    ($x,$y) = ($y, $x % $y);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### CoprimeColumns xy_to_n(): "$x,$y"
  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  if ($x < 1
      || $y < 1
      || $y >= $x+($x==1)
      || $x-1 == $x    # infinity
      || $y-1 == $y
      || ! _coprime($x,$y)) {
    return undef;
  }
  while ($#x_to_n < $x) {
    _extend();
  }
  my $n = $x_to_n[$x];
  ### base n: $n
  if ($y != 1) {
    foreach my $i (1 .. $y-1) {
      if (_coprime($x,$i)) {
        $n++;
      }
    }
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);

  if ($x2 <= 0 || $y2 <= 0) {
    return (1, 0);
  }
  return (1, .304*$x2*$x2 + 20);
}

1;
__END__

=for stopwords eg Ryde OEIS

=head1 NAME

Math::PlanePath::MathImageCoprimeColumns -- coprime x,y by columns

=head1 SYNOPSIS

 use Math::PlanePath::MathImageCoprimeColumns;
 my $path = Math::PlanePath::MathImageCoprimeColumns->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageCoprimeColumns-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PythagoreanTree>

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
