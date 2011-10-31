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


# http://alexis.monnerot-dumaine.neuf.fr/articles/fibonacci%20fractal.pdf


package Math::PlanePath::MathImageFibonacciWordFractal;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 79;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;


use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

my @rot_to_sx = (1,0,-1,0);
my @rot_to_sy = (0,1,0,-1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageFibonacciWordFractal n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  # my $frac;
  # {
  #   my $int = int($n);
  #   $frac = $n - $int;  # inherit possible BigFloat
  #   $n = $int;          # BigFloat int() gives BigInt, use that
  # }
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

  my $zero = ($n * 0);  # inherit bignum 0
  my $one = $zero + 1;  # inherit bignum 0

  my @f = ($one, $zero+2);
  my @xend = ($zero, $zero, $one);
  my @yend = ($zero, $one, $one);
  my $level = 1;
  while ($f[-1] < $n) {
    push @f, $f[-1] + $f[-2];

    my ($x,$y);
    if (($level % 6) == 0) {
      $x = $yend[-2];     # T
      $y = $xend[-2];
    } elsif (($level % 6) == 1) {
      $x = $yend[-2];      # -90
      $y = - $xend[-2];
    } elsif (($level % 6) == 2) {
      $x = $xend[-2];     # T -90
      $y = - $yend[-2];

    } elsif (($level % 6) == 3) {
      ### T
      $x = $yend[-2];     # T
      $y = $xend[-2];
    } elsif (($level % 6) == 4) {
      $x = - $yend[-2];     # +90
      $y = $xend[-2];
    } elsif (($level % 6) == 5) {
      $x = - $xend[-2];     # T +90
      $y = $yend[-2];
    }

    push @xend, $xend[-1] + $x;
    push @yend, $yend[-1] + $y;
    ### new: ($level%6)." add $x,$y for $xend[-1],$yend[-1]  for $f[-1]"
    $level++;
  }

  my $x = $zero;
  my $y = $zero;
  my $rot = 0;
  my $transpose = 0;

  while (@xend > 1) {
    ### at: "$x,$y  rot=$rot transpose=$transpose level=$level   n=$n consider f=$f[-1]"
    my $xo = pop @xend;
    my $yo = pop @yend;

    if ($n >= $f[-1]) {
      $n -= $f[-1];
      ### offset: "$xo, $yo  for ".($level % 6)

      if ($transpose) {
        ($xo,$yo) = ($yo,$xo);
      }
      if ($rot & 2) {
        $xo = -$xo;
        $yo = -$yo;
      }
      if ($rot & 1) {
        ($xo,$yo) = (-$yo,$xo);
      }
      ### apply rot to offset: "$xo, $yo"

      $x += $xo;
      $y += $yo;

      if (($level % 6) == 0) {
        $transpose ^= 1;  # T
      } elsif (($level % 6) == 1) {
        # -90
        if ($transpose) {
          $rot++;
        } else {
          $rot--;
        }
      } elsif (($level % 6) == 2) {
        $transpose ^= 1;    # T -90
        if ($transpose) {
          $rot--;
        } else {
          $rot++;
        }

      } elsif (($level % 6) == 3) {
        $transpose ^= 1;  # T
      } elsif (($level % 6) == 4) {
        if ($transpose) {
          $rot--;
        } else {
          $rot++;   # +90
        }
      } else {  # (($level % 6) == 5)
        $transpose ^= 1;    # T +90
        if ($transpose) {
          $rot++;   # +90
        } else {
          $rot--;
        }
      }
    }
    pop @f;
    $level--;
  }

  # $x = $frac * $rot_to_sx[$rot] + $x;
  # $y = $frac * $rot_to_sy[$rot] + $y;

  ### final with frac: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### FibonacciWordFractal xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my $zero = ($x * 0 * $y);  # inherit bignum 0
  my $one = $zero + 1;       # inherit bignum 0

  my @f = ($one, $zero+2);
  my @xend = ($zero, $one);
  my @yend = ($one, $one);
  my $level = 1;

  for (;;) {
    my ($xo,$yo);
    if (($level % 6) == 0) {
      $xo = $yend[-2];     # T
      $yo = $xend[-2];
    } elsif (($level % 6) == 1) {
      $xo = $yend[-2];      # -90
      $yo = - $xend[-2];
    } elsif (($level % 6) == 2) {
      $xo = $xend[-2];     # T -90
      $yo = - $yend[-2];

    } elsif (($level % 6) == 3) {
      ### T
      $xo = $yend[-2];     # T
      $yo = $xend[-2];
    } elsif (($level % 6) == 4) {
      $xo = - $yend[-2];     # +90
      $yo = $xend[-2];
    } elsif (($level % 6) == 5) {
      $xo = - $xend[-2];     # T +90
      $yo = $yend[-2];
    }

    $xo += $xend[-1];
    $yo += $yend[-1];
    last if ($xo > $x && $yo > $y);

    push @f, $f[-1] + $f[-2];
    push @xend, $xo;
    push @yend, $yo;

    ### new: ($level%6)." add $x,$yo for $xend[-1],$yend[-1]  for $f[-1]"
    $level++;
  }

  my $n = 0;
  while ($level >= 0) {
    ### at: "$x,$y  n=$n level=$level consider $xend[-1],$yend[-1] for $f[-1]"

    if (($level-1) % 6 < 3) {
      ### 1,2,3 X ...
      if ($x >= $xend[-1]) {
        $n += $f[-1];
        $x -= $xend[-1];
        $y -= $yend[-1];
        ### shift to: "$x,$y  levelmod ".($level % 6)

        if (($level % 6) == 1) {
          ($x,$y) = (-$y,$x);  # +90
        } elsif (($level % 6) == 2) {
          $y = -$y;            # +90 T
        } elsif (($level % 6) == 3) {
          ($x,$y) = ($y,$x);   # T
        }
        ### rot to: "$x,$y"
        if ($x < 0 || $y < 0) {
          return undef;
        }
      }
    } else {
      ### 4,5,0 Y ...
      if ($y >= $yend[-1]) {
        $n += $f[-1];
        $x -= $xend[-1];
        $y -= $yend[-1];
        ### shift to: "$x,$y  levelmod ".($level % 6)

        if (($level % 6) == 4) {
          ($x,$y) = ($y,-$x);  # -90
        } elsif (($level % 6) == 5) {
          $x = -$x;            # -90 T
        } elsif (($level % 6) == 0) {
          ($x,$y) = ($y,$x);   # T
        }
        ### rot to: "$x,$y"
        if ($x < 0 || $y < 0) {
          return undef;
        }
      }
    }

    pop @f;
    pop @xend;
    pop @yend;
    $level--;
  }

  if ($x != 0 || $y != 0) {
    return undef;
  }
  return $n;
}

