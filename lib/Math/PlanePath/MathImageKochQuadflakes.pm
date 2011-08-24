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


# math-image --path=MathImageKochQuadflakes --lines --scale=10
# math-image --path=MathImageKochQuadflakes --all --output=numbers_dash --size=132x50

# area approaches sqrt(48)/10


package Math::PlanePath::MathImageKochQuadflakes;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 68;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve;
*_round_down_pow3 = \&Math::PlanePath::KochCurve::_round_down_pow3;

# uncomment this to run the ### lines
#use Devel::Comments;


# level 0 inner square
# sidelen = 4^level
# ring points 4*4^level
# Nend = 4 * [ 1 + ... + 4^level ]
#      = 4 * (4^(level+1) - 1) / 3
#      = (4^(level+2) - 4) / 3
# Nstart = Nend(level-1) + 1
#        = (4^(level+1) - 4) / 3 + 1
#        = (4^(level+1) - 4 + 3) / 3
#        = (4^(level+1) - 1) / 3
#
# level    Nstart             Nend
#    0     (4-1)/3=1          (16-4)/3=12/3=4
#    1     (16-1)/3=15/3=5    (64-4)/3=60/3=20
#    2     (64-1)/3=63/3=21   (256-4)/3=252/3=84
#    3     (256-1)/3=255/3=85
#
# (4^(level+1) - 1) / 3 = N
# 4^(level+1) - 1 = 3*N
# 4^(level+1) = 3*N+1


sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageKochQuadflakes n_to_xy(): $n
  if ($n < 1) { return; }

  my $out = (! $self->{'inout'}
             || $self->{'inout'} eq 'out');

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  my ($pow,$level) = _round_down_pow4(3*$n + 1);
  ### $level
  ### $pow
  if (_is_infinite($level)) { return ($level,$level); }

  $n -= ($pow-1)/3;
  ### base: ($pow-1)/3
  ### next base would be: (4*$pow-1)/3
  ### n from base: $n

  my $sidelen = $pow/4;
  my $rot = int ($n / $sidelen);
  $n %= $sidelen;
  ### $sidelen
  ### n remainder: $n
  ### $rot

  ### assert: $n>=0
  ### assert: $n < 4 ** $level

  my @horiz = (1);
  my @diag = (1);
  my @digits;
  my $i = 0;
  while (--$level > 0) {
    push @digits, ($n % 4);
    $n = int($n/4);
    $horiz[$i+1] = 2*$horiz[$i] + 2*$diag[$i];
    $diag[$i+1]  = $horiz[$i] + 2*$diag[$i];
    $i++;
  }

  ### pow/8: $pow/8
  ### horiz: join(', ',@horiz)
  ### $i
  my $x = my $y = $horiz[$i]/-2;
  if ($rot & 1) {
    ($x,$y) = (-$y,$x)
  }
  if ($rot & 2) {
    $x = -$x;
    $y = -$y;
  }
  $rot *= 2;

  while (defined (my $digit = pop @digits)) {
    my ($dx, $dy, $drot);
    $i--;
    if ($digit == 0) {
      $dx = 0;
      $dy = 0;
      $drot = 0;
    } elsif ($digit == 1) {
      if ($rot & 1) {
        $dx = $diag[$i];
        $dy = $diag[$i];
      } else {
        $dx = $horiz[$i];
        $dy = 0;
      }
      $drot = ($out ? -1 : 1);
    } elsif ($digit == 2) {
      if ($rot & 1) {
        if ($out) {
          $dx = $diag[$i] + $horiz[$i];
          $dy = $diag[$i];
        } else {
          $dx = $diag[$i];
          $dy = $diag[$i] + $horiz[$i];
        }
      } else {
        $dx = $horiz[$i] + $diag[$i];
        $dy = $diag[$i];
        if ($out) { $dy = -$dy; }
      }
      $drot = ($out ? 1 : -1);
    } elsif ($digit == 3) {
      if ($rot & 1) {
        $dx = $dy = $diag[$i] + $horiz[$i];
      } else {
        $dx = $horiz[$i] + 2*$diag[$i];
        $dy = 0;
      }
      $drot = 0;
    }
    ### delta: "$dx,$dy   rot=$rot   drot=$drot"

    if ($rot & 2) {
      ($dx,$dy) = (-$dy,$dx)
    }
    if ($rot & 4) {
      $dx = -$dx;
      $dy = -$dy;
    }
    ### delta with rot: "$dx,$dy"

    $x += $dx;
    $y += $dy;
    $rot += $drot;
  }

  {
    my $dx = $frac;
    my $dy = ($rot & 1 ? $frac : 0);
    if ($rot & 2) {
      ($dx,$dy) = (-$dy,$dx)
    }
    if ($rot & 4) {
      $dx = -$dx;
      $dy = -$dy;
    }
    $x += $dx;
    $y += $dy;
  }

  return ($x,$y);
}

