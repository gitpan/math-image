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


# math-image --path=Flowsnake --lines --scale=10

# http://kilin.clas.kitasato-u.ac.jp/museum/gosperex/343-024.pdf
# http://web.archive.org/web/20070630031400/http://kilin.u-shizuoka-ken.ac.jp/museum/gosperex/343-024.pdf
#     Variations.
#
#  Martin Gardner, In which "monster" curves force redefinition of the word
#  "curve", Scientific American 235 (December issue), 1976, 124-133.
#

package Math::PlanePath::MathImageFlowsnake;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 57;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;


#         *
#        / \
#       /   \
#      *-----*
#
# (b/2)^2 + h^2 = s
# (1/2)^2 + h^2 = 1
# h^2 = 1 - 1/4
# h = sqrt(3)/2 = 0.866
#


#       4-->5-->6
#       ^       ^
#        \       \
#         3-->2
#            /
#           v
#       0-->1
my @L = (1,1,2,-1,-2,0,-1);
my @R = (0,1,1,0,0,0,1);
my @X;
my @Y;

sub n_to_xy {
  my ($self, $n) = @_;
  return if $n < 0;
# return if $n > 7**3 + 10;
  ### Flowsnake n_to_xy(): $n

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }

  # if ($n >= @X) {
  #   while ($n >= @L) {
  #     my @newL;
  #     foreach my $i (0 .. 6) {
  #       if ($R[$i]) {
  #         my @part = map {$_} reverse @L;
  #         unshift @part, - pop @part;
  #         push @newL, @part;
  #       } else {
  #         push @newL, @L;
  #       }
  #     }
  #     @L = @newL;
  #   }
  #   ### @L
  #
  #   @X = ();
  #   @Y = ();
  #   my $x = my $y = 0;
  #   my $dir = -1;
  #   foreach my $ndir (@L) {
  #     push @X, $x;
  #     push @Y, $y;
  #
  #     $dir = ($dir + $ndir) % 6;
  #     if ($dir == 0)    { $x += 2; }
  #     elsif ($dir == 1) { $x++, $y++; }
  #     elsif ($dir == 2) { $x--, $y++; }
  #     elsif ($dir == 3) { $x -= 2; }
  #     elsif ($dir == 4) { $x--, $y--; }
  #     elsif ($dir == 5) { $x++, $y--; }
  #     ### at: "n=@{[scalar(@X)]} dir=$dir to $x, $y"
  #   }
  #   ### X len: scalar(@X)
  #   ### Y len: scalar(@Y)
  #   ### @X
  #   ### @Y
  # }
  # ### x: $X[$n]
  # ### y: $Y[$n]
  # return ($X[$n],$Y[$n]);







  my (@n, @sh, @si, @sj);
  {
    my $sh = 1;
    my $si = 0;
    my $sj = 0;
    while ($n) {
      push @n, $n % 7;
      $n = int($n/7);
      push @sh, $sh;
      push @si, $si;
      push @sj, $sj;
      ($sh, $si, $sj) = (2*$sh - $sj,
                         2*$si + $sh,
                         2*$sj + $si);
    }
    ### @n
  }

  #       4-->5-->6
  #       ^       ^
  #        \       \
  #         3-->2
  #            /
  #           v
  #       0-->1

  #             6<---
  #             ^
  #            /
  #       0   5<--4
  #        \       \
  #         v       v
  #         1<--2<--3

  #            0   1  2  3  4  5  6
  my @pos_h = (0,  1, 1, 0, 0, 0, 1,
               0,  0, 1, 2, 2, 1, 1);
  my @pos_i = (0,  0, 1, 1, 1, 2, 2,
               0,  0, 0, 0, 0, 0, 1);
  my @pos_j = (0,  0, 0, 0, 1, 0, 0,
               0, -1,-1,-1, 0, 0, 0);
  my @rev   = (0,  7, 7, 0, 0, 0, 7,
               7,  0, 0, 0, 7, 7, 0);
  my @dir   = (0,  1, 3, 2, 0, 0, 5,
               5,  0, 0, 2, 3, 1, 0);


  # my @dir_h = (1, 0, 0, -1, 0, 0);
  # my @dir_i = (0, 1, 0,  0,-1, 0);
  # my @dir_j = (0, 0, 1,  0, 0,-1);

  my $h = my $i = my $j = 0;
  my $rev = 0;
  my $dir = 0;
  while (@n) {
    my $digit = pop @n;
    my $sh = pop @sh;
    my $si = pop @si;
    my $sj = pop @sj;
    my $o = $rev + $digit;

    ### $digit
    ### step: "$sh, $si, $sj  sx=".($sh*2 + $si - $sj)." sy=".($si+$sj)
    ### $dir
    ### $rev
    ### $o

    # $sh *= $pos_h[$o];
    # $si *= $pos_i[$o];
    # $sj *= $pos_j[$o];

    if ($dir == 0)    { ($sh,$si,$sj) = ($sh,$si,$sj); }
    elsif ($dir == 1) { ($sh,$si,$sj) = (-$sj,$sh,$si); }
    elsif ($dir == 2) { ($sh,$si,$sj) = (-$si,-$sj,$sh); }
    elsif ($dir == 3) { ($sh,$si,$sj) = (-$sh,-$si,-$sj); }
    elsif ($dir == 4) { ($sh,$si,$sj) = ($sj,-$sh,-$si); }
    elsif ($dir == 5) { ($sh,$si,$sj) = ($si,$sj,-$sh); }

    # $h += $sh;
    # $i += $si;
    # $j += $sj;

    $h += $sh * $pos_h[$o]  - $sj * $pos_i[$o]  - $si * $pos_j[$o];
    $i += $si * $pos_h[$o]  + $sh * $pos_i[$o]  - $sj * $pos_j[$o];
    $j += $sj * $pos_h[$o]  + $si * $pos_i[$o]  + $sh * $pos_j[$o];

    $rev ^= $rev[$o];
    $dir = ($dir + $dir[$o]) % 6;
    ### rotated step: "$sh, $si, $sj"
    ### pos: "$pos_h[$o], $pos_i[$o], $pos_j[$o]"
    ### to: "$h, $i, $j  x=".($h*2 + $i - $j)." y=".($i+$j)
  }

  ### ret: "$h, $i, $j  x=".($h*2 + $i - $j)." y=".($i+$j)
  return ($h*2 + $i - $j,
          $i+$j);


  # #       4-->5-->6      y=2
  # #       ^       ^
  # #        \       \
  # #         3-->2   7    y=1
  # #            /
  # #           v
  # #       0-->1          y=0
  # #
  # #     x=0 1 2 3 4 5
  # #
  # #
  #
  # my $h = my $i = my $j = 0;
  # my $bh = 1;
  # my $bi = 0;
  # my $bj = 0;
  #
  # while ($n) {
  #   my $digit = $n % 7;
  #   $n = int($n/7);
  #
  #   my $eh = 2*$bh - $bj;
  #   my $ei = 2*$bi + $bh;
  #   my $ej = 2*$bj + $bi;
  #
  #   my $rh = $eh - $h;
  #   my $ri = $ei - $i;
  #   my $rj = $ej - $j;
  #
  #   ### end: "$eh, $ei, $ej  x=".($eh*2 + $ei - $ej)." y=".($ei+$ej)
  #   ### rev: "$rh, $ri, $rj  x=".($rh*2 + $ri - $rj)." y=".($ri+$rj)
  #
  #   if ($digit == 1) {
  #     ($h,$i,$j) = ($bh  + $rh,
  #                   $bi  + $ri,
  #                   $bj  + $rj);
  #
  #   } elsif ($digit == 2) {
  #     ($h,$i,$j) = ($bh-$bj  - $rj,
  #                   $bi+$bh  + $rh,
  #                   $bj+$bi  + $ri);
  #
  #   } elsif ($digit == 3) {
  #     ($h,$i,$j) = (-$bj  + $h,
  #                   $bh   + $i,
  #                   $bi   + $j);
  #
  #   } elsif ($digit == 4) {
  #     ($h,$i,$j) = (-$bj - $bi  + $h,
  #                   $bh  - $bj  + $i,
  #                   $bi  + $bh  + $j);
  #
  #   } elsif ($digit == 5) {
  #     ($h,$i,$j) = (-2*$bj   + $h,
  #                   2*$bh    + $i,
  #                   2*$bi    + $j);
  #
  #   } elsif ($digit == 6) {
  #     ($h,$i,$j) = (-2*$bj + $bh   + $ri,
  #                   2*$bh  + $bi   - $rj,
  #                   2*$bi  + $bj   - $rh);
  #   }
  #
  #   ($bh, $bi, $bj) = ($eh,
  #                      $ei,
  #                      $ej);
  #
  #   # ($bh, $bi, $bj) = (2*$bh - $bj,
  #   #                    2*$bi + $bh,
  #   #                    2*$bj + $bi);
  #
  #
  #   ### pos: "$h, $i, $j"
  #   ### base: "$bh, $bi, $bj  x=".($bh*2 + $bi - $bj)." y=".($bi+$bj)
  # }
  #
  # ### ret: "$h, $i, $j  x=".($h*2 + $i - $j)." y=".($i+$j)
  # return ($h*2 + $i - $j,
  #         $i+$j);

}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  return undef;
  ### Flowsnake xy_to_n(): "$x, $y"
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = floor($x1 + 0.5);
  $y1 = floor($y1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($y2 < 0) {
    return (1, 0);
  }

  #            0  1  2  3  4  5  6  7
  my @pos_h = (0, 1, 1, 0, 0, 0, 1, 2);
  my @pos_i = (0, 0, 1, 1, 1, 2, 2, 1);
  my @pos_j = (0, 0, 0, 0, 1, 0, 0, 0);
  my $n_hi = 0;

  my $sh = 1;
  my $si = 0;
  my $sj = 0;
  my $n = 1;
  my $prev_x = 0;
  my $x_max = my $x_min = my $y_max = my $y_min = 0;
  my ($tr, $tl);

 OUTER: foreach (1 .. 10) {
    my ($h, $i, $j, $x, $y);

    foreach my $o (1 .. 7) {
      $h = $sh * $pos_h[$o]  - $sj * $pos_i[$o]  - $si * $pos_j[$o];
      $i = $si * $pos_h[$o]  + $sh * $pos_i[$o]  - $sj * $pos_j[$o];
      $j = $sj * $pos_h[$o]  + $si * $pos_i[$o]  + $sh * $pos_j[$o];
      $x = $h*2 + $i - $j;
      $y = $i + $j;

      if ($o == 6 && $x < $prev_x) {
        $tr = 1;
      }

      if ($x >= $x2 && $y >= $y2) {
        $tr = 1;
      }
      if ($x <= $x1 && $y >= $y2) {
        $tl = 1;
      }

      if ($tr && $tl) {
        $n *= $o;
        last OUTER;
      }
    }

    $n *= 7;
    $sh = $h;
    $si = $i;
    $sj = $j;
    $prev_x = $x;
  }
  return (0, $n);

  # my $ret = 9;
  # while ($x2) {
  #   $ret *= 4;
  #   $x2 = int($x2 / 2);
  # }
  # while ($y2) {
  #   $ret *= 3;
  #   $y2 = int($y2 / 2);
  # }
  # return (0, $ret);
}

