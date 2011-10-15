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


# math-image --path=MathImageUlamWarburton
# math-image --path=MathImageUlamWarburton --all --output=numbers --size=80x50
#
# A147582 - turned on by level n
# A147562 - total number of on cells at level n
# A147610 - 3^(ones(n-1) - 1)
# A048883 - 3^(ones n)

package Math::PlanePath::MathImageUlamWarburton;
use 5.004;
use strict;
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 77;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;


# 1+3+3+9=16
#
# 0 +1
# 1 +4        <- 0
# 5 +4        <- 1
# 9 +12
# 21 +4     <- 5 + 4+12 = 21 = 5 + 4*(1+3)
# 25 +12
# 37 +12
# 49 +36
# 85 +4     <- 21 + 4+12+12+36  = 21 + 4*(1+3+3+9)
# 89 +12      <- 8   +64
# 101 +12
# 113 +36
# 149
# 161
# 197
# 233
# 341
# 345         <- 16  +256
# 357
# 369

# 1+3 = 4  level 2
# 1+3+3+9 = 16    level 3
# 1+3+3+9+3+9+9+27 = 64    level 4
#
# 4*(1+4+...+4^(l-1)) = 4*(4^l-1)/3
#    l=1 total=4*(4-1)/3 = 4
#    l=2 total=4*(16-1)/3=4*5 = 20
#    l=3 total=4*(64-1)/3=4*63/3 = 4*21 = 84
#
# n = 2 + 4*(4^l-1)/3
# (n-2) = 4*(4^l-1)/3
# 3*(n-2) = 4*(4^l-1)
# 3n-6 = 4^(l+1)-4
# 3n-2 = 4^(l+1)
#
# 3^0+3^1+3^1+3^2 = 1+3+3+9=16
# x+3x+3x+9x = 16x = 256
# 4 quads is 4*16=64
#
# 1+1+3 = 5
# 1+1+3 +1+1+3 +3+3+9 = 25

# 1+4 = 5
# 1+4+4+12 = 21 = 1 + 4*(1+1+3)
# 2  +1
# 3  +3
# 6  +1
# 7  +1
# 10 +3
# 13


sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageUlamWarburton n_to_xy(): $n

  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }
  if ($n == 1) { return (0,0); }

  {
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
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  my ($power, $exp) = _round_down_pow (3*$n-2, 4);
  $exp -= 1;
  $power /= 4;

  ### $power
  ### $exp
  ### pow base: 2 + 4*(4**$exp - 1)/3

  $n -= ($power - 1)/3 * 4 + 2;
  ### n less pow base: $n

  my @levelbits = (2**$exp);
  $power = 3**$exp;

  # find the cumulative levelpoints total <= $n, being the start of the
  # level containing $n
  #
  my $factor = 4;
  while (--$exp >= 0) {
    $power /= 3;
    my $sub = 4**$exp * $factor;
    ### $sub
    # $power*$factor;
    my $rem = $n - $sub;

    ### $n
    ### $power
    ### $factor
    ### consider subtract: $sub
    ### $rem

    if ($rem >= 0) {
      $n = $rem;
      push @levelbits, 2**$exp;
      $factor *= 3;
    }
  }

  ### @levelbits
  ### remaining n: $n
  ### assert: $n >= 0
  ### assert: $n < $factor

  $factor /= 4;
  my $quad = int ($n / $factor);
  $n %= $factor;

  ### mod: $factor
  ### $quad
  ### n within quad: $n
  ### assert: $quad >= 0
  ### assert: $quad <= 3

  my $x = 0;
  my $y = 0;
  while (@levelbits) {
    ### levelbits: $levelbits[-1]
    ### digit: $n % 3
    my $digit = $n % 3;
    $n = int($n/3);
    $x += pop @levelbits;
    if (@levelbits) {
      if ($digit == 0) {
        ($x,$y) = ($y,-$x);   # rotate -90
      } elsif ($digit == 2) {
        ($x,$y) = (-$y,$x);   # rotate +90
      }
    }
    ### rotate to: "$x,$y"
    ### bit to x: "$x,$y"
  }

  ### xy no quad: "$x,$y"
  if ($quad & 2) {
    $x = -$x;
    $y = -$y;
  }
  if ($quad & 1) {
    ($x,$y) = (-$y,$x); # rotate +90
  }

  ### final: "$x,$y"
  return $x,$y;
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### UlamWarburton xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x == 0 && $y == 0) {
    return 1;
  }

  my $quad;
  if ($y > $x) {
    ### quad above leading diagonal ...
    if ($y > -$x) {
      ### quad above opposite diagonal, top quarter ...
      $quad = 1;
      ($x,$y) = ($y,-$x);  # rotate -90
    } else  {
      ### quad below opposite diagonal, left quarter ...
      $quad = 2;
      $x = -$x;  # rotate -180
      $y = -$y;
    }
  } else {
    ### quad below leading diagonal ...
    if ($y > -$x) {
      ### quad above opposite diagonal, right quarter ...
      $quad = 0;
    } else {
      ### quad below opposite diagonal, bottom quarter ...
      $quad = 3;
      ($x,$y) = (-$y,$x);  # rotate +90
    }
  }
  ### $quad
  ### quad rotated xy: "$x,$y"
  ### assert: $x >= $y
  ### assert: $x >= -$y

  my ($len, $exp) = _round_down_pow ($x + abs($y), 2);
  if (_is_infinite($exp)) { return ($exp); }


  my $level = my $ndigits = my $n = my $zero = ($x&0&$y);  # possible bignum 0

  while ($exp-- >= 0) {
    ### at: "$x,$y  n=$n len=$len"

    my $abs_y = abs($y);
    if ($x && $x == $abs_y) {
      return undef;
    }

    # right quarter
    ### assert: $x >= 0
    ### assert: $x >= abs($y)
    ### assert: $x+abs($y) < 2*$len || $x==abs($y)

    if ($x + $abs_y >= $len) {
      $x -= $len;
      ### shift to: "$x,$y"

      $level += $len;
      if ($x || $y) {
        $n *= 3;
        $ndigits++;

        if ($y < -$x) {
          ### bottom, digit 0 ...
          ($x,$y) = (-$y,$x);  # rotate +90

        } elsif ($y > $x) {
          ### top, digit 2 ...
          ($x,$y) = ($y,-$x);  # rotate -90
          $n += 2;
        } else {
          ### right, digit 1 ...
          $n += 1;
        }
      }
    }

    $len /= 2;
  }

  ### $n
  ### $level
  ### level n: _n_level($level)
  ### $ndigits
  ### npower: 3**$ndigits
  ### $quad
  ### quad powered: $quad*3**$ndigits
  ### xy_to_n: $n + ($zero+3)**$ndigits*$quad + _n_level($level)

  return $n + $quad*3**$ndigits + _n_level($level);
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageUlamWarburton rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my ($dlo, $dhi)
    = _rect_to_diamond_range (_round_nearest($x1), _round_nearest($y1),
                              _round_nearest($x2), _round_nearest($y2));
  ### $dlo
  ### $dhi

  if ($dlo) {
    ($dlo) = _round_down_pow ($dlo,2);
  }
  ($dhi) = _round_down_pow ($dhi,2);  # round up ...

  ### rounded to pow2: "$dlo  ".(2*$dhi)

  return (_n_level($dlo), _n_level(2*$dhi));
}

#     x1       |       x2
#     +--------|-------+ y2          xzero true, yzero false
#     |        |       |             diamond min is y1
#     +--------|-------+ y1
#              |
#    ----------O-------------
#
#     |   x1        x2
#     |    +--------+ y2          xzero false, yzero true
#     |    |        |             diamond min is x1
#    -O--------------------
#     |    |        |
#     |    +--------+ y1
#     |
#
sub _rect_to_diamond_range {
  my ($x1,$y1, $x2,$y2) = @_;

  my $xzero = ($x1 < 0) != ($x2 < 0);  # x range covers x=0
  my $yzero = ($y1 < 0) != ($y2 < 0);  # y range covers y=0

  $x1 = abs($x1);
  $y1 = abs($y1);
  $x2 = abs($x2);
  $y2 = abs($y2);

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1) }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1) }

  return (($yzero ? 0 : $y1) + ($xzero ? 0 : $x1),
          $x2+$y2);
}

sub _n_level {
  my ($level) = @_;
  ### _n_level: $level

  my ($power, $exp) = _round_down_pow ($level, 2);
  my $n = 2 + 4*($power*$power - 1)/3  - ($level==0);

  ### $power
  ### $exp
  ### $n

  $level -= $power;
  my $factor = 4;
  while ($exp--) {
    $power /= 2;
    if ($level >= $power) {
      $level -= $power;
      $n += $power*$power*$factor;
      ### add: $power*$factor
      $factor *= 3;
    }
  }
  ### n_level: $n
  return $n;
}

### assert: _n_level(1) == 2
### assert: _n_level(2) == 6
### assert: _n_level(3) == 10
### assert: _n_level(4) == 22
### assert: _n_level(5) == 26
### assert: _n_level(6) == 38
### assert: _n_level(7) == 50
### assert: _n_level(8) == 86


1;
__END__

=for stopwords eg Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageUlamWarburton -- points in quater-imaginary base 2i

=head1 SYNOPSIS

 use Math::PlanePath::MathImageUlamWarburton;
 my $path = Math::PlanePath::MathImageUlamWarburton->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This is the pattern of a cellular automaton studied by Ulam and Warburton
