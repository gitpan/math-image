# Copyright 2010 Kevin Ryde

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


package App::MathImage::PlanePath::Hilbert33;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 13;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

# i=0    6--7--8
#        |
#        5--4--3
#              |
#        0--1--2
#
# i=9    0--1--2
#              |
#        5--4--3
#        |
#        6--7--8
#
# i=18   8--7--6
#              |
#        3--4--5
#        |
#        2--1--0
#
# i=27   2--1--0
#        |
#        3--4--5
#              |
#        8--7--6
#
#
my @n_to_next_i = (0,9,0, 18,27,18, 0,9,0,     # i=0
                   9,0,9, 27,18,27, 9,0,9,     # i=9
                   18,27,18, 0,9,0, 18,27,18,  # i=18
                   27,18,27, 9,0,9, 27,18,27,  # i=27
                  );
my @n_to_x = (0,1,2, 2,1,0, 0,1,2,   # i=0
              0,1,2, 2,1,0, 0,1,2,   # i=9
              2,1,0, 0,1,2, 2,1,0,   # i=18
              2,1,0, 0,1,2, 2,1,0,   # i=27
             );
my @n_to_y = (0,0,0, 1,1,1, 2,2,2,   # i=0
              2,2,2, 1,1,1, 0,0,0,   # i=9
              0,0,0, 1,1,1, 2,2,2,   # i=18
              2,2,2, 1,1,1, 0,0,0,   # i=27
             );

my @yx_to_n = (0,1,2, 5,4,3, 6,7,8,   # i=0
               6,7,8, 5,4,3, 0,1,2,   # i=9
               2,1,0, 3,4,5, 8,7,6,   # i=18
               8,7,6, 3,4,5, 2,1,0,   # i=27
              );

sub n_to_xy {
  my ($self, $n) = @_;
  ### Hilbert33 n_to_xy(): $n
  return if $n < 0;

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }

  my $x = my $y = ($n & 0); # inherit
  my @n;
  while ($n) {
    push @n, ($n % 9);
    $n = int($n/9);
  }
  ### $pos

  my $i = 0;
  while (@n) {
    my $t = $i + (pop @n);
    $x = ($x * 3) + $n_to_x[$t];
    $y = ($y * 3) + $n_to_y[$t];
    ### $pos
    ### $i
    ### bits: ($n % 9)
    ### $t
    ### n_to_x: $n_to_x[$t]
    ### n_to_y: $n_to_y[$t]
    ### next_i: $n_to_next_i[$t]
    ### x: sprintf "%#X", $x
    ### y: sprintf "%#X", $y
    $i = $n_to_next_i[$t];
  }

  ### is: "$x,$y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### Hilbert33 xy_to_n(): "$x, $y"

  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  my $n = ($x & 0); # inherit

  my $pos = 0;
  my @x;
  my @y;
  while ($x || $y) {
    push @x, $x % 3;
    push @y, $y % 3;
    $x = int($x/3);
    $y = int($y/3);
  }

  my $i = 0;
  while (@x) {
    my $yx = (pop @y) * 3 + (pop @x);
    my $ndigs = $yx_to_n[$i + $yx];
    $n = ($n * 9) + $ndigs;
    ### $pos
    ### $i
    ### x digit: ($yx % 3)
    ### y digit: int($yx/3)
    ### t: $i + $yx
    ### yx_to_n: $yx_to_n[$i + $yx]
    ### next_i: $n_to_next_i[$i+$ndigs]
    ### n: sprintf "%#X", $n
    $i = $n_to_next_i[$i + $ndigs];
    $pos--;
  }

  return $n;
}


