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


package Math::PlanePath::MathImagePeanoRounded;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 84;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

use constant parameter_info_array =>
  [ { name      => 'radix',
      share_key => 'radix_3',
      type      => 'integer',
      minimum   => 2,
      default   => 3,
      width     => 3,
    } ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  if (! $self->{'radix'} || $self->{'radix'} < 2) {
    $self->{'radix'} = 3;
  }
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImagePeanoRounded n_to_xy(): $n
  if ($n < 0) {            # negative
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  {
    # ENHANCE-ME: for odd radix the ends join and the direction can be had
    # without a full N+1 calculation
    my $int = int($n);
    ### $int
    ### $n
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  # low to high
  my $x = my $y = ($n % 2);
  $n = int($n/2);
  my $power = ($n * 0) + 2;  # inherit BigInt 1
  my $radix = $self->{'radix'};

  for (;;) {
    ### $n
    ### $power
    {
      my $digit = $n % $radix;
      if ($digit & 1) {
        $y = $power-1 - $y;   # 99..99 - Y
      }
      $x += $power * $digit;
    }
    $n = int($n/$radix) || last;
    {
      my $digit = $n % $radix;
      $y += $power * $digit;
      $power *= $radix;

      if ($digit & 1) {
        $x = $power-1 - $x;
      }
    }
    $n = int($n/$radix) || last;
  }
  return ($x, $y);


  # # high to low
  # my $radix = $self->{'radix'};
  # my $radix_minus_1 = $radix - 1;
  # my (@n);
  # while ($n) {
  #   push @n, $n % $radix; $n = int($n/$radix);
  #   push @n, $n % $radix; $n = int($n/$radix);
  # }
  # my $x = 0;
  # my $y = 0;
  # my $xk = 0;
  # my $yk = 0;
  # while (@n) {
  #   {
  #     my $digit = pop @n;
  #     $xk ^= $digit;
  #     $y *= $radix;
  #     $y += ($yk & 1 ? $radix_minus_1-$digit : $digit);
  #   }
  #   {
  #     my $digit = pop @n;
  #     $yk ^= $digit;
  #     $x *= $radix;
  #     $x += ($xk & 1 ? $radix_minus_1-$digit : $digit);
  #   }
  # }
  # ### is: "$x,$y"
  # return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MathImagePeanoRounded xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  if ($x < 0 || $y < 0) {
    return undef;
  }
  if (_is_infinite($x)) {
    return $x;
  }
  if (_is_infinite($y)) {
    return $y;
  }

  my $xlow = $x % 2;
  my $ylow = $y % 2;
  $x = int($x/2);
  $y = int($y/2);

  my $radix = $self->{'radix'};
  my $radix_minus_1 = $radix - 1;
  my @x;
  my @y;
  while ($x || $y) {
    push @x, $x % $radix; $x = int($x/$radix);
    push @y, $y % $radix; $y = int($y/$radix);
  }

  my $xk = 0;
  my $yk = 0;
  my $n = 0;
  while (@x) {
    {
      my $digit = pop @y;
      if ($yk & 1) {
        $digit = $radix_minus_1 - $digit;
      }
      $n = ($n * $radix) + $digit;
      $xk ^= $digit;
    }
    {
      my $digit = pop @x;
      if ($xk & 1) {
        $digit = $radix_minus_1 - $digit;
      }
      $n = ($n * $radix) + $digit;
      $yk ^= $digit;
    }
  }

  if ($yk & 1) {
    $ylow = 1-$ylow;
  }
  if ($xk & 1) {
    $xlow = 1-$xlow;
  }
  $n *= 2;
  if ($xlow == 0 && $ylow == 0) {
    return $n;
  } elsif ($xlow == 1 && $ylow == 1) {
    return $n + 1;
  }
  return undef;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### rect_to_n_range(): "$x1,$y1 to $x2,$y2"

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);
  }

  my $radix = $self->{'radix'};

  my ($power, $level) = _round_down_pow (_max($x2,$y2)*$radix/2, $radix);
  if (_is_infinite($level)) {
    return (0, $level);
  }
  return (0, 2*$power*$power - 1);



  # Would need to backtrack if the rectangle misses the 2/4 cells filled ...


  # my $n_power = 2 * $power * $power * $radix;
  # my $max_x = 0;
  # my $max_y = 0;
  # my $max_n = 0;
  # my $max_xk = 0;
  # my $max_yk = 0;
  #
  # my $min_x = 0;
  # my $min_y = 0;
  # my $min_n = 0;
  # my $min_xk = 0;
  # my $min_yk = 0;
  #
  # # l<=c<h doesn't overlap c1<=c<=c2 if
  # #     l>c2 or h-1<c1
  # #     l>c2 or h<=c1
  # # so does overlap if
  # #     l<=c2 and h>c1
  # #
  # my $radix_minus_1 = $radix - 1;
  # my $overlap = sub {
  #   my ($c,$ck,$digit, $c1,$c2) = @_;
  #   if ($ck & 1) {
  #     $digit = $radix_minus_1 - $digit;
  #   }
  #   ### overlap consider: "inv".($ck&1)."digit=$digit ".($c+$digit*$power)."<=c<".($c+($digit+1)*$power)." cf $c1 to $c2 incl"
  #   return ($c + $digit*$power <= $c2
  #           && $c + ($digit+1)*$power > $c1);
  # };
  #
  # while ($level-- >= 0) {
  #   ### $power
  #   ### $n_power
  #   ### $max_n
  #   ### $min_n
  #   {
  #     my $digit;
  #     for ($digit = $radix_minus_1; $digit > 0; $digit--) {
  #       last if &$overlap ($max_y,$max_yk,$digit, $y1,$y2);
  #     }
  #     $max_n += $n_power * $digit;
  #     $max_xk ^= $digit;
  #     if ($max_yk&1) { $digit = $radix_minus_1 - $digit; }
  #     $max_y += $power * $digit;
  #     ### max y digit (complemented): $digit
  #     ### $max_y
  #     ### $max_n
  #   }
  #   {
  #     my $digit;
  #     for ($digit = 0; $digit < $radix_minus_1; $digit++) {
  #       last if &$overlap ($min_y,$min_yk,$digit, $y1,$y2);
  #     }
  #     $min_n += $n_power * $digit;
  #     $min_xk ^= $digit;
  #     if ($min_yk&1) { $digit = $radix_minus_1 - $digit; }
  #     $min_y += $power * $digit;
  #     ### min y digit (complemented): $digit
  #     ### $min_y
  #     ### $min_n
  #   }
  #
  #   $n_power = int($n_power/$radix);
  #   {
  #     my $digit;
  #     for ($digit = $radix_minus_1; $digit > 0; $digit--) {
  #       last if &$overlap ($max_x,$max_xk,$digit, $x1,$x2);
  #     }
  #     $max_n += $n_power * $digit;
  #     $max_yk ^= $digit;
  #     if ($max_xk&1) { $digit = $radix_minus_1 - $digit; }
  #     $max_x += $power * $digit;
  #     ### max x digit (complemented): $digit
  #     ### $max_x
  #     ### $max_n
  #   }
  #   {
  #     my $digit;
  #     for ($digit = 0; $digit < $radix_minus_1; $digit++) {
  #       last if &$overlap ($min_x,$min_xk,$digit, $x1,$x2);
  #     }
  #     $min_n += $n_power * $digit;
  #     $min_yk ^= $digit;
  #     if ($min_xk&1) { $digit = $radix_minus_1 - $digit; }
  #     $min_x += $power * $digit;
  #     ### min x digit (complemented): $digit
  #     ### $min_x
  #     ### $min_n
  #   }
  #
  #   $power = int($power/$radix);
  #   $n_power = int($n_power/$radix);
  # }
  #
  # ### is: "$min_n at $min_x,$min_y  to  $max_n at $max_x,$max_y"
  # return ($min_n, $max_n);
}

