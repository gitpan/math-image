# xy_to_n() not done ?


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


# math-image --path=MathImageQuintetCentres --lines --scale=10
# math-image --path=MathImageQuintetCentres --all --output=numbers_dash


package Math::PlanePath::MathImageQuintetCentres;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 72;

# inherit new(), rect_to_n_range(), arms_count(), n_start(),
# parameter_info_array()
use Math::PlanePath::MathImageQuintetCurve;
@ISA = ('Math::PlanePath::MathImageQuintetCurve');

use Math::PlanePath;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

my @rot_to_x = (0,0,-1,-1);
my @rot_to_y = (0,1,1,0);
my @rot_to_sx = (1,0,-1,0);
my @rot_to_sy = (0,1,0,-1);
my @digit_reverse = (0,1,0,0,1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### QuintetCentres n_to_xy(): $n

  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  my $arms = $self->{'arms'};
  {
    my $int = int($n);
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+$arms);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my $rot = $n % $arms;
  $n = int($n/$arms);

  my @digits;
  my @sx;
  my @sy;
  {
    my $sx = $rot_to_sx[$rot];
    my $sy = $rot_to_sy[$rot];
    while ($n) {
      push @digits, ($n % 5);
      push @sx, $sx;
      push @sy, $sy;
      $n = int($n/5);

      # 2*(sx,sy) + rot+90(sx,sy)
      ($sx,$sy) = (2*$sx - $sy,
                   2*$sy + $sx);
    }
    ### @digits
    my $rev = 0;
    for (my $i = $#digits; $i >= 0; $i--) {  # high to low
      ### digit: $digits[$i]
      if ($rev) {
        ### reverse: "$digits[$i] to ".(5 - $digits[$i])
        $digits[$i] = 4 - $digits[$i];
      }
      $rev ^= $digit_reverse[$digits[$i]];
      ### now rev: $rev
    }
  }
  ### reversed n: @digits


  my $x = 0;
  my $y = 0;
  my $ox = 0;
  my $oy = 0;
  # my $rot = 0;

  while (defined (my $digit = shift @digits)) {  # low to high
    my $sx = shift @sx;
    my $sy = shift @sy;
    ### at: "$x,$y  digit $digit   side $sx,$sy"

    # if ($rot & 2) {
    #   ($sx,$sy) = (-$sx,-$sy);
    # }
    # if ($rot & 1) {
    #   ($sx,$sy) = (-$sy,$sx);
    # }

    if ($digit == 0) {
      $x -= $sx;   # left at 180
      $y -= $sy;

    } elsif ($digit == 1) {
      # centre
      ($x,$y) = (-$y,$x);      # rotate -90
      ### rotate to: "$x,$y"
      # $rot--;

    } elsif ($digit == 2) {
      $x += $sy;   # down at -90
      $y -= $sx;
      ### offset to: "$x,$y"

    } elsif ($digit == 3) {
      ($x,$y) = (-$y,$x);      # rotate -90
      $x += $sx;   # right at 0
      $y += $sy;
      # $rot++;

    } else {  # $digit == 4
      ($x,$y) = ($y,-$x);      # rotate +90
      $x -= $sy;   # up at +90
      $y += $sx;
      # $rot++;
    }

    $ox += $sx;
    $oy += $sy;
  }

  ### final: "$x,$y  origin $ox,$oy"
  return ($x + $ox + $rot_to_x[$rot],
          $y + $oy + $rot_to_y[$rot]);
}


# uncomment this to run the ### lines
#use Devel::Comments;


# modulus 2*X+Y
#              3
#          0   2   4
#         /    1
#   X=0,Y=0
#
my @modulus_to_x = (0,1,1,1,2);
my @modulus_to_y = (0,-1,0,1,0);

my @modulus_to_digit
  = (0,2,1,4,3,    0,0,10,30,20,     #  0  base
     0,4,3,1,2,    0,10,50,40,10,    # 10
     4,0,1,3,2,    60,20,40,50,20,   # 20  rotated +90
     2,1,3,4,0,    30,60,0,30,50,    # 30
     1,0,3,2,4,    30,20,70,40,40,   # 40
     3,4,1,2,0,    70,10,30,50,50,   # 50  rotated +180
     4,2,3,0,1,    60,60,20,70,10,   # 60
     2,3,1,0,4,    70,0,60,70,40,    # 70  rotated +270
    );
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### QuintetCentres xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my $level_limit = log($x*$x + $y*$y + 1) * 1 * 2;
  if (_is_infinite($x)) { return $level_limit; }

  my @digits;
  my $arm;
  my $state;
  for (;;) {
    if ($level_limit-- < 0) {
      ### oops, level limit ...
      return undef;
    }
    if ($x == 0) {
      if ($y == 0) {
        ### found first arm 0,0 ...
        $arm = 0;
        $state = 0;
        last;
      }
      if ($y == 1) {
        ### found second arm 0,1 ...
        $arm = 1;
        $state = 20;
        last;
      }
    } elsif ($x == -1) {
      if ($y == 1) {
        ### found third arm -1,1 ...
        $arm = 2;
        $state = 50;
        last;
      }
      if ($y == 0) {
        ### found fourth arm -1,0 ...
        $arm = 3;
        $state = 70;
        last;
      }
    }
    my $m = (2*$x + $y) % 5;
    ### at: "$x,$y   digits=".join(',',@digits)
    ### mod remainder: $m

    $x -= $modulus_to_x[$m];
    $y -= $modulus_to_y[$m];
    push @digits, $m;

    ### digit: "$m  to $x,$y"
    ### shrink to: ((2*$x + $y) / 5).','.((2*$y - $x) / 5)
    ### assert: (2*$x + $y) % 5 == 0
    ### assert: (2*$y - $x) % 5 == 0

    # shrink
    # (2 -1)  inverse (2  1)
    # (1 2)           (-1 2)
    #
    ($x,$y) = ((2*$x + $y) / 5,
               (2*$y - $x) / 5);
  }

  ### @digits
  my $arms = $self->{'arms'};
  if ($arm >= $arms) {
    return undef;
  }

  my $n = 0;
  foreach my $m (reverse @digits) {  # high to low
    ### $m
    ### digit: $modulus_to_digit[$state + $m]
    ### state: $state
    ### next state: $modulus_to_digit[$state+5 + $m]

    $n = 5*$n + $modulus_to_digit[$state + $m];
    $state = $modulus_to_digit[$state+5 + $m];
  }
  ### final n along arm: $n

  return $n*$arms + $arm;
}