# uncomment this to run the ### lines
#use Smart::Comments;

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageFibonacciWordFractal rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### rect_to_n_range(): "$x1,$y1 to $x2,$y2"

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);
  }

  my $zero = ($x1 * 0 * $y1 * $x2 * $y2);  # inherit bignum 0
  my $one = $zero + 1;                     # inherit bignum 0

  my $f0 = 1;
  my $f1 = 2;
  my $xend0 = $zero;
  my $xend1 = $one;
  my $yend0 = $one;
  my $yend1 = $one;
  my $level = 1;

  for (;;) {
    my ($xo,$yo);
    if (($level % 6) == 0) {
      $xo = $yend0;     # T
      $yo = $xend0;
    } elsif (($level % 6) == 1) {
      $xo = $yend0;      # -90
      $yo = - $xend0;
    } elsif (($level % 6) == 2) {
      $xo = $xend0;     # T -90
      $yo = - $yend0;

    } elsif (($level % 6) == 3) {
      ### T
      $xo = $yend0;     # T
      $yo = $xend0;
    } elsif (($level % 6) == 4) {
      $xo = - $yend0;     # +90
      $yo = $xend0;
    } elsif (($level % 6) == 5) {
      $xo = - $xend0;     # T +90
      $yo = $yend0;
    }

    ($f1,$f0) = ($f1+$f0,$f1);
    ($xend1,$xend0) = ($xend1+$xo,$xend1);
    ($yend1,$yend0) = ($yend1+$yo,$yend1);
    $level++;

    ### consider: "f1=$f1  xy end $xend1,$yend1"
    if ($xend1 > $x2 && $yend1 > $y2) {
      return (0, $f1);
    }
  }
}

