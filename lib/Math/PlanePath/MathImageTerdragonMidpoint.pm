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

package Math::PlanePath::MathImageTerdragonMidpoint;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 84;

use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

use Math::PlanePath::MathImageTerdragonCurve;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant n_start => 0;
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

use constant parameter_info_array => [ { name      => 'arms',
                                         share_key => 'arms_6',
                                         type      => 'integer',
                                         minimum   => 1,
                                         maximum   => 6,
                                         default   => 1,
                                         width     => 1,
                                         description => 'Arms',
                                       } ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 6) { $arms = 6; }
  $self->{'arms'} = $arms;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageTerdragonMidpoint n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  {
    my $int = int($n);
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my ($x1,$y1) = $self->Math::PlanePath::MathImageTerdragonCurve::n_to_xy($n);
  my ($x2,$y2) = $self->Math::PlanePath::MathImageTerdragonCurve::n_to_xy($n+$self->{'arms'});

  $x1 *= 2;
  $y1 *= 2;
  $x2 *= 2;
  $y2 *= 2;
  my $dx = $x2-$x1;
  my $dy = $y2-$y1;
  return ($x1 + $dx/2,
          $y1 + ($dy)/2);
}

# sub n_to_xy {
#   my ($self, $n) = @_;
#   ### MathImageTerdragonMidpoint n_to_xy(): $n
# 
#   if ($n < 0) { return; }
#   if (_is_infinite($n)) { return ($n, $n); }
# 
#   my $frac;
#   {
#     my $int = int($n);
#     $frac = $n - $int;  # inherit possible BigFloat
#     $n = $int;          # BigFloat int() gives BigInt, use that
#   }
# 
#   my $zero = ($n * 0);  # inherit bignum 0
# 
#   my $arms = $self->{'arms'};
#   my $rot = $n % $arms;
#   $n = int($n/$arms);
# 
#   # ENHANCE-ME: sx,sy just from len,len
#   my @digits;
#   my @sx;
#   my @sy;
#   {
#     my $sx = $zero + 1;
#     my $sy = -$sx;
#     while ($n) {
#       push @digits, ($n % 2);
#       push @sx, $sx;
#       push @sy, $sy;
#       $n = int($n/2);
# 
#       # (sx,sy) + rot+90(sx,sy)
#       ($sx,$sy) = ($sx - $sy,
#                    $sy + $sx);
#     }
#   }
# 
#   ### @digits
#   my $rev = 0;
#   my $x = $zero;
#   my $y = $zero;
#   my $above_low_zero = 0;
# 
#   for (my $i = $#digits; $i >= 0; $i--) {     # high to low
#     my $digit = $digits[$i];
#     my $sx = $sx[$i];
#     my $sy = $sy[$i];
#     ### at: "$x,$y  $digit   side $sx,$sy"
#     ### $rot
# 
#     if ($rot & 2) {
#       $sx = -$sx;
#       $sy = -$sy;
#     }
#     if ($rot & 1) {
#       ($sx,$sy) = (-$sy,$sx);
#     }
#     ### rotated side: "$sx,$sy"
# 
#     if ($rev) {
#       if ($digit) {
#         $x += -$sy;
#         $y += $sx;
#         ### rev add to: "$x,$y next is still rev"
#       } else {
#         $above_low_zero = $digits[$i+1];
#         $rot ++;
#         $rev = 0;
#         ### rev rot, next is no rev ...
#       }
#     } else {
#       if ($digit) {
#         $rot ++;
#         $x += $sx;
#         $y += $sy;
#         $rev = 1;
#         ### plain add to: "$x,$y next is rev"
#       } else {
#         $above_low_zero = $digits[$i+1];
#       }
#     }
#   }
# 
#   # Digit above the low zero is the direction of the next turn, 0 for left,
#   # 1 for right.
#   #
#   ### final: "$x,$y  rot=$rot  above_low_zero=".($above_low_zero||0)
# 
#   if ($rot & 2) {
#     $frac = -$frac;  # rotate 180
#     $x -= 1;
#   }
#   if (($rot+1) & 2) {
#     # rot 1 or 2
#     $y += 1;
#   }
#   if (!($rot & 1) && $above_low_zero) {
#     $frac = -$frac;
#   }
#   $above_low_zero ^= ($rot & 1);
#   if ($above_low_zero) {
#     $y = $frac + $y;
#   } else {
#     $x = $frac + $x;
#   }
# 
#   ### rotated offset: "$x_offset,$y_offset   return $x,$y"
#   return ($x,$y);
# }

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MathImageTerdragonMidpoint xy_to_n(): "$x, $y"

  return undef;




  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my ($power,$level_limit) = _round_down_pow (abs($x)+abs($y),
                                             2);
  $level_limit = 2*$level_limit + 6;
  if (_is_infinite($level_limit)) {
    return $level_limit;  # infinity
  }

  my $arms = $self->{'arms'};
  my @hypot = (5);
  for (my $top = 0; $top < $level_limit; $top++) {
    push @hypot, ($top % 4 ? 2 : 3) * $hypot[$top];  # little faster than 2^lev

    # start from digits=1 but subtract 1 so that n=0,1,...,$arms-1 are tried
    # too
  ARM: foreach my $arm (-$arms .. 0) {
      my @digits = (((0) x $top), 1);
      my $i = $top;
      for (;;) {
        my $n = 0;
        foreach my $digit (reverse @digits) { # high to low
          $n = 2*$n + $digit;
        }
        $n = $arms*$n + $arm;
        ### consider: "arm=$arm i=$i  digits=".join(',',reverse @digits)."  is n=$n"

        my ($nx,$ny) = $self->n_to_xy($n);
        ### at: "n $nx,$ny  cf hypot ".$hypot[$i]

        if ($i == 0 && $x == $nx && $y == $ny) {
          ### found
          return $n;
        }

        if ($i == 0 || ($x-$nx)**2 + ($y-$ny)**2 > $hypot[$i]) {
          ### too far away: "$nx,$ny target $x,$y    ".(($x-$nx)**2 + ($y-$ny)**2).' vs '.$hypot[$i]

          while (++$digits[$i] > 1) {
            $digits[$i] = 0;
            if (++$i >= $top) {
              ### backtrack past top ...
              next ARM;
            }
            ### backtrack up
          }

        } else {
          ### descend
          ### assert: $i > 0
          $i--;
          $digits[$i] = 0;
        }
      }
    }
  }
  ### not found below level limit
  return undef;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageTerdragonMidpoint rect_to_n_range(): "$x1,$y1  $x2,$y2  arms=$self->{'arms'}"
  $x1 = abs($x1);
  $x2 = abs($x2);
  $y1 = abs($y1);
  $y2 = abs($y2);
  my $xmax = int(_max($x1,$x2));
  my $ymax = int(_max($y1,$y2));
  return (0,
          ($xmax*$xmax + 3*$ymax*$ymax + 1) * $self->{'arms'} * 5);
}