1;
__END__

=for stopwords eg Ryde Mandelbrot Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageQuintetCentres -- self-similar "plus" shape centres

=head1 SYNOPSIS

 use Math::PlanePath::MathImageQuintetCentres;
 my $path = Math::PlanePath::MathImageQuintetCentres->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This a self-similar curve tracing out a "+" shape like the QuintetCurve but
taking the centre of each square visited by that curve.

                                         92                        12
                                       /  |
            124-...                  93  91--90      88            11
              |                        \       \   /   \
        122-123 120     102              94  82  89  86--87        10
           \   /  |    /  |            /   /  |       |
            121 119 103 101-100      95  81  83--84--85             9
                   \   \       \       \   \
        114-115-116 118 104  32  99--98  96  80  78                 8
          |       |/   /   /  |       |/      |/   \
    112-113 110 117 105  31  33--34  97  36  79  76--77             7
       \   /   \       \   \       \   /   \      |
        111     109-108 106  30  42  35  38--37  75                 6
                      |/   /   /  |       |    /
                    107  29  43  41--40--39  74                     5
                           \   \              |
                 24--25--26  28  44  46  72--73  70      68         4
                  |       |/      |/   \   \   /   \   /   \
             22--23  20  27  18  45  48--47  71  56  69  66--67     3
               \   /   \   /   \      |        /   \      |
                 21   6  19  16--17  49  54--55  58--57  65         2
                   /   \      |       |    \      |    /
              4-- 5   8-- 7  15      50--51  53  59  64             1
               \      |    /              |/      |    \
          0-- 1   3   9  14              52      60--61  63     <- Y=0
              |/      |    \                          |/
              2      10--11  13                      62            -1
                          |/
                         12                                        -2

          ^
     -1  X=0  1   2   3   4   5   6   7   8   9  10  11  12  13

The base figure is "+" shape of the initial N=0 to N=4,

           .....
           .   .
           . 4 .
           .  \.
       ........\....
       .   |   .\  .
       . 0---1 . 3 .
       .   | | ./  .
       ......|./....
           . |/.
           . 2 .
           .   .
           .....

=head2 Arms

The optional C<arms> parameter can give up to four copies of the curve, each
advancing successively.  For example C<arms=E<gt>4> is as follows.  Notice
the N=4*k points are the plain curve, and N=4*k+1, N=3*k+2 and N=3*k+3 are
rotated copies of it.

                         69                     ...              7
                       /  |                        \
        121     113  73  65--61      53             120          6
       /   \   /   \   \       \   /   \           /
    ...     117 105-109  77  29  57  45--49     116              5
                  |    /   /  |       |            \
                101  81  25  33--37--41  96-100-104 112          4
                  |    \   \              |       |/
             50  97--93  85  21  13  88--92  80 108  72          3
           /  |       |/      |/   \   \   /   \   /   \
         54  46--42  89  10  17   5-- 9  84  24  76  64--68      2
           \      |    /  |       |        /   \      |
             58  38  14   6-- 2   1  16--20  32--28  60          1
           /      |    \               \      |    /
         62  30--34  22--18   3   0-- 4  12  36  56          <- Y=0
          |    \   /          |       |/      |    \
     70--66  78  26  86  11-- 7  19   8  91  40--44  52         -1
       \   /   \   /   \   \   /  |    /  |       |/
         74 110  82  94--90  15  23  87  95--99  48             -2
           /  |       |            \   \      |
        114 106-102--98  43--39--35  27  83 103                 -3
           \              |       |/   /      |
            118      51--47  59  31  79 111-107 119     ...     -4
           /           \   /   \       \   \   /   \   /
        122              55      63--67  75 115     123         -5
           \                          |/
            ...                      71                         -6

                                  ^
     -7  -6  -5  -4  -3  -2  -1  X=0  1   2   3   4   5   6

The pattern an ever expanding "+" shape with first cell N=0 at the origin.
The further parts are effectively as follows, though with wiggly spiralling
sides.  Four parts mesh together and fill the plane.

                +---+
                |   |
        +---+---    +---+
        |   |           |
    +---+   +---+   +---+
    |         2 | 1 |   |
    +---+   +---+---+   +---+
        |   | 3 | 0         |
        +---+   +---+   +---+
        |           |   |
        +---+   +---+---+
            |   |
            +---+

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageQuintetCentres-E<gt>new ()>

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
L<Math::PlanePath::Flowsnake>

=cut