1;
__END__

=for stopwords Guiseppe Peano Peano's eg Sur une courbe qui remplit toute aire Mathematische Annalen Ryde OEIS ZOrderCurve ie PeanoCurve Math-PlanePath versa Online Radix radix HilbertCurve

=head1 NAME

Math::PlanePath::MathImagePeanoRounded -- 3x3 self-similar quadrant traversal

=head1 SYNOPSIS

 use Math::PlanePath::MathImagePeanoRounded;
 my $path = Math::PlanePath::MathImagePeanoRounded->new;
 my ($x, $y) = $path->n_to_xy (123);

 # or another radix digits ...
 my $path5 = Math::PlanePath::MathImagePeanoRounded->new (radix => 5);

=head1 DESCRIPTION

This is a version of the PeanoCurve with rounded-off corners,


    11                        76-75       72-71       68-67
                             /     \     /     \     /     \
    10                     77       74-73       70-69       66
                            |                                |
     9                     78       81-82       61-62       65
                             \     /     \     /     \     /
     8                        79-80       83 60       63-64
                                           |  |
     7                        88-87       84 59       56-55
                             /     \     /     \     /     \
     6                 ...-89       86-85       58-57       54
                                                             |
     5      13-14       17-18       21-22       49-50       53
           /     \     /     \     /     \     /     \     /
     4   12       15-16       19-20       23 48       51-52
          |                                |  |
     3   11        8--7       28-27       24 47       44-43
           \     /     \     /     \     /     \     /     \
     2      10--9        6 29       26-25       46-45       42
                         |  |                                |
     1       1--2        5 30       33-34       37-38       41
           /     \     /     \     /     \     /     \     /
    Y=0   0        3--4       31-32       35-36       39-40

        X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17

=head2 Radix

The radix parameter can do the calculation in a base other than 3, using the
same kind of direction reversals.  For example radix 5 gives 5x5 groups,

      4  |
         |
      3  |
         |
      2  |
         |
      1  |
         |
     Y=0 |
         |
         +----------------------------------------------
           X=0   1   2   3   4   5   6   7   8   9  10

If the radix is even then the ends of each group don't join up.  For example
in radix 4 N=15 isn't next to N=16, nor N=31 to N=32, etc.

         |
      3  |
         |
      2  |
         |
      1  |
         |
     Y=0 |
         |
         +------------------------------------------
           X=0   1   2   4   5   6   7   8   9  10

Even sizes can be made to join using other patterns, but this module is just
Peano's digit construction.  For 2x2 groupings see HilbertCurve (which is
essentially the only way to join up in 2x2).  For bigger groupings there's
various ways.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImagePeanoRounded-E<gt>new ()>

=item C<$path = Math::PlanePath::MathImagePeanoRounded-E<gt>new (radix =E<gt> $r)>

Create and return a new path object.

The optional C<radix> parameter gives the base for digit splitting.  The
default is ternary, C<radix =E<gt> 3>.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::DragonRounded>

Guiseppe Peano, "Sur une courbe, qui remplit toute une aire plane",
Mathematische Annalen, volume 36, number 1, 1890, p157-160

    http://www.springerlink.com/content/w232301n53960133/
    DOI 10.1007/BF01199438

=cut

# math-image --path=MathImagePeanoRounded --all --output=numbers
# math-image --path=MathImagePeanoRounded,radix=5 --all --output=numbers
# math-image --path=MathImagePeanoRounded,radix=5 --lines
#
