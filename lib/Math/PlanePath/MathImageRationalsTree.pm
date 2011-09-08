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


# math-image --path=MathImageRationalsTree --all --scale=3


package Math::PlanePath::MathImageRationalsTree;
use 5.004;
use strict;
use List::Util qw(min max);

use vars '$VERSION', '@ISA';
$VERSION = 69;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new (@_);
  $self->{'tree_type'} ||= 'SB';
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### RationalsTree n_to_xy(): $n

  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  {
    my $int = int($n);
    if ($n != $int) {
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
  }

  my @ret;
  foreach my $offset (1,0) {
    my $i = $n + $offset;
    my $b = ($n & 0); # inherit bignum 0
    my $a = $b + 1;   # inherit bignum 1
    while ($i) {
      if ($i % 2) {
        $b += $a;
      } else {
        $a += $b;
      }
      $i = int($i/2);
    }
    push @ret, $b;
  }

  return @ret;
}

# (3*pow+1)/2 - (pow+1)/2
#     = (3*pow + 1 - pow - 1)/2
#     = (2*pow)/2
#     = pow
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### RationalsTree xy_to_n(): "$x, $y"

  return undef;
  # if (_is_infinite($p) || _is_infinite($q)  # infinity
  #     || $p < 1 || $q < 1       # negatives
  #     || ! (($p ^ $q) & 1)      # must be opposite parity
  #    ) {
  #   return undef;
  # }
}


# numprims(H) = how many with hypot < H
# limit H->inf  numprims(H) / H -> 1/2pi
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### rect_to_n_range()

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### $x2
  ### $y2

  return (0, ($x2+2)*($y2+2));

  my $max = ($x2 > $y2 ? $x2 : $y2);
  return (0, 2 ** $max);
}

1;
__END__

=for stopwords eg Ryde OEIS ie Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageRationalsTree -- reduced rationals by tree

=head1 SYNOPSIS

 use Math::PlanePath::MathImageRationalsTree;
 my $path = Math::PlanePath::MathImageRationalsTree->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path enumerates rationals Y/X in reduced form, ie. with no common
factor, by the Stern-Brocot or Calkin-Wilf binary trees.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageRationalsTree-E<gt>new ()>

Create and return a new path object.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PythagoreanTree>

=cut
