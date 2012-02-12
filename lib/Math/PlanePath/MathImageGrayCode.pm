# N as gray
# X,Y change by one bit each time





# Copyright 2011, 2012 Kevin Ryde

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



# math-image --path=MathImageGrayCode --all --output=numbers
# math-image --path=MathImageGrayCode,radix=3 --all --output=numbers



package Math::PlanePath::MathImageGrayCode;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 93;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_min = \&Math::PlanePath::_min;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

use Math::PlanePath::ZOrderCurve;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

# use constant parameter_info_array => [{ name      => 'radix',
#                                         share_key => 'radix_2',
#                                         type      => 'integer',
#                                         minimum   => 2,
#                                         default   => 2,
#                                         width     => 3,
#                                       }];

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
  ### GrayCode n_to_xy(): $n
  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }


   $n = _to_gray($n);
  # $n = _from_gray($n);
  return $self->Math::PlanePath::ZOrderCurve::n_to_xy($n);



  {
    # ENHANCE-ME: N and N+1 differ by not much ...
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
  my @digits;
  while ($n) {
    push @digits, ($n % $radix);
    $n = int($n/$radix);
    push @digits, ($n % $radix);
    $n = int($n/$radix);
  }

  my $x = my $y = ($n * 0);  # inherit bignum 0
  my $rev = 0;
  my $radix_minus_1 = $radix - 1;

  while (@digits) {
    {
      my $digit = pop @digits;  # high to low
      if ($rev & 1) {
        $y = $y * $radix + $radix_minus_1 - $digit;
      } else {
        $y = $y * $radix + $digit;
      }
      $rev ^= $digit;
    }
    {
      my $digit = pop @digits;
      if ($rev & 1) {
        $x = $x * $radix + $radix_minus_1 - $digit;
      } else {
        $x = $x * $radix + $digit;
      }
      $rev ^= $digit;
    }
  }
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### GrayCode xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0
      || _is_infinite($x)
      || _is_infinite($y)) {
    return undef;
  }

  my $n = $self->Math::PlanePath::ZOrderCurve::xy_to_n($x,$y) || 0;
  return _from_gray($n);
  return _to_gray($n);




  my $radix = $self->{'radix'};
  my $n = ($x * 0 * $y); # inherit bignum 0
  my $power = $n + 1;    # inherit bignum 1

  my $d2 = ($x % $radix);  # digits low to high
  $x = int ($x / $radix);

  while ($x || $y) {
    my $digit = ($y % $radix);
    $n += ($digit ^ $d2) * $power;
    $y = int ($y / $radix);
    $power *= $radix;

    $d2 = ($x % $radix);
    $x = int ($x / $radix);
    $n += $power * ($digit ^ $d2);
    $power *= $radix;
  }
  return $n + $power * $d2;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = _round_nearest($x1);
  $y1 = _round_nearest($y1);
  $x2 = _round_nearest($x2);
  $y2 = _round_nearest($y2);

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }  # x1 smaller
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }  # y1 smaller

  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  my $radix = $self->{'radix'};
  my ($pow_max) = _round_down_pow (_max($x2,$y2),
                                   $radix);
  $pow_max *= $radix;
  return (0,
          $pow_max*$pow_max - 1);
}

sub _to_gray {
  my ($n) = @_;
  return ($n >> 1) ^ $n;
}

sub _from_gray {
  my ($n) = @_;
  my @digits;
  while ($n) {
    push @digits, $n & 1;
    $n >>= 1;
  }
  my $xor = 0;
  my $ret = 0;
  while (@digits) {
    my $digit = pop @digits;
    $ret <<= 1;
    $ret |= $digit^$xor;
    $xor ^= $digit;
  }
  return $ret;
}

1;
__END__

=for stopwords Ryde Math-PlanePath eg Radix radix ie

=head1 NAME

Math::PlanePath::MathImageGrayCode -- 2x2 self-similar Z shape digits

=head1 SYNOPSIS

 use Math::PlanePath::MathImageGrayCode;

 my $path = Math::PlanePath::MathImageGrayCode->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress...>  Mostly works.

This path gives points in a Gray code order by taking N as a is a split of N into X,Y by alternate bits, but with N values in Gray
code order.

      7  |  63--62  57--56  39--38  33--32
         |       |   |           |   |
      6  |  60--61  58--59  36--37  34--35
         |
      5  |  51--50  53--52  43--42  45--44
         |       |   |           |   |
      4  |  48--49  54--55  40--41  46--47
         |
      3  |  15--14   9-- 8  23--22  17--16
         |       |   |           |   |
      2  |  12--13  10--11  20--21  18--19
         |
      1  |   3-- 2   5-- 4  27--26  29--28
         |       |   |           |   |
     Y=0 |   0-- 1   6-- 7  24--25  30--31
         +----------------------------------
            X=0  1   2   3   4   5   6   7

Within an power of 2 square 2x2, 4x4, 8x8, 16x16 etc (2^k)x(2^k), all the N
values 0 to 2^(2*k)-1 are within the square.  The top left corner 3, 15, 63,
255 etc of each is the 2^(2*k)-1 maximum.  The bottom left corner 1, 7, 31,
127 etc is half-way, ie. one bit less.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageGrayCode-E<gt>new ()>

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