my @inner_to_n = (1,2,4,3);

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MathImageKochQuadflakes xy_to_n(): "$x, $y"

  return undef;






  if (abs($x) <= .75 && abs($y) <= .75) {
    return $inner_to_n[($x >= 0) + 2*($y >= 0)];
  }
  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my $high;
  if ($x >= $y + ($y>0)) {
    # +($y>0) to exclude the downward bump of the top side
    ### below leading diagonal ...
    if ($x < -$y) {
      ### bottom quarter ...
      $high = 0;
    } else {
      ### right quarter ...
      $high = 1;
      ($x,$y) = ($y, -$x);   # rotate -90
    }
  } else {
    ### above leading diagonal
    if ($y > -$x) {
      ### top quarter ...
      $high = 2;
      $x = -$x;   # rotate 180
      $y = -$y;
    } else {
      ### right quarter ...
      $high = 3;
      ($x,$y) = (-$y, $x);   # rotate +90
    }
  }
  ### rotate to: "$x,$y   high=$high"

  # ymax = (10*4^(l-1)-1)/3
  # ymax < (10*4^(l-1)-1)/3+1
  # (10*4^(l-1)-1)/3+1 > ymax
  # (10*4^(l-1)-1)/3 > ymax-1
  # 10*4^(l-1)-1 > 3*(ymax-1)
  # 10*4^(l-1) > 3*(ymax-1)+1
  # 10*4^(l-1) > 3*(ymax-1)+1
  # 10*4^(l-1) > 3*ymax-3+1
  # 10*4^(l-1) > 3*ymax-2
  # 4^(l-1) > (3*ymax-2)/10
  #
  # (2*4^(l-1) + 1)/3 = ymin
  # 2*4^(l-1) + 1 = 3*y
  # 2*4^(l-1) = 3*y-1
  # 4^(l-1) = (3*y-1)/2
  #
  # ypos = 4^l/2 = 2*4^(l-1)


  # z = -2*y+x
  # (2*4**($level-1) + 1)/3 = z
  # 2*4**($level-1) + 1 = 3*z
  # 2*4**($level-1) = 3*z - 1
  # 4**($level-1) = (3*z - 1)/2
  #               = (3*(-2y+x)-1)/2
  #               = (-6y+3x - 1)/2
  #               = -3*y + (3x-1)/2

  # 2*4**($level-1) = -2*y-x
  # 4**($level-1) = -y-x/2
  # 4**$level = -4y-2x
  #
  # line slope y/x = 1/2 as an index
  my ($len,$level) = _round_down_pow4(-$y-$x/2);
  ### slope point: -$y-$x/2
  ### amin: 2*4**($level-1)
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }

  $len *= 2;
  $x += $len;
  $y += $len;
  ### shift to: "$x,$y"

  # Nmin = (4*8^l+3)/7
  # Nmin+high = (4*8^l+3)/7 + h*8^l
  #           = (4*8^l + 3 + 7h*8^l)/7 +
  #           = ((4+7h)*8^l + 3)/7
  #
  ### plain curve on: ($x+2*$len).",".($y+2*$len)."  give n=".(defined $n && $n)
  ### $high
  ### high: (8**$level)*$high
  ### base: (4 * 8**($level+1) + 3)/7
  ### base with high: ((4+7*$high) * 8**($level+1) + 3)/7

  # if (defined $n) {
  #   return ((4+7*$high) * 8**($level+1) + 3)/7 + $n;
  # } else {
  #   return undef;
  # }
}

# level width extends
#    side = 4^level
#    ypos = 4^l / 2
#    width = 1 + 4 + ... + 4^(l-1)
#          = (4^l - 1)/3
#    ymin = ypos(l) - 4^(l-1) - width(l-1)
#         = 4^l / 2  - 4^(l-1) - (4^(l-1) - 1)/3
#         = 4^(l-1) * (2 - 1 - 1/3) + 1/3
#         = (2*4^(l-1) + 1) / 3
#
#    (2*4^(l-1) + 1) / 3 = z
#    2*4^(l-1) + 1 = 3*z
#    2*4^(l-1) = 3*z-1
#    4^(l-1) = (3*z-1)/2
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageKochQuadflakes rect_to_n_range(): "$x1,$y1  $x2,$y2"

  # $x1 = _round_nearest ($x1);
  # $y1 = _round_nearest ($y1);
  # $x2 = _round_nearest ($x2);
  # $y2 = _round_nearest ($y2);

  my $m = max(1,
              abs($x1), abs($x2),
              abs($y1), abs($y2));
  my $level = ceil (log((3*$m+5)/2) / log(4));
  ### $level
  return (1, 4 * 8**($level+1) - 1);
}


# return ($pow, $exp) with $pow = 4**$exp <= $n, the next power of 4 at or
# below $n
sub _round_down_pow4 {
  my ($n) = @_;

  # Math::BigInt and Math::BigRat overloaded log() return NaN, use integer
  # based blog()
  my $exp = (ref $n && ($n->isa('Math::BigInt') || $n->isa('Math::BigRat'))
             ? $n->copy->blog(4)
             : int(log($n)/log(4)));
  my $pow = 4**$exp;
  ### n:   ref($n)."  $n"
  ### exp: ref($exp)."  $exp"
  ### pow: ref($pow)."  $pow"

  # check how $pow actually falls against $n, not sure should trust float
  # rounding in log()/log(4)
  if ($pow > $n) {
    ### hmm, int(log) too big, decrease...
    $exp -= 1;
    $pow = 4**$exp;
  } elsif (4*$pow <= $n) {
    ### hmm, int(log) too small, increase...
    $exp += 1;
    $pow *= 4;
  }
  return ($pow, $exp);
}

1;
__END__

=for stopwords eg Ryde ie Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageKochQuadflakes -- four-sided Koch snowflakes

=head1 SYNOPSIS

 use Math::PlanePath::MathImageKochQuadflakes;
 my $path = Math::PlanePath::MathImageKochQuadflakes->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This is the pattern of the Koch curve arranged as four sided concentric
snowflakes.

              ...                           15                     3
              /                            /  \
        75--74                      17--16      14--13             2
         |                           |               |
        76                          18              12             1
      /                           /       4 -- 3      \
    77                          19             |        11     <- Y=0
      \                           \       1 -- 2      /
        78                          20              10            -1
         |                                           |
        79--80                       5-- 6       8-- 9            -2
              \                            \   /
                81                           7                    -3
                 |
                82                                                -4
              /
            83                                                    -5
              \
                84                                                -6

                21--22      24--25                      33--...   -7
                      \   /       \                   /
                        23          26              32            -8
                                     |               |
                                    27--28      30--31            -9
                                          \   /
                                            29                   -10

                                             ^
    -10 -9  -8  -7  -6  -5  -4  -3  -2  -1  X=0  1   2   3

The innermost square of points N=1 to N=4 are on X=+/-0.5,Y=+/-0.5
fractions, the further points are integer X,Y on a square grid.

=head1 Inward

The C<inout> option can direct the sides inward instead of outward.  The
side lengths etc are the same.

    69--68      66--65                      57--56      54--53     7
     |    \   /       \                   /       \   /      |
    70      67          64              58          55      52     6
      \                  |               |                /
        71              63--62      60--59              51         5
      /                       \   /                       \
    72                          61                          50     4
     |                                                       |
    73                                                      49     3
      \                                                   /
        74--75          17--16      14--13          47--48         2
             |           |    \   /      |           |
            76          18      15      12          46             1
              \           \    4--3   /           /
                77          19    | 11          45             <- Y=0
              /           /    1--2   \           \
            78          20       7      10          44            -1
             |                /   \      |           |
        80--79           5-- 6       8-- 9          43--42        -2
      /                                                   \
    81                                                      41    -3
     |                                                       |
    82                          29                          40    -4
      \                       /   \                       /
        83              27--28      30--31              39        -5
      /                  |               |                \
    84      23          26              32          35      38    -6
          /   \       /                   \       /   \      |
    21--22      24--25                      33--34      36--37    -7

                                 ^
    -7  -6  -5  -4  -3  -2  -1  X=0  1   2   3   4   5   6   7


=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageKochQuadflakes-E<gt>new ()>

=item C<$path = Math::PlanePath::MathImageKochQuadflakes-E<gt>new (inout =E<gt> $enum)>

Create and return a new path object.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::KochSnowflakes>

=cut