# This is a bit bloated, but the result is the exact minimum/maximum N in
# the given rectangle.
#
# The strategy is similar to xy_to_n(), except that at each bit position
# instead of taking a bit of x,y from the input instead those bits are
# chosen from among the 4 sub-parts according to which has the maximum N and
# is within the given target rectangle.  The final result is both an $n_max
# and a $x_max,$y_max which is its position, but only the $n_max is
# returned.
#
# Similarly for the minimum.  There's separate N and X,Y for the min and
# max, including a different "i" state corresponding to the two Ns.
#
# If a sub-part is completely within the target rectangle then the remaining
# bits are min N=0 and max N=0b11..111.  The N=0 will happen if 0,0 is in
# the rectangle, but the max might only skip low 1-bits of the target
# rectangle, which usually won't be many.
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = floor($x1 + 0.5);
  $y1 = floor($y1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    return (-1, 0);
  }

  my $ret = 9;
  while ($x2) {
    $ret *= 3;
    $x2 = int($x2 / 3);
  }
  while ($y2) {
    $ret *= 3;
    $y2 = int($y2 / 3);
  }
  return (0, $ret);

  # my $n_min = my $n_max
  #   = my $x_min = my $y_min
  #     = my $x_max = my $y_max
  #       = ($x1 & 0); # 0 inherit
  # 
  # my $pos = 0;
  # my $digit = $n_min + 2;  # inherit
  # {
  #   my $m = max ($x1, $x2, $y1, $y2);
  #   while ($m >= $digit) {
  #     $digit *= 3;
  #     $pos++;
  #   }
  # }
  # ### $pos
  # 
  # my $i_min = my $i_max = ($pos & 1) << 2;
  # $digit = int($digit/3);
  # while ($pos >= 0) {
  #   {
  #     my $x_cmp = $x_max + $digit;
  #     my $y_cmp = $y_max + $digit;
  #     my $x_cmp2 = $x_cmp + $digit;
  #     my $y_cmp2 = $y_cmp + $digit;
  # 
  #     my $nbits = -1;
  #     my $yx;
  # 
  #     my $this_yx = 0;
  #     foreach my $incl (($x1 <  $x_cmp && $y1 <  $y_cmp),    # bot left
  #                       ($x2 >= $x_cmp && $y1 <  $y_cmp),    # bot right
  #                       ($x1 <  $x_cmp && $y2 >= $y_cmp2),    # top left
  #                       ($x2 >= $x_cmp2 && $y2 >= $y_cmp2)) {  # top right
  #       if ($incl) {  # sub-quadrant included in target rectangle
  #         my $this_nbits = $yx_to_n[$i_max + $this_yx];
  #         if ($this_nbits > $nbits) {
  #           $nbits = $this_nbits;
  #           $yx = $this_yx;
  #         }
  #       }
  #       $this_yx++;
  #     }
  # 
  #     $n_max = ($n_max << 2) + $nbits;
  #     $x_max += ($yx & 1) << $pos;
  #     $y_max += (($yx & 2) >> 1) << $pos;
  #     ### $pos
  #     ### $yx
  #     ### $nbits
  #     ### next_i: $n_to_next_i[$i_max+$nbits]
  #     ### n_max: sprintf "%#X", $n_max
  #     ### bit:  sprintf "%#X", $digit
  #     $i_max = $n_to_next_i[$i_max + $nbits];
  #   }
  # 
  #   {
  #     my $x_cmp = $x_min + $digit;
  #     my $y_cmp = $y_min + $digit;
  # 
  #     my $nbits = 4;
  #     my $yx;
  # 
  #     my $this_yx = 0;
  #     foreach my $incl (($x1 <  $x_cmp && $y1 <  $y_cmp),    # bot left
  #                       ($x2 >= $x_cmp && $y1 <  $y_cmp),    # bot right
  #                       ($x1 <  $x_cmp && $y2 >= $y_cmp),    # top left
  #                       ($x2 >= $x_cmp && $y2 >= $y_cmp)) {  # top right
  #       if ($incl) {  # sub-quadrant included in target rectangle
  #         my $this_nbits = $yx_to_n[$i_min + $this_yx];
  #         if ($this_nbits < $nbits) {
  #           $nbits = $this_nbits;
  #           $yx = $this_yx;
  #         }
  #       }
  #       $this_yx++;
  #     }
  # 
  #     $n_min = ($n_min << 2) | $nbits;
  #     $x_min += ($yx & 1) << $pos;
  #     $y_min += (($yx & 2) >> 1) << $pos;
  #     ### $pos
  #     ### $yx
  #     ### $nbits
  #     ### next_i: $n_to_next_i[$i_min+$nbits]
  #     ### n_min: sprintf "%#X", $n_min
  #     ### bit:  sprintf "%#X", $digit
  #     $i_min = $n_to_next_i[$i_min + $nbits];
  #   }
  # 
  #   $pos--;
  #   $digit = int($digit/3);
  # }
  # 
  # return ($n_min, $n_max);
}