# sub rect_to_n_range {
#   my ($self, $x1,$y1, $x2,$y2) = @_;
#   ### MathImageTerdragonMidpoint rect_to_n_range(): "$x1,$y1  $x2,$y2"
#
#   return Math::PlanePath::MathImageTerdragonCurve->rect_to_n_range
#     (sqrt(2)*$x1, sqrt(2)*$y1, sqrt(2)*$x2, sqrt(2)*$y2);
# }

1;
__END__

=for stopwords eg Ryde Terdragon Math-PlanePath Nlevel Davis Knuth et al TerdragonCurve MathImageTerdragonMidpoint terdragon

=head1 NAME

Math::PlanePath::MathImageTerdragonMidpoint -- dragon curve midpoints

=head1 SYNOPSIS

 use Math::PlanePath::MathImageTerdragonMidpoint;
 my $path = Math::PlanePath::MathImageTerdragonMidpoint->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress ...>

This is an integer version of the terdragon paper folding curve by Davis and
Knuth, following the midpoint of each edge of the curve segments.



     ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^
    -10 -9  -8  -7  -6  -5  -4  -3  -2  -1  X=0  1

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageTerdragonMidpoint-E<gt>new ()>

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
L<Math::PlanePath::DragonMidpoint>

=cut


# Local variables:
# compile-command: "math-image --path=MathImageTerdragonMidpoint --lines --scale=40"
# End:
#
# math-image --path=MathImageTerdragonMidpoint --all --output=numbers_dash