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


# math-image --path=MathImageDigitGroups,radix=2 --all --output=numbers
# math-image --path=MathImageDigitGroups,radix=2 --lines
#
# increment N+1 changes low 1111 to 10000
# X bits change 011 to 000, no carry, decreasing by number of low 1s
# Y bits change 011 to 100, plain +1




package Math::PlanePath::MathImageDigitGroups;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 76;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

use constant parameter_info_array => [{ name      => 'radix',
                                        share_key => 'radix_2',
                                        type      => 'integer',
                                        minimum   => 2,
                                        default   => 2,
                                        width     => 3,
                                      }];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  if (! $self->{'radix'} || $self->{'radix'} < 2) {
    $self->{'radix'} = 2;
  }
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### DigitGroups n_to_xy(): $n
  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  {
    # ENHANCE-ME: N and N+1 are either adjacent X or on a slope Y to Y+1 for
    # the base X, don't need the full calculation for N+1
    my $int = int($n);
    ### $int
    if ($n != $int) {
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      ### $frac
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my $radix = $self->{'radix'};
  ### $radix
  my $x = my $y = $n & 0;          # inherit bignum 0
  my $xpower = my $ypower = $x+1;  # inherit bignum 1
  my $digit;
  for (;;) {
    do {
      $digit = ($n % $radix);
      ### digit to x: $digit
      $x += $digit * $xpower;
      $n = int ($n / $radix) || return ($x, $y);
      $xpower *= $radix;
    } until ($digit);

    do {
      $digit = ($n % $radix);
      ### digit to y: $digit
      $y += $digit * $ypower;
      $n = int ($n / $radix) || return ($x, $y);
      $ypower *= $radix;
    } until ($digit);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DigitGroups xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0
      || _is_infinite($x)
      || _is_infinite($y)) {
    return undef;
  }

  if ($x == 0 && $y == 0) {
    return 0;
  }

  my $n = ($x & 0 & $x); # inherit
  my $radix = $self->{'radix'};

  my $power = $n+1; # inherit
  my $digit;
  for (;;) {
    if ($x) {
      do {
        $digit = ($x % $radix);
        $n += $digit * $power;
        $power *= $radix;
        $x = int ($x / $radix) || return $n + $y*$power;
      } until ($digit);
    } else {
      return undef;
    }

    if ($y) {
      do {
        $digit = ($y % $radix);
        $n += $digit * $power;
        $power *= $radix;
        $y = int ($y / $radix) || return $n + $x*$power;
      } until ($digit);
    } else {
      return undef; # $n + $x * $power;
    }
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }  # x1 smaller
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }  # y1 smaller

  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  if ($x1 < 0) { $x1 = 0; }
  if ($y1 < 0) { $y1 = 0; }

  # monotonic increasing in $x and $y directions, so this is exact
  return ($self->xy_to_n ($x1, $y1),
          $self->xy_to_n ($x2, $y2));
}

1;
__END__

=for stopwords Ryde Math-PlanePath Karatsuba undrawn

=head1 NAME

Math::PlanePath::MathImageDigitGroups -- 2x2 self-similar Z shape digits

=head1 SYNOPSIS

 use Math::PlanePath::MathImageDigitGroups;

 my $path = Math::PlanePath::MathImageDigitGroups->new;
 my ($x, $y) = $path->n_to_xy (123);

 # or another radix digits ...
 my $path3 = Math::PlanePath::MathImageDigitGroups->new (radix => 3);

=head1 DESCRIPTION

This path ...

      7  |   
      6  |   
      5  |   
      4  |   
      3  |   
      2  |   
      1  |   
     Y=0 |   
         +--------------------------------
          X=0   1   2   3   4   5   6   7


=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageDigitGroups-E<gt>new ()>

=item C<$path = Math::PlanePath::MathImageDigitGroups-E<gt>new (radix =E<gt> $r)>

Create and return a new path object.  The optional C<radix> parameter gives
the base for digit splitting (the default is binary, radix 2).

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::ZOrderCurve>

=cut