1;
__END__

=for stopwords eg Ryde OEIS

=head1 NAME

Math::PlanePath::MathImageFlowsnake -- self-similar path traversal

=head1 SYNOPSIS

 use Math::PlanePath::MathImageFlowsnake;
 my $path = Math::PlanePath::MathImageFlowsnake->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.  No C<xy_to_n> yet.  And C<rect_to_n_range> is an
under-estimate.  A full range would be N=1e14 or more to cover Y from say
-500 to +500, which is nearly past the accuracy of 53-bit floats ...>

This path is an integer version of the flowsnake curve by William Gosper,
making a self-similar traversal of the plane.

                         39----40----41                        8
                           \           \
          32----33----34    38----37    42                     7
            \           \        /     /
             31----30    35----36    43    47----48            6
                  /                    \     \     \
          28----29    17----16----15    44    46    49...      5
         /              \           \     \  /
       27    23----22    18----19    14    45                  4
         \     \     \        /     /
          26    24    21----20    13    11----10               3
            \  /                    \  /     /
             25     4---- 5---- 6    12     9                  2
                     \           \         /
                       3---- 2     7---- 8                     1
                           /
                    0---- 1                                  y=0

     x=-4 -3 -2 -1  0  1  2  3  4  5  6  7  8  9 10 11

