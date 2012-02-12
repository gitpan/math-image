# working ...



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




# math-image --path=MathImageSierpinskiCurveSquare --lines --scale=10
#
# math-image --path=MathImageSierpinskiCurveSquare --all --output=numbers_dash



package Math::PlanePath::MathImageSierpinskiCurveSquare;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 93;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;

# x,y negatives by number of arms
my @x_negative = (undef,  0,0, 1,1, 1,1, 1,1);
my @y_negative = (undef,  0,0, 0,0, 1,1, 1,1);
sub x_negative {
  my ($self) = @_;
  return $x_negative[$self->arms_count];
}
sub y_negative {
  my ($self) = @_;
  return $y_negative[$self->arms_count];
}

sub arms_count {
  my ($self) = @_;
  return $self->{'arms'};
}

use constant parameter_info_array =>
  [
   { name      => 'arms',
     share_key => 'arms_8',
     type      => 'integer',
     minimum   => 1,
     maximum   => 8,
     default   => 1,
     width     => 1,
   },
  ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 8) { $arms = 8; }
  $self->{'arms'} = $arms;
  return $self;
}

#                        20--21
#                         |   |
#                    18--19  22--23
#                     |           |
#                16--17          24--25
#                 |                   |
#                15--14          27--26
#                     |           |
#         4---5      13--12  29--28      36--37
#         |   |           |   |           |   |
#     2---3   6---7  10--11  30--31  34--35  38--39  42--43
#     |           |   |           |   |           |   |
# 0---1           8---9          32--33          40--41

# len=5
# N=0 to 9 is 10
# next N=0 to 41 is 42=4*10+2
# next is 4*42+2=166
# points(level) = 4*points(level-1)+2
#
# or side 5 points
# points(level) = 4*points(level-1)+1
#               = 4*(4*points(level-2)+1)+1
#               = 16*points(level-2) + 4 + 1
#               = 64*points(level-3) + 16 + 4 + 1
#               = 5 * 4^level + 1+...+4^(level-1)
#               = 5 * 4^level + (4^level - 1) / 3
#               = (15 * 4^level + 4^level - 1) / 3
#               = (16 * 4^level - 1) / 3
#               = (4^(level+2) - 1) / 3
# level=0 (16*1-1)/3=5
# level=1 (16*4-1)/3=21
# level=2 (16*16-1)/3=85
#
# n = (16 * 4^level - 1) / 3
# 3n+1 = 16 * 4^level
# 4^level = (3n+1)/16
# level = log4 ( (3n+1)/16)
#       = log4(3n+1) - 2
# N=21 log4(64)-2=3-2=1
#
# nlen=4^(level+2)
# n = (nlen-1)/3
# next_n = (nlen/4-1)/3
#        = (nlen-4)/3 /4
#        = ((nlen-1)/3 -1) /4
#
# len=2,6,14
# len(k)=2*len(k-1) + 2
#       = 2^k + 2*(2^(k-1)-1)
#       = 2^k + 2^k - 2
#       = 2*(2^k - 1)
# k=1 len=2*(2-1) = 2
# k=2 len=2*(4-1) = 6
# k=3 len=2*(8-1) = 14

# len(k)-2=2*len(k-1)
# (len(k)-2)/2=len(k-1)
# len(k-1) = (len(k)-2)/2
#          = len(k)/2-1

