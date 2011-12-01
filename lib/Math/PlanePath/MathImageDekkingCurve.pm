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


package Math::PlanePath::MathImageDekkingCurve;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 82;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

# tables generated by tools/dekking-curve-table.pl
#
my @next_state = (  0,  0,175,100, 25,
                    0,175,100, 50,175,
                    0,  0,150, 25,150,
                   75, 75,100, 75,125,
                  150, 25,  0,125,125,
                   25, 25,100,125, 50,
                   25,100,125, 75,100,
                   25, 25,175, 50,175,
                    0,  0,125,  0,150,
                  175, 50, 25,150,150,
                   50, 50,125,150, 75,
                   50,125,150,  0,125,
                   50, 50,100, 75,100,
                   25, 25,150, 25,175,
                  100, 75, 50,175,175,
                   75, 75,150,175,  0,
                   75,150,175, 25,150,
                   75, 75,125,  0,125,
                   50, 50,175, 50,100,
                  125,  0, 75,100,100,
                   25, 25,100,125, 50,
                   25,175,  0,175,175,
                   50,125, 50,100,100,
                   75,150,  0, 75,100,
                  125,  0, 75,100,100,
                   50, 50,125,150, 75,
                   50,100, 25,100,100,
                   75,150, 75,125,125,
                    0,175, 25,  0,125,
                  150, 25,  0,125,125,
                   75, 75,150,175,  0,
                   75,125, 50,125,125,
                    0,175,  0,150,150,
                   25,100, 50, 25,150,
                  175, 50, 25,150,150,
                    0,  0,175,100, 25,
                    0,150, 75,150,150,
                   25,100, 25,175,175,
                   50,125, 75, 50,175,
                  100, 75, 50,175,175);
my @digit_to_x = (0,1,2,1,0, 1,2,1,0,0, 0,1,2,2,3, 4,4,3,3,2, 3,3,4,4,4,
                  4,4,4,3,3, 2,2,1,2,1, 0,0,1,0,0, 0,1,1,2,3, 4,3,2,3,4,
                  4,3,2,3,4, 3,2,3,4,4, 4,3,2,2,1, 0,0,1,1,2, 1,1,0,0,0,
                  0,0,0,1,1, 2,2,3,2,3, 4,4,3,4,4, 4,3,3,2,1, 0,1,2,1,0,
                  4,4,4,3,3, 2,3,3,4,4, 3,2,2,1,0, 0,0,1,2,1, 0,1,2,1,0,
                  4,3,2,3,4, 3,2,1,1,0, 0,0,1,0,0, 1,2,1,2,2, 3,3,4,4,4,
                  0,0,0,1,1, 2,1,1,0,0, 1,2,2,3,4, 4,4,3,2,3, 4,3,2,3,4,
                  0,1,2,1,0, 1,2,3,3,4, 4,4,3,4,4, 3,2,3,2,2, 1,1,0,0,0);
my @digit_to_y = (0,0,0,1,1, 2,2,3,2,3, 4,4,3,4,4, 4,3,3,2,1, 0,1,2,1,0,
                  0,1,2,1,0, 1,2,1,0,0, 0,1,2,2,3, 4,4,3,3,2, 3,3,4,4,4,
                  4,4,4,3,3, 2,2,1,2,1, 0,0,1,0,0, 0,1,1,2,3, 4,3,2,3,4,
                  4,3,2,3,4, 3,2,3,4,4, 4,3,2,2,1, 0,0,1,1,2, 1,1,0,0,0,
                  0,1,2,1,0, 1,2,3,3,4, 4,4,3,4,4, 3,2,3,2,2, 1,1,0,0,0,
                  4,4,4,3,3, 2,3,3,4,4, 3,2,2,1,0, 0,0,1,2,1, 0,1,2,1,0,
                  4,3,2,3,4, 3,2,1,1,0, 0,0,1,0,0, 1,2,1,2,2, 3,3,4,4,4,
                  0,0,0,1,1, 2,1,1,0,0, 1,2,2,3,4, 4,4,3,2,3, 4,3,2,3,4);
my @xy_to_digit = ( 0, 4, 8, 9,10,
                    1, 3, 5, 7,11,
                    2,19, 6,12,13,
                   20,21,18,17,14,
                   24,23,22,16,15,
                   10,11,13,14,15,
                    9, 7,12,17,16,
                    8, 5, 6,18,22,
                    4, 3,19,21,23,
                    0, 1, 2,20,24,
                   15,16,22,23,24,
                   14,17,18,21,20,
                   13,12, 6,19, 2,
                   11, 7, 5, 3, 1,
                   10, 9, 8, 4, 0,
                   24,20, 2, 1, 0,
                   23,21,19, 3, 4,
                   22,18, 6, 5, 8,
                   16,17,12, 7, 9,
                   15,14,13,11,10,
                   24,20,16,15,14,
                   23,21,19,17,13,
                   22, 5,18,12,11,
                    4, 3, 6, 7,10,
                    0, 1, 2, 8, 9,
                   14,13,11,10, 9,
                   15,17,12, 7, 8,
                   16,19,18, 6, 2,
                   20,21, 5, 3, 1,
                   24,23,22, 4, 0,
                    9, 8, 2, 1, 0,
                   10, 7, 6, 3, 4,
                   11,12,18, 5,22,
                   13,17,19,21,23,
                   14,15,16,20,24,
                    0, 4,22,23,24,
                    1, 3, 5,21,20,
                    2, 6,18,19,16,
                    8, 7,12,17,15,
                    9,10,11,13,14);