The points are spread out on every second X coordinate to make little
triangles but staying in integer coordinates.  It should be equilateral
triangles, but on a square grid this comes out a little flatter.

The basic pattern is the seven points 0 to 6,

        4---- 5---- 6
         \           \
           3---- 2
               /
        0---- 1

This repeats at 7-fold increasing scale, with the 1, 2 and 6 sub-sections
reversed (mirror image).  The next scale level can be seen at the multiple
of 7 points 0,7,14,21,28,35,42,49.

                                        42
                            -----------    ---
                         35                   ---
             -----------                         ---
          28                                        49 ---
            ---
               ----                  14
                   ---   -----------  |
                      21              |
                                     |
                                    |
                                    |
                              ---- 7
                         -----
                    0 ---

Notice this is the same shape as the 0 to 6, but rotated 20.68 degrees
counter-clockwise.  Each level rotates further and for example after 18
levels it goes all the way around and back to the first quadrant.

The effect of the rotation is to fill the whole plane, eventually.  For
example at N=8592 it returns to the X axis at X=-82,Y=0 and starts to go
into YE<lt>0 shortly after.  Getting all the way around to fill the fourth
quadrant XE<gt>0,YE<lt>0 takes a long time though, something on the order
N=7^17 (which is close to rounding off in 53-bit floats).

=head2 Fractal

The flowsnake can also be thought of as successively subdividing the line
segments with suitably scaled copies of the 0 to 7 figure (or its reversal).

The code here could be used for that by taking points N=0 to N=7^level.  The
Y coordinates should be multiplied by sqrt(3) to make proper equilateral
triangles, then a rotation and scaling to make the endpoint come out at 1,0
or wherever desired.  With this the path is confined to a finite fractal
boundary.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageFlowsnake-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.  Integer positions are always just 1 apart either
horizontally or vertically, so the effect is that the fraction part appears
either added to or subtracted from X or Y.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::ZOrderCurve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Math-Image is Copyright 2010, 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