my @lowdigit_to_x = (0,1,1,2,2,1);
my @lowdigit_to_y = (0,0,1,1,2,2);

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageSierpinskiCurveSquare n_to_xy(): $n

  if ($n < 0) {
    return;
  }

  my $arms = $self->{'arms'};
  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    if ($frac) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+$arms);

      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }
  ### $frac

  my $arm;
  {
    $arm = ($n % $arms);
    $n = int($n/$arms);
  }

  my $zero = ($n * 0);  # inherit bignum 0

  my ($nlen,$level) = _round_down_pow (3*$n+1, 4);
  ### $nlen
  ### $level
  if (_is_infinite($level)) {
    return $level;
  }

  my $x = $zero;
  my $y = $zero;
  my $dx = 1;
  my $dy = 0;

  my $len = 2**$level - 2;
  $nlen = ($nlen-1)/3;

  while ($level-- > 1) {
    ### at: "n=$n xy=$x,$y  nlen=$nlen len=$len"

    if ($n < 2*$nlen+1) {
      if ($n < $nlen) {
        ### part 0 ...
      } else {
        ### part 1 ...
        $x += ($len+1)*$dx - $len*$dy;
        $y += ($len+1)*$dy + $len*$dx;
        ($dx,$dy) = ($dy,-$dx); # rotate -90
        $n -= $nlen;
      }
    } else {
      $n -= 2*$nlen+1;
      if ($n < $nlen) {
        ### part 2 ...
        $x += (2*$len+2)*$dx - $dy;
        $y += (2*$len+2)*$dy + $dx;
        ($dx,$dy) = (-$dy,$dx); # rotate +90
      } else {
        ### part 3 ...
        $x += ($len+2)*$dx - ($len+2)*$dy;
        $y += ($len+2)*$dy + ($len+2)*$dx;
        $n -= $nlen;
      }
    }

    $nlen = ($nlen-1)/4;
    $len = $len/2-1;
  }

  ### final: "n=$n  xy=$x,$y  dxdy=$dx,$dy"
  ### lowdigit: "$lowdigit_to_x[$n],$lowdigit_to_y[$n]"
  ### assert: $n <= $#lowdigit_to_x

  $x += $lowdigit_to_x[$n]*$dx - $lowdigit_to_y[$n]*$dy;
  $y += $lowdigit_to_x[$n]*$dy + $lowdigit_to_y[$n]*$dx;

  $x += 1;
  if ($arm & 1) {
    ($x,$y) = ($y,$x);   # mirror 45
  }
  if ($arm & 2) {
    ($x,$y) = (-1-$y,$x);   # rotate +90
  }
  if ($arm & 4) {
    $x = -1-$x;   # rotate 180
    $y = -1-$y;
  }

  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MathImageSierpinskiCurveSquare xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my $arm = 0;
  if ($y < 0) {
    $arm = 4;
    $x = -1-$x;  # rotate -180
    $y = -1-$y;
  }
  if ($x < 0) {
    $arm += 2;
    ($x,$y) = ($y, -1-$x);  # rotate -90
  }
  if ($y > $x) {       # second octant
    $arm++;
    ($x,$y) = ($y,$x); # mirror 45
  }

  my $arms = $self->{'arms'};
  if ($arm >= $arms) {
    return undef;
  }

  $x -= 1;
  if ($x < 0 || $x < $y) {
    return undef;
  }
  ### x adjust to zero: "$x,$y"
  ### assert: $x >= 0
  ### assert: $y >= 0

  # len=2*(2^level - 1)
  # len/2+1 = 2^level
  # 2^level = len/2+1
  # 2^(level+1) = len+2

  my ($len,$level) = _round_down_pow ($x+1, 2);
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }

  my $n = 0;
  my $nlen = ($len*$len-1)/3;

  foreach (2 .. $level) {
    ### at: "loop=$_   x=$x,y=$y  n=$n nlen=$nlen   len=$len diag cmp ".(2*$len-2)
    ### assert: $x >= 0
    ### assert: $y >= 0

    if ($x+$y <= 2*$len-2) {
      ### part 0 or 1...
      if ($x < $len-1) {
        ### part 0 ...
      } else {
        ### part 1 ...
        ($x,$y) = ($len-2-$y, $x-($len-1));   # shift then rotate +90
        $n += $nlen;
      }
    } else {
      $n += 2*$nlen + 1;  # +1 for middle point
      ### part 2 or 3 ...
      if ($y < $len) {
        ### part 2...
        ($x,$y) = ($y-1, 2*$len-2-$x);     # shift y-1 then rotate -90
      } else {
        #### digit 3...
        $x -= $len;
        $y -= $len;
        $n += $nlen;
      }
      if ($x < 0) {
        return undef;
      }
    }
    $len /= 2;
    $nlen = ($nlen-1)/4;
  }

  ### end at: "x=$x,y=$y   n=$n"
  ### assert: $x >= 0
  ### assert: $y >= 0

  if ($x == 0 && $y == 0) {
    ### final digit 0 ...
  } elsif ($x == 1 && $y == 0) {
    ### final digit 1 ...
    $n += 1;
  } elsif ($x == 1 && $y == 1) {
    ### final digit 2 ...
    $n += 2;
  } elsif ($x == 2 && $y == 1) {
    ### final digit 3 ...
    $n += 3;
  } elsif ($x == 2 && $y == 2) {
    ### final digit 4 ...
    $n += 4;
  } elsif ($x == 1 && $y == 2) {
    ### final digit 5 ...
    $n += 5;
  } else {
    return undef;
  }

  return $n*$arms + $arm;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageSierpinskiCurveSquare rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  #            x2
  # y2 +-------+      *
  #    |       |    *
  # y1 +-------+  *
  #             *
  #           *
  #         *
  #       ------------------
  #
  #
  #               *
  #   x1    *  x2 *
  #    +-----*-+y2*
  #    |      *|  *
  #    |       *  *
  #    |       |* *
  #    |       | **
  #    +-------+y1*
  #   ----------------
  #
  my $arms = $self->{'arms'};
  if (($arms <= 4
       ? ($y2 < 0  # y2 negative, nothing ...
          || ($arms == 1 && $x2 <= $y1)
          || ($arms == 2 && $x2 < 0)
          || ($arms == 3 && $x2 < -$y2))

       # arms >= 5
       : ($y2 < 0
          && (($arms == 5 && $x1 >= $y2)
              || ($arms == 6 && $x1 >= 0)
              || ($arms == 7 && $x1 > 3-$y2))))) {
    ### rect outside octants, for arms: $arms
    ### $x1
    ### $y2
    return (1,0);
  }

  my $max = $x2;
  if ($arms >= 2) {
    _apply_max ($max, $y2-1);

    if ($arms >= 4) {
      _apply_max ($max, 1-$x1);

      if ($arms >= 6) {
        _apply_max ($max, 1-$y1);
      }
    }
  }
  ### $max

  my ($len, $level) = _round_down_pow ($max,
                                       2);


  # points = (4^(level+2) - 1) / 3
  return (0, (4*$len*$len - 4)/3 * $arms);
}

