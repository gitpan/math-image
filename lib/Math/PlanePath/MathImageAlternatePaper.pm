# Copyright 2011, 2012 Kevin Ryde

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


# math-image --path=MathImageAlternatePaper --output=numbers --all
# math-image --path=MathImageAlternatePaper --expression='i<=32?i:0' --output=numbers --size=60

package Math::PlanePath::MathImageAlternatePaper;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 89;

use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;
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
                                         description => 'Arms',
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

sub n_to_xy {
  my ($self, $n) = @_;
  ### AlternatePaper n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;          # BigFloat int() gives BigInt, use that
  }

  my $zero = ($n * 0);  # inherit bignum 0

  # initial rotation from arm number $n mod $arms
  my $arms = $self->{'arms'};
  my $rot = $n % $arms;
  $n = int($n/$arms);

  my @digits;
  my @sx;
  my @sy;
  {
    my $sy = $zero;   # inherit BigInt
    my $sx = $sy + 1; # inherit BigInt
    ### $sx
    ### $sy

    while ($n) {
      push @digits, ($n % 2);
      $n = int($n/2);
      push @sx, $sx;
      push @sy, $sy;

      # (sx,sy) + rot+90(sx,sy)
      ($sx,$sy) = ($sx - $sy,
                   $sy + $sx);

      push @digits, ($n % 2);
      $n = int($n/2);
      push @sx, $sx;
      push @sy, $sy;

      # (sx,sy) + rot-90(sx,sy)
      ($sx,$sy) = ($sx + $sy,
                   $sy - $sx);
    }
  }

  ### @digits
  my $rev = 0;
  my $x = $zero;
  my $y = $zero;
  while (defined (my $digit = pop @digits)) {
    {
      my $sx = pop @sx;
      my $sy = pop @sy;
      ### at: "$x,$y  $digit   side $sx,$sy"
      ### $rot

      if ($rot & 2) {
        ($sx,$sy) = (-$sx,-$sy);
      }
      if ($rot & 1) {
        ($sx,$sy) = (-$sy,$sx);
      }

      if ($rev) {
        if ($digit) {
          $x -= $sy;
          $y += $sx;
          ### rev add to: "$x,$y next is still rev"
        } else {
          $rot ++;
          $rev = 0;
        }
      } else {
        if ($digit) {
          $rot ++;
          $x += $sx;
          $y += $sy;
          $rev = 1;
          ### add to: "$x,$y next is rev"
        }
      }
    }
      $digit = pop @digits;
      last if ! defined $digit;
    {
      my $sx = pop @sx;
      my $sy = pop @sy;
      ### at: "$x,$y  $digit   side $sx,$sy"
      ### $rot

      if ($rot & 2) {
        ($sx,$sy) = (-$sx,-$sy);
      }
      if ($rot & 1) {
        ($sx,$sy) = (-$sy,$sx);
      }

      if ($rev) {
        if ($digit) {
          $x += $sy;
          $y -= $sx;
          ### rev add to: "$x,$y next is still rev"
        } else {
          $rot --;
          $rev = 0;
        }
      } else {
        if ($digit) {
          $rot --;
          $x += $sx;
          $y += $sy;
          $rev = 1;
          ### add to: "$x,$y next is rev"
        }
      }
    }
  }
  if ($rev) {
    $rot += 2;
  }
  $rot &= 3;
  $x = $frac * $rot_to_sx[$rot] + $x;
  $y = $frac * $rot_to_sy[$rot] + $y;

  ### final: "$x,$y"
  return ($x,$y);
}

# point N=2^(2k) at XorY=+/-2^k  radius 2^k
#       N=2^(2k-1) at X=Y=+/-2^(k-1) radius sqrt(2)*2^(k-1)
# radius = sqrt(2^level)
# R(l)-R(l-1) = sqrt(2^level) - sqrt(2^(level-1))
#             = sqrt(2^level) * (1 - 1/sqrt(2))
# about 0.29289
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### AlternatePaper xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my ($len,$level) = _round_down_pow($x, 4);
  if (_is_infinite($level)) {
    return $level;  # infinity
  }

  return undef;

  my $n = $x * 0 * $y;  # inherit bignum 0
  while ($level-- > 0) {
    #      /|
    #     / |
    #    /__|
    #   /|\ |
    #  / | \|
    # /------
    # x-y > x+y
    #
    $n *= 2;
    if ($x >= $len) {
    } else {
      if ($x+$y >= $len) {
        $n += 1;
        ($x,$y) = ($y, $len-$x);   # X to origin, then rotate -90
      }
    }
  }
  ### not found below level limit
  return undef;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### AlternatePaper rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest($x1);
  $x2 = _round_nearest($x2);
  $y1 = _round_nearest($y1);
  $y2 = _round_nearest($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0 || $y1 > $x2) {
    return (1,0);
  }

  my ($len, $level) =_round_down_pow ($x2, 4);
  return (0, 16*$len*$len-1);
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath Nlevel et al vertices doublings OEIS Online

=head1 NAME

Math::PlanePath::MathImageAlternatePaper -- alternate paper folding curve

=head1 SYNOPSIS

 use Math::PlanePath::MathImageAlternatePaper;
 my $path = Math::PlanePath::MathImageAlternatePaper->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the alternate paper folding curve,

      4                               32----...
                                      |
      3                        10---11/31----30
                               |      |      |
      2                  8----9/13--12/28--29/25----24
                         |     |      |      |      |
      1           2-----3/7---6/14--15/27--26/18--19/23---22
                  |      |     |      |      |      |      |
    Y=0    0------1      4-----5     16-----17     20-----21

           X=0    1      2     3      4      5      6      7

The curve visits "inside" X,Y points twice.  The first of these is X=2,Y=1
which is N=3 and also N=7.  The corners N=2,3,4 and N=6,7,8 have touched,
but the path doesn't cross itself.  The doubled vertices are all like this,
touching but not crossing, and no edges repeating.

The first step N=1 is to the right along the X axis and the path fills the
eighth of the plane below X=Y.  The end of each replication is N=2^level ...

=head2 Paper Folding

The path arises from thinking of a long strip of paper folded in half
repeatedly and alternately one way and the other, then unfolded so each
crease is a 90 degree angle.  The effect is that the curve repeats in
successive doublings turned by 90 degrees and reversed.  For example the
first segment unfolds,

                                         2
                                    ->   |
                    unfold         /     |
                                  |      |
                                         |
    0------1                     0-------1

Then it unfolds again from the end "2", but on the opposite side of the
curve,

                                         2-------3
           2                             |       |
           |        unfold               |   ^   |
           |                             | _/    |
           |                             |       |
    0------1                     0-------1       4

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageAlternatePaper-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 OEIS

The alternate paper folding curve is in Sloane's Online Encyclopedia of
Integer Sequences as,

    http://oeis.org/A106665  (etc)

    A106665 -- turn, 0=left,1=right

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>

=cut
