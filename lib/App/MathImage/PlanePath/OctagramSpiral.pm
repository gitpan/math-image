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


package App::MathImage::PlanePath::OctagramSpiral;
use 5.004;
use strict;
use warnings;
use List::Util 'min', 'max';
use POSIX 'floor', 'ceil';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 43;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments '###';

sub n_to_xy {
  my ($self, $n) = @_;
  #### OctagramSpiral n_to_xy: $n

  if ($n <= 2) {
    if ($n < 1) {
      return;
    } else {
      return ($n-1, 0);
    }
  }

  my $d = int (sqrt(.125 * $n + 0.06640625) + 0.4375);
  #### d frac: (sqrt(.125 * $n + 0.06640625) + 0.4375)
  #### $d

  #### base: ((8*$d - 7)*$d + 1)
  $n -= ((8*$d - 7)*$d + 1);
  #### remainder: $n

  if ($n < $d) {
    return ($d + $n, $n);
  }
  $n -= 2*$d;
  if ($n < $d) {
    return ($d - min(0,$n), $d + max(0,$n));
  }
  $n -= 2*$d;

  if ($n < $d) {
    return (-$n, $d+abs($n));
  }
  $n -= 2*$d;

  if ($n < $d) {
    return (-$d - max(0,$n), $d - min(0,$n));
  }
  $n -= 2*$d;

  if ($n < $d) {
    return (-$d-abs($n), -$n);
  }
  $n -= 2*$d;

  if ($n < $d) {
    return (-$d + min(0,$n), -$d - max(0,$n));
  }
  $n -= 2*$d;

  if ($n < $d) {
    return ($n, -$d - abs($n));
  }
  $n -= 2*$d;

  if ($n < $d+1) {
    return ($d + max(0,$n), -$d + min(0,$n));
  }

  # $n >= $d+1 through to 2*$d+1
  return (3*$d+2 - $n, -2*$d-1 + $n);
}

         #         29             25
         #          |  \         /  |
         #         30  28      26  24      ...-56--55       
         #          |     \   /     |            /
         # 33--32--31   7  27   5  23--22--21  54          2
         #   \          | \   / |         /  /
         #     34   9-- 8   6   4-- 3  20  53              1
         #       \   \            /   /  /
         #         35  10   1---2  19  52             <- y=0
         #       /   /                \   \  
         #     36  11--12  14  16--17--18  51             -1
         #   /          | /   \ |            \
         # 37--38--39  13  43  15  47--48--49--50         -2
         #          |    /   \      |
         #         40  42      44  46
         #          | /          \  |
         #         41              45
         # 
         #                  ^
         #     -3  -2  -1  x=0  1   2   3