with cells numbered by growth level and anti-clockwise within the level.

                               94                                  9
                            95 87 93                               8
                               63                                  7
                            64 42 62                               6
                         65    30    61                            5
                      66 43 31 23 29 41 60                         4
                   69    67    14    59    57                      3
                70 44 68    15  7 13    58 40 56                   2
       96    71    32    16     3    12    28    55    92          1
    97 88 72 45 33 24 17  8  4  1  2  6 11 22 27 39 54 86 91   <- Y=0
       98    73    34    18     5    10    26    53    90         -1
                74 46 76    19  9 21    50 38 52       ...        -2
                   75    77    20    85    51                     -3
                      78 47 35 25 37 49 84                        -4
                         79    36    83                           -5
                            80 48 82                              -6
                               81                                 -7
                            99 89 101                             -8
                              100                                 -9

                               ^
    -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9

The rule is that a given cell grows up, down, left and/or right, but only if
the new cell has no neighbours (up, down, left or right).  So,

                a                  initial level 0 cell
                                       
                b   
             b  a  b               level 1 
                b    

                c      
                b        
          c  b  a  b  c            level 2  
                b        
                c        

                d
             d  c  d      
          d     b     d   
       d  c  b  a  b  c  d         level 3  
          d     b     d   
             d  c  d  
                d

                e                
                d
             d  c  d     
          d     b     d   
    e  d  c  b  a  b  c  d  e      level 4
          d     b     d   
             d  c  d  
                d
                e

The initial cell "a" is N=1, then the "b" cells are numbered N=2 to N=5
anti-clockwise from the right, and likewise the "c" cells N=6 to N=9.  The
"b" cells can only grow outwards for 4 "c"s, since the other up/down etc
would have a neighbour in the existing "b"s.

The "d" cells are then N=10 to N=21, numbered following the previous level
"c" cell order and anti-clockwise around each.  Notice that there's only 4
"e" cells since the "d"s can only grow along the X,Y axes as all other
up/down etc have neighbours (the existing "b"s and "d"s).

In general each level always grows by 1 along the X and Y axes and the plane
in between is filled in a sort of diamond shaped tree pattern which ends up
with 11 cells in each 4x4 square block.

=head2 Level Ranges

Counting level 0 as the N=1 at the origin, and level 1 as the next N=2,3,4,5
generation, the number of new cells added in a growth level is

    levelcells(0) = 1
      then
    levelcells(level) = 4 * 3^((count 1 bits in level) - 1)

So level 1 has 4*3^0=4 cells, as does level 2 N=6,7,8,9.  Then level 3 has
4*3^1=12 cells N=10 through N=21 because 3=0b11 has two 1 bits in binary.
The N start for a level is the cumulative total of those before it,

    Nstart(level) = 1 + (levelcells(0) + ... + levelcells(level-1))

For example level 3 starts at N=1+(1+4+4)=10.

    level    Nstart     levelcells   
      0          1          1
      1          2          4
      2          6          4
      3         10         12
      4         22          4
      5         26         12
      6         38         12
      7         50         36
      8         86          4
      9         90        ...

For a power-of-2 level the Nstart sum is

    Nstart(2^a) = 2 + 4*(4^a-1)/3

For example level=4=2^2 starts at N=2+4*(4^2-1)/3=22, or level=4=2^3 starts
N=2+4*(4^3-1)/3=86.

Further bits in the level value contribute powers-of-4 with a tripling for
each bit above.  So if the level has bits a,b,c,d,etc in descending order,

    level = 2^a + 2^b + 2^c + 2^d ...
    Nstart = 2 + 4*(4^a-1)/3
               +       4^(b+1)
               +   3 * 4^(c+1)
               + 3^2 * 4^(d+1) + ...

For example level=6 = 2^2+2^1 is Nstart = 1 + (1+4*(4^2-1)/3) + 4^(1+1) =
38.  Or level=7 = 2^2+2^1+2^0 is Nstart = 1 + (1+4*(4^2-1)/3) + 4^(1+1) +
3*4^(0+1) = 50.

=head1 OEIS

This automaton is in Sloane's Online Encyclopedia of Integer Sequences as

    A147582 - new cells in level n
    A147562 - cumulative total cells to level n

    http://oeis.org/A147582    etc

The A147582 new cells sequence starts from n=1, so has the innermost N=1
single cell as level n=1, then N=2 to N=5 as level n=2, etc.  This makes the
formula a binary ones count of n-1 rather than n the way levelcells() above
has it.

The 3^(count 1 bits in level) part of the levelcells() is separately in
A048883, and in A147610 with n-1.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageUlamWarburton-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 1 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SierpinskiTriangle>

=cut

# Local variables:
# compile-command: "math-image --path=MathImageUlamWarburton"
# End:
