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


# math-image --path=MathImageKochSquareflakes --lines --scale=10
# math-image --path=MathImageKochSquareflakes --all --output=numbers_dash --size=132x50


# horiz: 1, 4, 14, 48, 164, 560, 1912, 6528, 22288, 76096, 259808, 887040
# A007070 a(n+1) = 4*a(n) - 2*a(n-1), starting 1,4
#
# diag:  1, 3, 10, 34, 116, 396, 1352, 4616, 15760, 53808, 183712, 627232
# A007052 a(n+1) = 4*a(n) - 2*a(n-1), starting 1,3
#
# cf A006012 same recurrence, start 1,2


package Math::PlanePath::MathImageKochSquareflakes;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 69;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;


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

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageKochSquareflakes n_to_xy(): $n
  if ($n < 1) { return; }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  # (4^(level+1) - 1) / 3 = N
  # 4^(level+1) - 1 = 3*N
  # 4^(level+1) = 3*N+1
  #
  my ($pow,$level) = _round_down_pow (3*$n + 1, 4);

  ### $level
  ### $pow
  if (_is_infinite($level)) { return ($level,$level); }

  # Nstart = (4^(level+1)-1)/3 with $power=4^(level+1) here
  #
  $n -= ($pow-1)/3;

  ### base: ($pow-1)/3
  ### next base would be: (4*$pow-1)/3
  ### n remainder from base: $n

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

  my $inward = $self->{'inward'};

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
      $drot = ($inward ? 1 : -1);
    } elsif ($digit == 2) {
      if ($rot & 1) {
        if ($inward) {
          $dx = $diag[$i];
          $dy = $diag[$i] + $horiz[$i];
        } else {
          $dx = $diag[$i] + $horiz[$i];
          $dy = $diag[$i];
        }
      } else {
        $dx = $horiz[$i] + $diag[$i];
        $dy = $diag[$i];
        unless ($inward) { $dy = -$dy; }
      }
      $drot = ($inward ? -1 : 1);
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
  ### MathImageKochSquareflakes xy_to_n(): "$x, $y"

  if (4*$x < 3 && 4*$y < 3 && 4*$x >= -3 && 4*$y >= -3) {
    return $inner_to_n[($x >= 0) + 2*($y >= 0)];
  }

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  # quarter curve segment and high digit
  my $n;
  {
    my $negx = -$x;
    if (($y > 0 ? $x > $y : $x >= $y)) {
      ### below leading diagonal ...
      if ($negx > $y) {
        ### bottom quarter ...
        $n = 1;
      } else {
        ### right quarter ...
        $n = 2;
        ($x,$y) = ($y, $negx);   # rotate -90
      }
    } else {
      ### above leading diagonal
      if ($y > $negx) {
        ### top quarter ...
        $n = 3;
        $x = $negx;   # rotate 180
        $y = -$y;
      } else {
        ### right quarter ...
        $n = 4;
        ($x,$y) = (-$y, $x);   # rotate +90
      }
    }
  }
  $y = -$y;
  ### rotate to: "$x,$y   n=$n"

  if (_is_infinite($x)) {
    return $x;
  }
  if (_is_infinite($y)) {
    return $y;
  }

  my @horiz;
  my @diag;
  my $horiz = 1;
  my $diag = 1;
  for (;;) {
    push @horiz, $horiz;
    push @diag, $diag;
    my $offset = $horiz+$diag;
    my $nextdiag = $offset + $horiz;  # 2*horiz + diag
    if ($y <= $nextdiag) {
      ### found level at: "top=$nextdiag vs y=$y"
      $y -= $offset;
      $x += $offset;
      last;
    }
    $horiz = 2*$offset;
    $diag = $nextdiag;
  }


  if ($self->{'inward'}) {
    $y = -$y;
  }

  ### origin based side: "$x,$y   horiz=$horiz diag=$diag  with levels ".scalar(@horiz)

  # loop 4*1, 4*4, 4*4^2 etc, extra +1 on the digits to include that in the sum
  #
  my $slope;
  while (@horiz) {
    ### at: "$x,$y slope=".($slope||0)." n=$n"
    $horiz = pop @horiz;
    $diag = pop @diag;
    $n *= 4;

    if ($slope) {
      if ($x < $diag) {
        ### digit 0 ...
        $n += 1;
      } else {
        $x -= $diag;
        $y -= $diag;

        if ($y < $horiz) {
          ### digit 1 ...
          $n += 2;
          ($x,$y) = ($y, -$x);   # rotate -90
          $slope = 0;
        } else {
          $y -= $horiz;

          if ($x < $horiz) {
            ### digit 2 ...
            $n += 3;
            $slope = 0;

          } else {
            ### digit 3 ...
            $n += 4;
            $x -= $horiz;
          }
        }
      }

    } else {
      if ($x < $horiz) {
        ### digit 0 ...
        $n += 1;
      } else {
        $x -= $horiz;
        ### not digit 0 to: "$x,$y"

        if ($x < $diag) {
          ### digit 1 ...
          $n += 2;
          $slope = 1;
        } else {
          $x -= $diag;
          ### not digit 1 to: "$x,$y"

          if ($x < $diag) {
            ### digit 2 ...
            $n += 3;
            $slope = 1;
            ($x,$y) = ($diag-$y, $x);   # offset and rotate +90

          } else {
            ### digit 3 ...
            $n += 4;
            $x -= $diag;
          }
        }
      }
    }
  }
  ### final: "$x,$y n=$n"

  if ($x == 0 && $y == 0) {
    return $n;
  } else {
    return 0;
  }
  return undef;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageKochSquareflakes rect_to_n_range(): "$x1,$y1  $x2,$y2"

  foreach my $c ($x1,$y1, $x2,$y2) {
    if (_is_infinite($c)) {
      return (0, $c);
    }
    $c = abs(_round_nearest($c));
  }
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }
  my $max = ($x2 > $y2 ? $x2 : $y2);

  # Nend = 4 * [ 1 + ... + 4^level ]
  #      = 4 + 16 + ... + 4^(level+1)
  #
  my $horiz = 4;
  my $diag = 3;
  my $nhi = 4;
  for (;;) {
    $nhi += 1;
    $nhi *= 4;
    my $nextdiag = $horiz + 2*$diag;
    if (($self->{'inward'} ? $horiz : $nextdiag) >= 2*$max) {
      return (1, $nhi);
    }
    $horiz = $nextdiag + $horiz;   # 2*$horiz + 2*$diag;
    $diag = $nextdiag;
  }
}


