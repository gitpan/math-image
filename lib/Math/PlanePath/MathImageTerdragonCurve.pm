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


package Math::PlanePath::MathImageTerdragonCurve;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 86;

use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

use constant n_start => 0;
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

use constant parameter_info_array =>
  [ { name      => 'arms',
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

my @rot_to_si = (1,0,0, -1,0,0);
my @rot_to_sj = (0,1,0, 0,-1,0);
my @rot_to_sk = (0,0,1, 0,0,-1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageTerdragonCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;          # BigFloat int() gives BigInt, use that
  }

  my $zero = ($n * 0);  # inherit bignum 0

  # initial rotation from arm number
  my $arms = $self->{'arms'};
  my $rot = $n % $arms;
  $n = int($n/$arms);

  my @digits;
  my (@si, @sj, @sk);  # vectors
  {
    my $si = $zero + 1; # inherit bignum 1
    my $sj = $zero;     # inherit bignum 0
    my $sk = $zero;     # inherit bignum 0

    for (;;) {
      push @digits, ($n % 3);
      push @si, $si;
      push @sj, $sj;
      push @sk, $sk;
      ### push: "digit $digits[-1]   $si,$sj,$sk"

      $n = int($n/3) || last;

      # straight + rot120 + straight
      ($si,$sj,$sk) = (2*$si - $sj,
                       2*$sj - $sk,
                       2*$sk + $si);
    }
  }
  ### @digits

  my $rev = 0;
  my $i = $zero;
  my $j = $zero;
  my $k = $zero;
  while (defined (my $digit = pop @digits)) {  # digits high to low
    my $si = pop @si;
    my $sj = pop @sj;
    my $sk = pop @sk;
    ### at: "$i,$j,$k  $digit   side $si,$sj,$sk"
    ### $rot

    $rot %= 6;
    if ($rot == 1)    { ($si,$sj,$sk) = (-$sk,$si,$sj); }
    elsif ($rot == 2) { ($si,$sj,$sk) = (-$sj,-$sk,$si); }
    elsif ($rot == 3) { ($si,$sj,$sk) = (-$si,-$sj,-$sk); }
    elsif ($rot == 4) { ($si,$sj,$sk) = ($sk,-$si,-$sj); }
    elsif ($rot == 5) { ($si,$sj,$sk) = ($sj,$sk,-$si); }

    # if ($rev) {
    # if ($digit) {
    #   $x -= $sy;
    #   $y += $sx;
    #   ### rev add to: "$x,$y next is still rev"
    # } else {
    #   $rot ++;
    #   $rev = 0;
    # }

    if ($digit) {
      $i += $si;  # digit=1 or digit=2
      $j += $sj;
      $k += $sk;
      if ($digit == 2) {
        $i -= $sj;  # digit=2, straight+rot120
        $j -= $sk;
        $k += $si;
      } else {
        $rot += 2;  # digit=1
      }
    }
  }

  $rot %= 6;
  $i = $frac * $rot_to_si[$rot] + $i;
  $j = $frac * $rot_to_sj[$rot] + $j;
  $k = $frac * $rot_to_sk[$rot] + $k;

  ### final: "$i,$j,$k"
  return (2*$i + $j - $k, $j+$k);
}


# maximum extent -- no, not quite right
#
#          .----*
#           \
#       *----.
#
# Two triangle heights, so
#     rnext = 2 * r * sqrt(3)/2
#           = r * sqrt(3)
#     rsquared_next = 3 * rsquared
# Initial X=2,Y=0 is rsquared=4
# then X=3,Y=1 is 3*3+3*1*1 = 9+3 = 12 = 4*3
# then X=3,Y=3 is 3*3+3*3*3 = 9+3 = 36 = 4*3^2
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### TerdragonCurve xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my ($pow,$exp) = _round_down_pow ($x*$x + 3*$y*$y,
                                    3);
  my $level_limit = $exp + 6;
  if (_is_infinite($level_limit)) {
    return $level_limit;  # infinity
  }

  my $arms = $self->{'arms'};
  my @hypot = (4);
  for (my $top = 0; $top < $level_limit; $top++) {
    push @hypot, ($top % 8 ? 4 : 3) * $hypot[$top];  # little faster than 3^lev

    # start from digits=1 but use (n-1)*arms so that n=0,1,...,$arms-1 are
    # tried too, done by $arm -6 to -1
  ARM: foreach my $arm (-$arms .. -1) {
      my @digits = (((0) x $top), 1);
      my $i = $top;
      for (;;) {
        my $n = 0;
        foreach my $digit (reverse @digits) { # high to low
          $n = 3*$n + $digit;
        }
        $n = $arms*$n + $arm;
        ### consider: "arm=$arm i=$i  digits=".join(',',reverse @digits)."  is n=$n"

        my ($nx,$ny) = $self->n_to_xy($n);
        ### at: "n pos $nx,$ny  cf hypot ".$hypot[$i]

        if ($i == 0 && $x == $nx && $y == $ny) {
          ### found ...
          return $n;
        }

        if ($i == 0 || ($x-$nx)**2 + 3*($y-$ny)**2 > $hypot[$i]) {
          ### too far away: "$nx,$ny target $x,$y    ".(($x-$nx)**2 + 3*($y-$ny)**2).' vs '.$hypot[$i]

          while (++$digits[$i] > 2) {
            $digits[$i] = 0;
            if (++$i > $top) {
              ### backtrack past top ...
              next ARM;
            }
            ### backtrack up ...
          }

        } else {
          ### descend ...
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

# minimum  -- no, not quite right
#
#                *----------*
#                 \
#                  \   *
#               *   \
#                    \
#          *----------*
#
# width = side/2
# minimum = side*sqrt(3)/2 - width
#         = side*(sqrt(3)/2 - 1)
#
# minimum 4/9 * 2.9^level roughly
# h = 4/9 * 2.9^level
# 2.9^level = h*9/4
# level = log(h*9/4)/log(2.9)
# 3^level = 3^(log(h*9/4)/log(2.9))
#         = h*9/4, but big bigger for log
#
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageTerdragonCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"
  my $xmax = _max(abs($x1),abs($x2));
  my $ymax = _max(abs($y1),abs($y2));
  return (0,
          $self->{'arms'} * ($xmax*$xmax + 3*$ymax*$ymax) * 3);
}

1;
__END__

=for stopwords eg Ryde Dragon Math-PlanePath Nlevel Knuth et al vertices doublings OEIS Online terdragon

=head1 NAME

Math::PlanePath::MathImageTerdragonCurve -- triangular dragon curve

=head1 SYNOPSIS

 use Math::PlanePath::MathImageTerdragonCurve;
 my $path = Math::PlanePath::MathImageTerdragonCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress ...>

This is the terdragon curve by Davis and Knuth,


              30                28                                  7
           /       \         /       \
     31/34 -------- 26/29/32 ---------  27                          6
          \        /         \
           24/33/42 ---------- 22/25                                5
          /        \         /       \
  40/43/46 -------- 20/23/44 -------- 12/21            10           4
           \       /        \        /      \       /       \
             18/45 --------- 13/16/19 ------ 8/11/14 -------- 9     3
                    \       /       \       /       \
                       17              6/15 --------- 4/7           2
                                             \      /     \
                                               2/5 ---------  3     1
                                                   \
                                         0 ----------- 1         <-Y=0

       ^       ^        ^        ^       ^      ^      ^      ^
      -4      -3       -2       -1      X=0     1      2      3

The curve visits "inner" X,Y points three times, and outside points either
once or twice.  The first triple point is X=1,Y=3 which is N=8, N=11 and
N=14.  The curve N=7,8,9 make a vertex there, as does N=10,11,12 and
N=13,14,15.  The curve touches, but doesn't cross itself.  The tripled
vertices are all like this, touching but not crossing, and no edges repeat.

The first step N=1 is to the right along the X axis and the path then slowly
spirals counter-clockwise and progressively fatter.  The end of each
replication is

    Nlevel = 3^level

That point is at level*30 degrees around (as reckoned with the usual
Y*sqrt(3) for a triangular grid, per L<Math::PlanePath/Triangular Lattice>).

    Nlevel     X,Y     angle (degrees)
    ------    -----    -----
      1        1,0        0
      3        3,1       30
      9        3,3       60
     27        0,6       90
     81       -9,9      120
    243      -27,9      150
    729      -54,0      180

The following is points N=0 to N=3^6=729 going half-circle around to 180
degrees.  The N=0 origin is marked "o" and the N=729 end marked "e".

=cut

# generated by
# math-image --path=MathImageTerdragonCurve --expression='i<=729?i:0' --text --size=132x40

=pod

                               * *               * *
                            * * * *           * * * *
                           * * * *           * * * *
                            * * * * *   * *   * * * * *   * *
                         * * * * * * * * * * * * * * * * * * *
                        * * * * * * * * * * * * * * * * * * *
                         * * * * * * * * * * * * * * * * * * * *
                            * * * * * * * * * * * * * * * * * * *
                           * * * * * * * * * * * *   * *   * * *
                      * *   * * * * * * * * * * * *           * *
     * e           * * * * * * * * * * * * * * * *           o *
    * *           * * * * * * * * * * * *   * *
     * * *   * *   * * * * * * * * * * * *
    * * * * * * * * * * * * * * * * * * *
     * * * * * * * * * * * * * * * * * * * *
        * * * * * * * * * * * * * * * * * * *
       * * * * * * * * * * * * * * * * * * *
        * *   * * * * *   * *   * * * * *
                 * * * *           * * * *
                * * * *           * * * *
                 * *               * *

=cut

# =head2 Turns
#
# At each point N the curve always turns 120 degrees either to the left or
# right, it never goes straight ahead.  If N is written in ternary then ...
#
#     Ndigit      Turn
#     ------      ----
#       0
#       1
#       2

=head2 Arms

The curve fills a sixth of the plane and six copies mesh together perfectly
when rotated by 60, 120, 180, 240 and 300 degrees.  The C<arms> parameter
can choose 1 to 6 curve arms successively advancing.

For example C<arms =E<gt> 6> begins as follows, with N=0,6,12,18,etc being
one arm, N=1,7,13,19 the second, N=2,8,14,20 the third, etc.

                  8/13/31 -----------------  7/12/30
                /        \                 /          \
              /            \             /              \
      9/14/32 ------------- 0/1/2/3/4/5 ----------------  6/17/35
              \            /            \              /
                \        /                \          /
                 10/15/33 ----------------- 11/16/34

With six arms every X,Y point is visited three times (except the origin 0,0
where all six begin) and every edge between the points is traversed once.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageTerdragonCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::MathImageTerdragonCurve-E<gt>new (arms =E<gt> 6)>

Create and return a new path object.

The optional C<arms> parameter can make 1 to 6 copies of the curve, each arm
successively advancing.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The curve can visit an C<$x,$y> up to three times.  In the current code the
smaller of the these N values is returned.  Is that the best way?

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 OEIS

The terdragon is in Sloane's Online Encyclopedia of Integer Sequences as the
turn at each line segment,

    http://oeis.org/A080846  etc

    A080846 -- turn 0=left,1=right, by 120 degrees
    A060236 -- turn 1=left,2=right, by 120 degrees
    A038502 -- taken mod 3 is turn 1=left,2=right
    A026225 -- N positions of left turns
    A026179 -- N positions of right turns (except initial 1)

A026179 starts with a value 1 arising from its morphism definition but that
value should be skipped to consider it as turns.  At N=1 the curve is a left
turn (value 1 is in the A026225 left turns sequence).

=head1 BUGS

C<xy_to_n()> is a bit slow due to doing a crude backtracking digits search.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>

=cut

# Local variables:
# compile-command: "math-image --path=MathImageTerdragonCurve --lines --scale=20"
# End:
#
# math-image --path=MathImageTerdragonCurve --all --scale=10
