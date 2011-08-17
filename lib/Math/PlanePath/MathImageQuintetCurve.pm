# rect range not done



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

use vars '$VERSION', '@ISA';
$VERSION = 67;

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
  $n += $arms-1;
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
  $n = int($n/$arms);

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
  ### QuintetCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"

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

Math::PlanePath::MathImageQuintetCurve -- Mandelbrot quintet "cross" curve

=head1 SYNOPSIS

 use Math::PlanePath::MathImageQuintetCurve;
 my $path = Math::PlanePath::MathImageQuintetCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is an integer version of the ...


    ^
   X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 ...

=head1 FUNCTIONS

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