sub xy_to_n {
  my ($self, $x, $y) = @_;
  return undef;

  # $x = floor ($x + 0.5);
  # $y = floor ($y + 0.5);
  # ### xy_to_n: "x=$x, y=$y"
  # 
  # my $d;
  # if (($d = $x) > abs($y)) {
  #   ### right vertical
  #   ### $d
  #   #
  #   # base bottom right per above
  #   ### BR: 4*$d*$d + (-4+2*$w)*$d + (2-$w)
  #   # then +$d-1 for the y=0 point
  #   # N_Y0  = 4*$d*$d + (-4+2*$w)*$d + (2-$w) + $d-1
  #   #       = 4*$d*$d + (-3+2*$w)*$d + (2-$w) + -1
  #   #       = 4*$d*$d + (-3+2*$w)*$d +  1-$w
  #   ### N_Y0: (4*$d + -3 + 2*$w)*$d + 1-$w
  #   #
  #   return (4*$d + -3)*$d + 1 + $y;
  # }
  # 
  # if (($d = -$x) > abs($y)) {
  #   ### left vertical
  #   ### $d
  #   #
  #   # top left per above
  #   ### TL: 4*$d*$d + (2*$w)*$d + 1
  #   # then +$d for the y=0 point
  #   # N_Y0  = 4*$d*$d + (2*$w)*$d + 1 + $d
  #   #       = 4*$d*$d + (1 + 2*$w)*$d + 1
  #   ### N_Y0: (4*$d + 1 + 2*$w)*$d + 1
  #   #
  #   return (4*$d + 1)*$d + 1 - $y;
  # }
  # 
  # $d = abs($y);
  # if ($y > 0) {
  #   ### top horizontal
  #   ### $d
  #   #
  #   # top left per above
  #   ### TL: 4*$d*$d + (2*$w)*$d + 1
  #   # then -($d) for the x=0 point
  #   # N_X0  = 4*$d*$d + (2*$w)*$d + 1 + -($d)
  #   #       = 4*$d*$d + (-1 + 2*$w)*$d + 1
  #   ### N_Y0: (4*$d - 1 + 2*$w)*$d + 1
  #   #
  #   return (4*$d - 1)*$d + 1 - $x;
  # }
  # 
  # ### bottom horizontal, and centre y=0
  # ### $d
  # #
  # # top left per above
  # ### TL: 4*$d*$d + (2*$w)*$d + 1
  # # then +2*$d to bottom left, +$d for the x=0 point
  # # N_X0  = 4*$d*$d + (2*$w)*$d + 1 + 2*$d + $d)
  # #       = 4*$d*$d + (3 + 2*$w)*$d + 1
  # ### N_Y0: (4*$d + 3 + 2*$w)*$d + 1
  # #
  # return (4*$d + 3)*$d + 1 + $x;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  my $d = 1 + max (1,
                   floor(0.5 + max(abs($y1),abs($y2))),
                   (map {$_ = floor(0.5 + $_);
                         max ($_,
                              -$_)}
                    ($x1, $x2)));
  ### $s
  ### is: $s*$s

  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          (4*$d + -4)*$d + 2);  # bottom-right
}

1;
__END__

=for stopwords Ulam OctagramSpiral pronic PlanePath Ryde Math-PlanePath Ulam's VogelFloret PyramidSides PyramidRows PyramidSpiral Honaker's decagonal octagram

=head1 NAME

App::MathImage::PlanePath::OctagramSpiral -- integer points drawn around a square (or rectangle)

=head1 SYNOPSIS

 use App::MathImage::PlanePath::OctagramSpiral;
 my $path = App::MathImage::PlanePath::OctagramSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a spiral around an octagram (8-pointed star),

            28              24                      4
             |  \         /  |
            29  27      25  23      ...-54--53      3       
             |     \   /     |            /
    32--31--30   7  26   5  22--21--20  52          2
      \          | \   / |         /  /
        33   9-- 8   6   4-- 3  19  51              1
          \   \            /   /  /
            34  10   1---2  18  50             <- y=0
          /   /              |   |    
        35  11--12  14  16--17  49                 -1
      /          | /   \ |         \   
    36--37--38  13  42  15  46--47--48             -2
             |    /   \      |
            39  41      43  45                     -3
             | /          \  |
            40              44                     -4

                     ^
    -4  -3  -2  -1  x=0  1   2   3   4   5  ...







            29             25                       4
             |  \         /  |
            30  28      26  24      ...-56--55      3       
             |     \   /     |            /
    33--32--31   7  27   5  23--22--21  54          2
      \          | \   / |         /  /
        34   9-- 8   6   4-- 3  20  53              1
          \   \            /   /  /
            35  10   1---2  19  52             <- y=0
          /   /                \   \  
        36  11--12  14  16--17--18  51             -1
      /          | /   \ |            \
    37--38--39  13  43  15  47--48--49--50         -2
             |    /   \      |
            40  42      44  46                     -3
             | /          \  |
            41              45                     -4

                     ^
    -4  -3  -2  -1  x=0  1   2   3   4   5  ...

=head1 FUNCTIONS

=over 4

=item C<$path = App::MathImage::PlanePath::OctagramSpiral-E<gt>new ()>

Create and return a new square spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each N
in the path as centred in a square of side 1, so the entire plane is
covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SquareSpiral>,
L<Math::PlanePath::PyramidSpiral>

=cut