sub _apply_max {
  ### _apply_max(): "$_[0] cf $_[1]"
  unless ($_[0] > $_[1]) {
    $_[0] = $_[1];
  }
}

1;
__END__

=for stopwords eg Ryde Waclaw Sierpinski Sierpinski's Math-PlanePath Nlevel CornerReplicate Nend Ntop Xlevel

=head1 NAME

Math::PlanePath::MathImageSierpinskiCurveSquare -- Sierpinski curve

=head1 SYNOPSIS

 use Math::PlanePath::MathImageSierpinskiCurveSquare;
 my $path = Math::PlanePath::MathImageSierpinskiCurveSquare->new (arms => 2);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This is a variation on the SierpinskiCurve with squared up diagonal sections.


    14  |                                              84-85
        |                                               |  |
    13  |                                           82-83 ...
        |                                            |
    12  |                                        80-81
        |                                         |
    11  |                                        79-78
        |                                            |
    10  |                                  68-69    77-76
        |                                   |  |        |
     9  |                               66-67 70-71 74-75
        |                                |        |  |
     8  |                            64-65       72-73
        |                             |
     7  |                            63-62       55-54
        |                                |        |  |
     6  |                      20-21    61-60 57-56 53-52
        |                       |  |        |  |        |
     5  |                   18-19 22-23    59-58    50-51
        |                    |        |              |
     4  |                16-17       24-25       48-49
        |                 |              |        |
     3  |                15-14       27-26       47-46
        |                    |        |              |
     2  |           4--5    13-12 29-28    36-37    45-44
        |           |  |        |  |        |  |        |
     1  |        2--3  6--7 10-11 30-31 34-35 38-39 42-43
        |        |        |  |        |  |        |  |
    Y=0 |     0--1        8--9       32-33       40-41
        |
        +----------------------------------------------------
           ^
          X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16

The tiling etc is the same as the SierpinskiCurve, but a diagonal part
becomes 4 segments instead of 3.  So in the following start of the
SierpinskiCurve N=0 to N=1 corresponds to N=0 to N=4, and N=2 to N=3
corresponds to N=5 to N=9.  The point N=10 (and similar at N=31, N=42, etc)
is an extra in between sides at the same angle

                7--                    20-
              /                         |
             6                      16--
             |                       |
             5                      15--
              \                         |
       1--2     4             4--5  10-11
     /     \  /               |  |  |
    0        3             0--    --9

=head2 Arms

The optional C<arms> parameter can give up to eight copies curves, each
advancing successively.  For example C<arms =E<gt> 8>,


                   ..--90       89--..                      7
                        |        |
                       82-74 73-81                          6
                           |  |
                       58-66 65-57                          5
                        |        |
                    42-50       49-41                       4
                     |              |
                    34-26       25-33                       3
                        |        |
     ...      43-35    18-10  9-17    32-40       ..        2
      |        |  |        |  |        |  |        |
     91-83 59-51 27-19     2  1    16-24 48-56 80-88        1
         |  |        |              |        |  |
        75-67       11--3     .  0--8       64-72      <- Y=0

        76-68       12--4        7-15       71-79          -1
         |  |        |              |        |  |
     92-84 60-52 28-20     5  6    23-31 55-63 87-95       -2
      |        |  |        |  |        |  |        |
     ..       44-36    21-13 14-22    39-47       ..       -3
                        |        |
                    37-29       30-38                      -4
                     |              |
                    45-53       54-46                      -5
                        |        |
                       61-69 70-62                         -6
                           |  |
                       85-77 78-86                         -7
                        |        |
                   ..--93       94--..                     -8

                                 ^
     -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

The middle "." is the origin X=0,Y=0.  It would be more symmetrical to make
the origin the middle of the eight arms, at X=-0.5,Y=-0.5 in the above, but
that would give fractional X,Y values.  Apply an offset as X+0.5,Y+0.5 if
desired.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageSierpinskiCurveSquare-E<gt>new ()>

=item C<$path = Math::PlanePath::MathImageSierpinskiCurveSquare-E<gt>new (arms =E<gt> 8)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SierpinskiCurve>

=cut
