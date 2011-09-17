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


# math-image --path=MathImageQuintetCurve --lines --scale=10
# math-image --path=MathImageQuintetCurve --all --output=numbers_dash


package Math::PlanePath::MathImageQuintetCurve;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX 'ceil';
use Math::PlanePath::SacksSpiral;

use vars '$VERSION', '@ISA';
$VERSION = 70;

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

use constant parameter_info_array => [ { name      => 'arms',
                                         share_key => 'arms_4',
                                         type      => 'integer',
                                         minimum   => 1,
                                         maximum   => 4,
                                         default   => 1,
                                         width     => 1,
                                       } ];
sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 4) { $arms = 4; }
  $self->{'arms'} = $arms;
  return $self;
}

my @rot_to_sx = (1,0,-1,0);
my @rot_to_sy = (0,1,0,-1);
my @digit_reverse = (0,1,0,0,1,0);

sub n_to_xy {
  my ($self, $n) = @_;
  ### QuintetCurve n_to_xy(): $n

  if ($n < 0) {
    return;
  }
  my $arms = $self->{'arms'};
  if (_is_infinite($n)) {
    return ($n,$n);
  }

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
  $n = int(($n+$arms-1) / $arms);

  my @digits;
  my @sx;
  my @sy;
  {
    my $sx = 1; # $rot_to_sx[$rot];
    my $sy = 0; # $rot_to_sy[$rot];
    while ($n) {
      push @digits, ($n % 5);
      push @sx, $sx;
      push @sy, $sy;
      $n = int($n/5);

      # 2*(sx,sy) + rot+90(sx,sy)
      ($sx,$sy) = (2*$sx - $sy,
                   2*$sy + $sx);
    }
    # ### @digits
    # my $rev = 0;
    # for (my $i = $#digits; $i >= 0; $i--) {  # high to low
    #   ### digit: $digits[$i]
    #   if ($rev) {
    #     ### reverse: "$digits[$i] to ".(5 - $digits[$i])
    #     $digits[$i] = (5 - $digits[$i]) % 5;
    #   }
    #   #      $rev ^= $digit_reverse[$digits[$i]];
    #   ### now rev: $rev
  }
  #    ### reversed n: @digits


  my $x = 0;
  my $y = 0;
  my $rev = 0;

  while (defined (my $digit = pop @digits)) {  # high to low
    my $sx = pop @sx;
    my $sy = pop @sy;
    ### at: "$x,$y  digit $digit   side $sx,$sy"

    if ($rot & 2) {
      ($sx,$sy) = (-$sx,-$sy);
    }
    if ($rot & 1) {
      ($sx,$sy) = (-$sy,$sx);
    }

    if ($rev) {
      if ($digit == 0) {
        $rev = 0;
        $rot++;

      } elsif ($digit == 1) {
        $x -= $sy;
        $y += $sx;
        $rot++;

      } elsif ($digit == 2) {
        $x += -2*$sy;
        $y += 2*$sx;

      } elsif ($digit == 3) {
        $x += $sx - 2*$sy;    # add 2*rot-90(side) + side
        $y += $sy + 2*$sx;
        $rot--;
        $rev = 0;

      } else {  # $digit == 4
        $x += $sx - $sy;    # add rot-90(side) + side
        $y += $sy + $sx;
      }

    } else {
      # normal

      if ($digit == 0) {

      } elsif ($digit == 1) {
        $x += $sx;
        $y += $sy;
        $rot--;
        $rev = 1;

      } elsif ($digit == 2) {
        $x += $sx + $sy;    # add side + rot-90(side)
        $y += $sy - $sx;

      } elsif ($digit == 3) {
        $x += 2*$sx + $sy;
        $y += 2*$sy - $sx;
        $rot++;

      } else {  # $digit == 4
        $x += 2*$sx;
        $y += 2*$sy;
        $rot++;
        $rev = 1;
      }
    }
  }

  ### final: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### QuintetCurve xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my $level_limit = log($x*$x + $y*$y + 1) * 1 * 2;
  if (_is_infinite($level_limit)) { return $level_limit; }

  my $arms = $self->{'arms'};
  my @sx = (1);
  my @sy = (0);
  my @hypot = (5);
  my $top = 0;

  for (;;) {
  ARM: foreach my $arm (0 .. $arms-1) {
      my $i = 0;
      my @digits = (0);
      for (;;) {
        my $n = 0;
        foreach my $digit (reverse @digits) { # high to low
          $n = 5*$n + $digit;
        }
        $n = $n*$arms + $arm;
        ### consider: "i=$i  digits=".join(',',reverse @digits)."  is n=$n"

        my ($nx,$ny) = $self->n_to_xy($n);
        if ($i == 0 && $x == $nx && $y == $ny) {
          ### found
          return $n;
        }

        if ($i == 0
            || ($x-$nx) ** 2 + ($y-$ny) ** 2 > $hypot[$i]) {
          ### too far away: "$nx,$ny target $x,$y    ".(($x-$nx) ** 2 + * ($y-$ny) ** 2).' vs '.$hypot[$i]

          while (++$digits[$i] > 6) {
            $digits[$i] = 0;
            if (++$i <= $top) {
              ### backtrack up ...
            } else {
              ### not found within this arm and top ...
              next ARM;
            }
          }

        } else {
          ### descend
          ### assert: $i > 0
          $i--;
          $digits[$i] = 0;
        }
      }
    }

    if (++$top > $level_limit) {
      ### oops, not found below level limit
      return;
    }

    # 2*(sx,sy) + rot+90(sx,sy)
    #
    $sx[$top] = 2 * $sx[$top-1] - $sy[$top-1];
    $sy[$top] = 2 * $sy[$top-1] + $sx[$top-1];
    $hypot[$top] = 5 * $hypot[$top-1];
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### QuintetCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my ($r_lo, $r_hi) = Math::PlanePath::SacksSpiral::_rect_to_radius_range
    ($x1,$y1*sqrt(3), $x2,$y2*sqrt(3));
  $r_hi *= 2;
  my $level_plus_1 = ceil( log(max(1,$r_hi/4)) / log(sqrt(5)) ) + 2;
  # return (0, 5**$level_plus_1);


  my $level_limit = $level_plus_1;
  ### $level_limit
  if (_is_infinite($level_limit)) { return ($level_limit,$level_limit); }

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### sorted range: "$x1,$y1  $x2,$y2"

  my $rect_dist = sub {
    my ($x,$y) = @_;
    my $xd = ($x < $x1 ? $x1 - $x
              : $x > $x2 ? $x - $x2
              : 0);
    my $yd = ($y < $y1 ? $y1 - $y
              : $y > $y2 ? $y - $y2
              : 0);
    return ($xd*$xd + $yd*$yd);
  };

  my $arms = $self->{'arms'};
  ### $arms
  my $n_lo;
  {
    my @hypot = (4);
    my $top = 0;
    for (;;) {
    ARM_LO: foreach my $arm (0 .. $arms-1) {
        my $i = 0;
        my @digits;
        if ($top > 0) {
          @digits = ((0)x($top-1), 1);
        } else {
          @digits = (0);
        }

        for (;;) {
          my $n = 0;
          foreach my $digit (reverse @digits) { # high to low
            $n = 5*$n + $digit;
          }
          $n = $n*$arms + $arm;
          ### lo consider: "i=$i  digits=".join(',',reverse @digits)."  is n=$n"

          my ($nx,$ny) = $self->n_to_xy($n);
          my $nh = &$rect_dist ($nx,$ny);
          if ($i == 0 && $nh == 0) {
            ### lo found inside: $n
            if (! defined $n_lo || $n < $n_lo) {
              $n_lo = $n;
            }
            next ARM_LO;
          }

          if ($i == 0 || $nh > $hypot[$i]) {
            ### too far away: "nxy=$nx,$ny   nh=$nh vs ".$hypot[$i]

            while (++$digits[$i] > 4) {
              $digits[$i] = 0;
              if (++$i <= $top) {
                ### backtrack up ...
              } else {
                ### not found within this top and arm, next arm ...
                next ARM_LO;
              }
            }
          } else {
            ### lo descend ...
            ### assert: $i > 0
            $i--;
            $digits[$i] = 0;
          }
        }
      }

      # if an $n_lo was found on any arm within this $top then done
      if (defined $n_lo) {
        last;
      }

      ### lo extend top ...
      if (++$top > $level_limit) {
        ### nothing below level limit ...
        return (1,0);
      }
      $hypot[$top] = 5 * $hypot[$top-1];
    }
  }

  my $n_hi = 0;
 ARM_HI: foreach my $arm (reverse 0 .. $arms-1) {
    my @digits = ((4) x $level_limit);
    my $i = $#digits;
    for (;;) {
      my $n = 0;
      foreach my $digit (reverse @digits) { # high to low
        $n = 5*$n + $digit;
      }
      $n = $n*$arms + $arm;
      ### hi consider: "arm=$arm  i=$i  digits=".join(',',reverse @digits)."  is n=$n"

      my ($nx,$ny) = $self->n_to_xy($n);
      my $nh = &$rect_dist ($nx,$ny);
      if ($i == 0 && $nh == 0) {
        ### hi found inside: $n
        if ($n > $n_hi) {
          $n_hi = $n;
          next ARM_HI;
        }
      }

      if ($i == 0 || $nh > (4 * 5**$i)) {
        ### too far away: "$nx,$ny   nh=$nh vs ".(4 * 5**$i)

        while (--$digits[$i] < 0) {
          $digits[$i] = 4;
          if (++$i < $level_limit) {
            ### hi backtrack up ...
          } else {
            ### hi nothing within level limit for this arm ...
            next ARM_HI;
          }
        }

      } else {
        ### hi descend
        ### assert: $i > 0
        $i--;
        $digits[$i] = 4;
      }
    }
  }

  if ($n_hi == 0) {
    ### oops, lo found but hi not found
    $n_hi = $n_lo;
  }

  return ($n_lo, $n_hi);
}

1;
__END__

=for stopwords eg Ryde Mandelbrot Math-PlanePath Nlevel

=head1 NAME

Math::PlanePath::MathImageQuintetCurve -- self-similar  "plus" shaped curve

=head1 SYNOPSIS

 use Math::PlanePath::MathImageQuintetCurve;
 my $path = Math::PlanePath::MathImageQuintetCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This path is a self-similar curve tracing out a "+" shape,

             ...                     93--92                      11
              |                       |   |
        123-124                      94  91--90--89--88          10
          |                           |               |
        122-121-120 103-102          95  82--83  86--87           9
                  |   |   |           |   |   |   |
        115-116 119 104 101-100--99  96  81  84--85               8
          |   |   |   |           |   |   |
    113-114 117-118 105  32--33  98--97  80--79--78               7
      |               |   |   |                   |
    112-111-110-109 106  31  34--35--36--37  76--77               6
                  |   |   |               |   |
                108-107  30  43--42  39--38  75                   5
                          |   |   |   |       |
                 25--26  29  44  41--40  73--74                   4
                  |   |   |   |           |
             23--24  27--28  45--46--47  72--71--70--69--68       3
              |                       |                   |
             22--21--20--19--18  49--48  55--56--57  66--67       2
                              |   |       |       |   |
              5---6---7  16--17  50--51  54  59--58  65           1
              |       |   |           |   |   |       |
      0---1   4   9---8  15          52--53  60--61  64       <- Y=0
          |   |   |       |                       |   |
          2---3  10--11  14                      62--63          -1
                      |   |
                     12--13                                      -2

      ^
     X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 ...


The base figure is the initial N=0 to N=4.

              |
              |
      0---1   4      base figure
          |   |
          |   |
          2---3

It corresponds to a traversal of a "+" shape,

         .....5
         .    |
         .   <|
         .    |
    0----1....4.....
    . v  |    |    .
    .    |>   |>   .
    .    |    |    .
    .....2----3.....
         . v  .
         .    .
         .    .
         ......

The "v", ">" etc notches are side the figure is directed at the higher
replication levels.  The 0, 2 and 3 parts are the right hand side of the
line which means a plain repetition of the base figure.  The 1 and 4 parts
are to the left which means a reversal.  The first such reversal is seen
above as N=5 to N=10.

    5---6---7
            |
            |       reversed figure
        9---8
        |
        |

=head2 Arms

The optional C<arms> parameter can give up to four copies of the curve, each
advancing successively.  For example C<arms=E<gt>4> is as follows.  Notice
the N=4*k points are the plain curve, and N=4*k+1, N=3*k+2 and N=3*k+3 are
rotated copies of it.

                    70--66                     ...
                     |   |                       | 
    ..-118-114-110  74  62--58--54--50         117 
                 |   |               |           | 
           102-106  78  26--30  42--46  97-101 113 
             |       |   |   |   |       |   |   | 
            98--94  82  22  34--38  89--93 105-109 
                 |   |   |           |                 
        51--47  90--86  18--14--10  85--81--77--73--69 
         |   |                   |                   | 
        55  43--39  11-- 7   2-- 6  17--21--25  61--65 
         |       |   |   |           |       |   |     
        59  31--35  15   3   0   1  13  33--29  57     
         |   |       |       |   |   |   |       |
    67--63  27--23--19   8-- 4   5-- 9  37--41  53
     |                   |                   |   |
    71--75--79--83--87  12--16--20  88--92  45--49
                     |           |   |   |
       111-107  95--91  40--36  24  84  96-100
         |   |   |       |   |   |   |       |
       115 103--99  48--44  32--28  80 108-104
         |           |               |   |
       119          52--56--60--64  76 112-116-120-...
         |                       |   |                
       ...                      68--72           

Essentially the curve fills an ever expanding "+" shape with one corner at
the origin.  In the following picture the plain curve fills "A" and there's
room for two more arms to fill B and C, rotated 120 and 240 degrees
respectively.

                +---+
                |   |
        +---+---    +---+
        |   |     A     |
    +---+   +---+   +---+
    |     B     |   |   |
    +---+   +---O---+   +---+
        |   |   |     D     |
        +---+   +---+   +---+
        |     C     |   |
        +---+   +---+---+ 
            |   |
            +---+

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageQuintetCurve-E<gt>new ()>

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