1;
__END__

=for stopwords eg Ryde C Math-PlanePath Nlevel Heighway Harter et al vertices doublings OEIS Online

=head1 NAME

Math::PlanePath::MathImageFibonacciWordFractal -- turns by Fibonacci word bits

=head1 SYNOPSIS

 use Math::PlanePath::MathImageFibonacciWordFractal;
 my $path = Math::PlanePath::MathImageFibonacciWordFractal->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress...>

This is an integer version of the Fibonacci word fractal by Alexis
Monnerot-Dumaine.  It makes turns controlled by by the "Fibonacci word" or
"golden string" sequence

    11  | 27-28-29    33-34-35          53-54-55    59-60-61
        |  |     |     |     |           |     |     |     |
    10  | 26    30-31-32    36          52    56-57-58    62
        |  |                 |           |                 |
     9  | 25-24          38-37          51-50          64-63
        |     |           |                 |           |
     8  |    23          39    43-44-45    49          65
        |     |           |     |     |     |           |
     7  | 21-22          40-41-42    46-47-48          66-67
        |  |                                               |
     6  | 20    16-15-14                      74-73-72    68
        |  |     |     |                       |     |     |
     5  | 19-18-17    13                      75    71-70-69
        |              |                       |
     4  |          11-12                      76-77         
        |           |                             |         
     3  |          10                            78         
        |           |                             |         
     2  |           9--8                      80-79         
        |              |                       |                
     1  |  1--2--3     7                      81    85-86-87    
        |  |     |     |                       |     |     |    
    Y=0 |  0     4--5--6                      82-83-84    88-89-...
        +-------------------------------------------------------
          X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 

A current direction up,down,left,right is maintained, initially up.  The
path goes one in that direction then if the Fibonacci word is 0 then turn to
the left if N is even or to the right if N is odd.  For example at N=0 draw
up to N=1 and the Fibonacci word at N=0 is 0 and N even so change direction
to the right (for the N=1 to N=2 segment).

     N     Fibonacci word
    ---    --------------
     0       0    turn right
     1       1    
     2       0    turn right
     3       0    turn left
     4       1
     5       0    turn left
     6       1

The result is self-similar blocks within the first quadrant
(XE<gt>=0,YE<gt>=0).  New blocks extend from N values which are Fibonacci
numbers.  For example at N=21 begins a new block above, then N=34 a new
block across, N=55 down, N=89 across again, etc.

The new blocks are a copy of the shape starting N=0, rotated and/or
transposed according to the replication level mod 6,

    level mod 6      new block
    -----------      ---------
       0              transpose
       1                         rotate -90
       2              transpose, rotate -90
       3              transpose
       4                         rotate +90
       5              transpose, rotate +90

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageFibonacciWordFractal-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The curve visits an C<$x,$y> twice for various points (all the "inside"
points).  In the current code the smaller of the two N values is returned.
Is that the best way?

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>

Alexis Monnerot-Dumaine "The Fibonacci Word Fractal", February 2009

    http://hal.archives-ouvertes.fr/hal-00367972_v1/
    http://hal.archives-ouvertes.fr/docs/00/36/79/72/PDF/The_Fibonacci_word_fractal.pdf

=cut

# Local variables:
# compile-command: "math-image --path=MathImageFibonacciWordFractal --lines --scale=20"
# End:
#
# math-image --path=MathImageFibonacciWordFractal --output=numbers_dash