1;
__END__


  # my $n = int($nf);
  # my $frac = $nf - $n;

    # if ($bits == 0) {
    #   ### d unchanged
    # } elsif ($bits == 1) {
    #   ($dx,$dy) = ($dy,$dx);
    #   ### d swap: "$dx,$dy"
    # } elsif ($bits == 2) {
    #   $dx = -$dx;
    #   $dy = -$dy;
    #   ### d invert: "$dx,$dy"
    # } elsif ($bits == 3) {
    #   ($dx,$dy) = ($dy,$dx);
    #   ### d swap: "$dx,$dy"
    # }
    # my $prevbits = $bits;

    # if ($bits == 0) {
    #   ### d unchanged
    # } elsif ($bits == 1) {
    #   ($dx,$dy) = ($dy,$dx);
    #   ### d swap: "$dx,$dy"
    # } elsif ($bits == 2) {
    #   if ($prevbits == 3) {
    #     ($dx,$dy) = ($dy,$dx);
    #     ### d swap: "$dx,$dy"
    #   }
    #   ($dx,$dy) = ($dy,$dx);
    #   ### d swap: "$dx,$dy"
    # } elsif ($bits == 3) {
    #   if ($prevbits == 3) {
    #     ($dx,$dy) = ($dy,$dx);
    #     ### d swap: "$dx,$dy"
    #   }
    #   $dx = -$dx;
    #   $dy = -$dy;
    #   ### d invert: "$dx,$dy"
    # }
  # my $dx = 1;
  # my $dy = 0;
  # $x += $dx * $frac;
  # $y += $dy * $frac;
  # ### d: "$dx,$dy"









=for stopwords Ryde Math-Image OEIS

=head1 NAME

App::MathImage::PlanePath::Hilbert33 -- self-similar quadrant traversal

=head1 SYNOPSIS

 use App::MathImage::PlanePath::Hilbert33;
 my $path = App::MathImage::PlanePath::Hilbert33->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path traverses a quadrant of the plane one step at a time in a 3x3
self-similar pattern,

      y=8   60--61--62--63--64--65  78--79--80--...
             |                   |   |
      y=7   59--58--57  68--67--66  77--76--75
                     |   |                   |
      y=6   54--55--56  69--70--71--72--73--74
             |
      y=5   53--52--51  38--37--36--35--34--33
                     |   |                   |
      y=4   48--49--50  39--40--41  30--31--32
             |                   |   |
      y=3   47--46--45--44--43--42  29--28--27
                                             |
      y=2    6---7---8---9--10--11  24--25--26
             |                   |   |
      y=1    5---4---3  14--13--12  23--22--21
                     |   |                   |
      y=0    0---1---2  15--16--17--18--19--20

           x=0   1   2   3   4   5   6   7   8   9 ...

The start is an S shape per 0..9, and then nine of those are put together in
the same configuration but the sub parts flipped horizonally or vertically
to make the starts and ends adjacent, so 8 next to 9, 17 next to 18, etc,

    60,61,62     63,64,65     78,79,80
    59,58,57 --- 68,67,55 --- 77,76,75
    54,55,56     69,70,71     72,73,74
       |
       |
    53,52,51     38,37,36     35,34,33
    48,49,50 --- 39,40,41 --- 30,31,32
    47,46,45     44,43,42     29,28,27
                                  |
                                  |
    6,7,8         9,10,11     24,25,26
    3,4,5  -- -- 12,13,14 --- 23,22,21
    0,1,2        15,16,17     18,19,20

The process repeats, tripling each time.

Within a power-of-3 square 3x3, 9x9, 27x27, 81x81 etc 3^k, all the N values
0 to 3^(2*k)-1 are within the square.  The top right corner 8, 80, 6560 of
each is the 3^(2*k)-1 maximum.

=head2 OEIS

The Hilbert Curve path is in Sloane's OEIS as ...

    http://www.research.att.com/~njas/sequences/A163332

=head1 FUNCTIONS

=over 4

=item C<$path = App::MathImage::PlanePath::Hilbert33-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.  Integer positions are always just 1 apart either
horizontally or vertically, so the effect is that the fraction part appears
either added to or subtracted from X or Y.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square an C<$x,$y> within that square
returns N.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::ZOrderCurve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Math-Image is Copyright 2010 Kevin Ryde

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