sub n_to_xy {
  my ($self, $n) = @_;
  ### DekkingCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  {
    # ENHANCE-ME: determine dx/dy direction from N bits, not full
    # calculation of N+1
    my $int = int($n);
    if ($n != $int) {
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;
  }

  my @digits;
  my $len = $n*0 + 1;   # inherit bignum 1
  while ($n) {
    push @digits, $n % 25;
    $n = int($n/25);
    $len *= 5;
  }
  ### digits: join(', ',@digits)."   count ".scalar(@digits)
  ### $len

  my $state = 0;
  my $x = 0;
  my $y = 0;

  while (@digits) {
    $len /= 5;
    $state += pop @digits;

    ### $len
    ### $state
    ### digit_to_x: $digit_to_x[$state]
    ### digit_to_y: $digit_to_y[$state]
    ### next_state: $next_state[$state]

    $x += $len * $digit_to_x[$state];
    $y += $len * $digit_to_y[$state];
    $state = $next_state[$state];
  }

  ### final: "$x,$y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DekkingCurve xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  if (_is_infinite($x)) {
    return $x;
  }
  if (_is_infinite($y)) {
    return $y;
  }

  my ($len, $level) = _round_down_pow (($x > $y ? $x : $y),
                                       5);
  ### $len
  ### $level

  my $n = ($x * 0 * $y);
  my $state = 0;
  while ($level-- >= 0) {
    ### at: "$x,$y  len=$len level=$level"
    ### assert: $x >= 0
    ### assert: $y >= 0
    ### assert: $x < 5*$len
    ### assert: $y < 5*$len

    my $xo = int ($x / $len);
    my $yo = int ($y / $len);
    ### assert: $xo >= 0
    ### assert: $xo <= 4
    ### assert: $yo >= 0
    ### assert: $yo <= 4

    $x %= $len;
    $y %= $len;
    ### xy bits: "$xo, $yo"

    my $digit = $xy_to_digit[$state + 5*$xo + $yo];
    $state = $next_state[$state+$digit];
    $n = 25*$n + $digit;
    $len /= 5;
  }

  ### assert: $x == 0
  ### assert: $y == 0

  return $n;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DekkingCurve rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;

  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);
  }

  my ($len, $level) = _round_down_pow (($x2 > $y2 ? $x2 : $y2),
                                       5);
  ### $len
  ### $level
  return (0, 25*$len*$len-1);
}

1;
__END__

=for stopwords eg Ryde ie DekkingCurve Math-PlanePath Dekking

=head1 NAME

Math::PlanePath::MathImageDekkingCurve -- 5x5 self-similar

=head1 SYNOPSIS

 use Math::PlanePath::MathImageDekkingCurve;
 my $path = Math::PlanePath::MathImageDekkingCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress ...>

This is an integer version of a 5x5 self-similar curve by Dekking,

     14                        135-136 138-139-140 174 170 166-165-164 
                                 |    \  |       |   |   |\   \      | 
     13                        134 132 137 142-141 173 171 169 167 163 
                                 |/   \      |       |/      |/   /    
     12                        133 130-131 143 147 172 155 168 162-161 
                                  /       /   /  |    /   \          | 
     11                        129-128 144 146 148 154-153 156-157 160 
                                      \   \  |   |        \      |   | 
     10                        125-126-127 145 149-150-151-152 158-159 
                              /                    
      9    115-116 122-123-124  89--88  86--85--84 
             |   |    \          |    \  |       | 
      8    114 117-118 121-120  90  92  87  82--83 
             |        \   /      |/   \      |     
      7    113-112 106 119 102  91  94--93  81  77 
              /   /  |    /  |    /       /   /  | 
      6    111 107 105 103 101  95--96  80  78  76 
             |    \   \  |   |        \   \  |   | 
      5    110-109-108 104 100--99--98--97  79  75 
                                                  \ 
      4     10--11  13--14--15  35--36  38--39--40  74  70  66--65--64 
             |    \  |       |   |    \  |       |   |   |\   \      | 
      3      9   7  12  17--16  34  32  37  42--41  73  71  69  67  63 
             |/   \      |       |/   \      |       |/      |/   /    
      2      8   5-- 6  18  22  33  30--31  43  47  72  55  68  62--61 
               /      /   /  |    /       /   /  |    /   \          | 
      1      4-- 3  19  21  23  29--28  44  46  48  54--53  56--57  60 
                  \   \  |   |        \   \  |   |        \      |   | 
    Y=0->    0-- 1-- 2  20  24--25--26--27  45  49--50--51--52  58--59 
          
            X=0  1   2   3   4   5   6   7   8   9  10  11  12  13  14

The base pattern is the N=0 to N=24 section.  It then repeats with rotations
or reversals that make the ends join.  For example N=75 to N=99 is the base
pattern in reverse.  Or N=50 to N=74 is reverse and also rotate by -90.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageDekkingCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoCurve>

=cut 

# when ready ...
# L<Math::PlanePath::DekkingCurve>


# Local variables:
# compile-command: "math-image --path=MathImageDekkingCurve --lines --scale=20"
# End:
#
# math-image --path=MathImageDekkingCurve --all --output=numbers_dash