1;
__END__

=for stopwords eg Ryde ie Math-PlanePath Koch

=head1 NAME

Math::PlanePath::MathImageKochSquareflakes -- four-sided Koch snowflakes

=head1 SYNOPSIS

 use Math::PlanePath::MathImageKochSquareflakes;
 my $path = Math::PlanePath::MathImageKochSquareflakes->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This is the Koch curve pattern arranged as concentric four-sided snowflakes.

                                  61                                10
                                 /  \
                            63-62    60-59                           9
                             |           |
                   67       64          58       55                  8
                  /  \     /              \     /  \
             69...    66-65                57-56    54-53            7
              |                                         |
             70                                        52            6
            /                                            \
          71                                              51         5
            \                                            /
             72                                        50            4
              |                                         |
             73                   15                   49            3
            /                    /  \                    \
       75-74                17-16    14-13                48-47      2
        |                    |           |                    |
       76                   18          12                   46      1
      /                    /     4---3    \                    \
    77                   19        . |     11                   45  Y=0
      \                    \     1---2    /                    /
       78                   20          10                   44     -1
        |                                |                    |
       79-80                 5--6     8--9                42-43     -2
            \                    \  /                    /
             81                    7                   41           -3
              |                                         |
             82                                        40           -4
            /                                            \
          83                                              39        -5
            \                                            /
             84                                        38           -6
                                                        |
             21-22    24-25                33-34    36-37           -7
                  \  /     \              /     \  /
                   23       26          32       35                 -8
                             |           |
                            27-28    30-31                          -9
                                 \  /
                                  29                               -10

                                   ^
       -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9 10

The innermost square N=1 to N=4 is the initial figure.  Its sides expand in
the Koch curve pattern in subsequent rings.  The initial figure is on
X=+/-0.5,Y=+/-0.5 fractions but the points after that are integer X,Y.

=head1 Inward

The C<inward> option can direct the sides inward instead of outward.  The
shape and side lengths etc are the same.

    69-68    66-65                57-56    54-53     7
     |   \  /     \              /     \  /    |
    70    67       64          58       55    52     6
      \             |           |            /
       71          63-62    60-59          51        5
      /                 \  /                 \
    72                   61                   50     4
     |                                         |
    73                                        49     3
      \                                      /
       74-75       17-16    14-13       47-48        2
           |        |   \  /    |        |
          76       18    15  3 12       46           1
            \        \  4--3  /        /
             77       19   |11       45          <- Y=0
            /        /  1--2  \        \
          78       20     7    10       44          -1
           |            /  \    |        |
       80-79        5--6     8--9       43-42       -2
      /                                      \
    81                                        41    -3
     |                                         |
    82                   29                   40    -4
      \                 /  \                 /
       83          27-28    30-31          39       -5
      /             |           |            \
    84    23       26          32       35    38    -6
         /  \     /              \     /  \    |
    21-22    24-25                33-34    36-37    -7

                          ^
    -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7

=head2 Level Ranges

Counting the innermost N=1 to N=4 square as level 0, a given level has

    looplen = 4*4^level

many points.  The start of a level is therefore N=1 plus preceding loop
lengths,

    Nstart = 1 + 4*[ 1 + 4 + 4^2 + ... + 4^(level-1) ]
           = 1 + 4*(4^level - 1)/3
           = (4^(level+1) - 1)/3

and the end similarly as the total loop lengths inclusive, and also simply
one less than the next Nstart,

    Nend = 4 * [ 1 + ... + 4^level ]
         = (4^(level+2) - 4) / 3

         = Nstart(level+1) - 1

For example,

    level  Nstart   Nend
      0       1       4
      1       5      20
      2      21      84
      3      85     340

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageKochSquareflakes-E<gt>new ()>

=item C<$path = Math::PlanePath::MathImageKochSquareflakes-E<gt>new (inward =E<gt> $bool)>

Create and return a new path object.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::KochSnowflakes>

=cut







    #                             15                     3
    #                            /  \
    #                     17--16      14--13             2
    #                      |               |
    #                     18              12             1
    #                   /       4 -- 3      \
    #                 19             |        11     <- Y=0
    #                   \       1 -- 2      /
    #                     20              10            -1
    #                                      |
    #                      5-- 6       8-- 9            -2
    #                            \   /
    #                              7                    -3
    #
    #                                                   -4
    #
    #                                                   -5
    #
    # ...                                               -6
    #
    # 21--22      24--25                      33--...   -7
    #       \   /       \                   /
    #         23          26              32            -8
    #                      |               |
    #                     27--28      30--31            -9
    #                           \   /
    #                             29                   -10
