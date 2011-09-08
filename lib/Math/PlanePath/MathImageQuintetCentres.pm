# rect_to_n_range() not done
# xy_to_n() not done


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
$VERSION = 69;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 4) { $arms = 4; }
  $self->{'arms'} = $arms;
  return $self;
}

my @rot_to_x = (0,0,-1,-1);
my @rot_to_y = (0,1,1,0);
my @rot_to_sx = (1,0,-1,0);
my @rot_to_sy = (0,1,0,-1);
my @digit_reverse = (0,1,0,0,1,0);

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

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### QuintetPeaks xy_to_n(): "$x, $y"

  return undef;

  $x = _round_nearest($x);
  $y = _round_nearest($y);
  if ($y < 0 || $x < 0 || (($x ^ $y) & 1)) {
    ### neg y or parity different ...
    return undef;
  }
  my ($len,$level) = _round_down_pow3(($x/2)||1);
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }

  my $n = 0;
  foreach (0 .. $level) {
    $n *= 4;
    ### at: "level=$level len=$len   x=$x,y=$y  n=$n"
    if ($x < 3*$len) {
      if ($x < 2*$len) {
        ### digit 0 ...
      } else {
        ### digit 1 ...
        $x -= 2*$len;
        ($x,$y) = (($x+3*$y)/2,   # rotate -60
                   ($y-$x)/2);
        $n++;
      }
    } else {
      $x -= 4*$len;
      ### digit 2 or 3 to: "x=$x"
      if ($x < $y) {   # before diagonal
        ### digit 2...
        $x += $len;
        $y -= $len;
        ($x,$y) = (($x-3*$y)/2,     # rotate +60
                   ($x+$y)/2);
        $n += 2;
      } else {
        #### digit 3...
        $n += 3;
      }
    }
    $len /= 3;
  }
  ### end at: "x=$x,y=$y   n=$n"
  if ($x != 0 || $y != 0) {
    return undef;
  }
  return $n;
}

# level extends to x= 2*3^level
#                  level = log3(x/2)
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### QuintetCentres rect_to_n_range(): "$x1,$y1  $x2,$y2"

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
  if ($y2 < 0  || $x2 < $y1) {
    ### outside first octant
    return (1,0);
  }
  if (_is_infinite($x2)) {
    return (0, $x2);
  }

  my $n_lo = 1;
  my $w = 2;
  while ($w < $x1) {
    $n_lo *= 4;
    $w = 2*$w + 2;
  }

  my $n_hi = 1;
  $w = 0;
  while ($w < $x2) {
    $n_hi *= 4;
    $w = 2*$w + 2;
  }

  return ($n_lo-1, $n_hi * $self->{'arms'});
}

1;
__END__

=for stopwords eg Ryde Mandelbrot Math-PlanePath Nlevel

=head1 NAME

Math::PlanePath::MathImageQuintetCentres -- "plus" shape centres

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
