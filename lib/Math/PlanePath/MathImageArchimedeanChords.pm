# xy_to_n very slow at around n=600,000



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


package Math::PlanePath::MathImageArchimedeanChords;
use 5.004;
use strict;
use List::Util 'min', 'max';
use Math::Libm 'hypot', 'M_PI';
use POSIX 'floor';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 49;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant figure => 'circle';

my @radius = (0, 1);

# Starting at polar angle position t,
#     r = t / 2pi
#     x = r * cos(t) = t * cos(t) / 2pi
#     y = r * sin(t) = t * sin(t) / 2pi
#
# Add an amount u to seek a chord distance of 1.  Hypot square distance from
# t to t+u,
#
#     dist(u) =   ((t+u)/2pi*cos(t+u) - t/2pi*cos(t))^2     # X
#               + ((t+u)/2pi*sin(t+u) - t/2pi*sin(t))^2     # Y
#             = [  (t+u)^2*cos^2(t+u) - 2*(t+u)*t*cos(t+u)*cos(t) + t^2*cos^2(t)
#                + (t+u)^2*sin^2(t+u) - 2*(t+u)*t*sin(t+u)*sin(t) + t^2*sin^2(t) ]/4pi^2
#             = [  (t+u)^2            - 2*(t+u)*t*cos((t+u)-t)    + t^2 ] /4pi^2
#             = [ (t+u)^2 + t^2 - 2*t*(t+u)*cos(u) ] / (4*pi^2)
#
# and switch to cos(u) = 1 - 2*sin^2(u/2) since if u is small then cos(u)
# near 1.0 might lose accuracy
#
#     dist(u) = [(t+u)^2 + t^2 - 2*t*(t+u)*(1 - 2*sin^2(u/2))] / (4*pi^2)
#             = [(t+u)^2 + t^2 - 2*t*(t+u) + 2*t*(t+u)*2*sin^2(u/2)] / (4*pi^2)
#             = [((t+u) - t)^2 + 4*t*(t+u)*sin^2(u/2)] / (4*pi^2)
#             = [ u^2 + 4*t*(t+u)*sin^2(u/2) ] / (4*pi^2)
#
# Seek d(u) = 1 by f(u)=0
#
#     f(u) = u^2 + 4*t*(t+u)*sin^2(u/2) - 4*pi^2
#
# Derivative f'(u) for the slope, starting from the cos() form,
#
#     f(u)  = (t+u)^2 + t^2 - 2*t*(t+u)*cos(u) - 4*pi^2
#
#     f'(u) = 2*(t+u) - 2*t*[ cos(u) - (t+u)*sin(u) ]
#           = 2*(t+u) - 2*t*[ 1 - 2*sin^2(u/2) - (t+u)*sin(u) ]
#           = 2*t + 2*u - 2*t + 2*t*2*sin^2(u/2) + 2*t*(t+u)*sin(u)
#           = 2*[ u + 2*t*sin^2(u/2) + t*(t+u)*sin(u) ]
#           = 2*[ u + t * [2*sin^2(u/2) + (t+u)*sin(u) ] ]
#
sub _chord_angle_inc {
  my ($t) = @_;

  my $tsq = $t*$t;
  my $u = 2*M_PI()/$t; # estimate

  foreach (0 .. 10) {
    my $shu = sin($u/2); $shu *= $shu;
    my $tu = ($t+$u);
    my $f = $u*$u + 4*$t*$tu*$shu - 4*M_PI()*M_PI();
    my $slope = 2 * ( $u + $t*(2*$shu + $tu*sin($u)));

    # unsimplified ...
    # $f = ($t+$u)**2 + $t**2 - 2*$t*($t+$u)*cos($u) - 4*M_PI()*M_PI();
    # $slope = 2*($t+$u) - 2*$t*( cos($u) - ($t+$u)*sin($u) );

    my $sub = $f/$slope;
    $u -= $sub;

    # printf ("f=%.6f slope=%.6f sub=%.20f u=%.6f\n", $f, $slope, $sub, $u);
    last if (abs($sub) < 1e-15);
  }
  # printf ("return u=%.6f\n", $u);
  return $u;
}

use constant _SAVE => 500;

my @save_n = (1);
my @save_t = (2*M_PI());
my $next_save = $save_n[0] + _SAVE;

sub new {
  my $class = shift;
  ### ArchimedeanChords new()
  return $class->SUPER::new (i => $save_n[0],
                             t => $save_t[0],
                             @_);
}

sub n_to_xy {
  my ($self, $n) = @_;

  if ($n < 0
      || $n-1 == $n) {  # infinity
    return;
  }

  if ($n < 1) {
    return ($n, 0);
  }

  if ($n != int($n)) {
    my $frac = $n;
    $n = int($n);
    $frac -= $n;
    my ($x1, $y1) = $self->n_to_xy($n);
    my ($x2, $y2) = $self->n_to_xy($n+1);
    return ($x2*$frac + $x1*(1-$frac),
            $y2*$frac + $y1*(1-$frac));
  }

  my $i = $self->{'i'};
  my $t = $self->{'t'};

  if ($i > $n) {
    my $pos = min ($#save_n, int (($n - $save_n[0]) / _SAVE));
    $i = $save_n[$pos];
    $t = $save_t[$pos];
    ### resume: "$i  t=$t"
  }

  while ($i < $n) {
    $t += _chord_angle_inc($t);
    if (++$i == $next_save) {
      push @save_n, $i;
      push @save_t, $t;
      $next_save += _SAVE;
    }
  }

  $self->{'i'} = $i;
  $self->{'t'} = $t;

  my $r = $t * (1 / (2*M_PI()));
  return ($r*cos($t),
          $r*sin($t));
}

# each loop begins at N = pi*k^2 - 2
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ArchimedeanChords xy_to_n(): "$x, $y"

  my $r = hypot ($x,$y);
  my $t = (atan2 ($y,$x) + M_PI()) / (2*M_PI);       # 0 <= $t <= 1
  if ($t >= 1) { $t -= 1; }  # 0 <= $t < 1
  $r = int ($r + 0.5 - $t) + $t;

  my $r2 = $r * $r;
  my $n_lo =  int (max (0, 1 + int(M_PI()*$r2) - 4*$r));
  my $n_hi = $n_lo + 3*$r;
  ### hypot: hypot($x,$y)
  ### $t
  ### $r
  ### $r2
  ### $n_lo
  ### $n_hi
  ### range: $n_hi-$n_lo

  if ($n_lo == $n_lo-1 || $n_hi == $n_hi-1) {
    ### infinite range, r inf or too big
    return undef;
  }

  # for(;;) loop since $n_lo..$n_hi limited to IV range
  for (my $n = $n_lo; $n <= $n_hi; $n++) {
    my ($nx,$ny) = $self->n_to_xy($n);
    # #### $n
    # #### $nx
    # #### $ny
    # #### hypot: hypot ($x-$nx,$y-$ny)
    if (hypot ($x-$nx,$y-$ny) <= 0.5) {
      return $n;
    }
  }
  return undef;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  my $r = 1 + int (hypot (max(abs($x1),abs($x2)), max(abs($y1),abs($y2))));

  # each loop begins at N = pi*k^2 - 2 or thereabouts
  return (0,
          int(M_PI()*$r*$r) + 1);
}

1;
__END__

    # my $slope = 2*($t + (-$c1-$s1*$t)*cos($t) + ($c1*$t-$s1)*sin($t));
    # my $dist = ( ($t*cos($t) - $c1) ** 2
    #           + ($t*sin($t) - $s1) ** 2
    #           - 4*M_PI()*M_PI() );
    # my $slope = (2*($t*cos($t)-$c1)*(cos($t) - $t*sin($t))
    #          + 2*($t*sin($t)-$s1)*(sin($t) + $t*cos($t)));
    # my $c1 = $t1 * cos($t1);
    # my $s1 = $t1 * sin($t1);
    # my $c1_2 = $c1*2;
    # my $s1_2 = $s1*2;
    # my $t = $t1 + 2*M_PI()/$t1; # estimate
    # my $ct = cos($t);
    # my $st = sin($t);
    # my $dist = (($t - $ct*$c1_2 - $st*$s1_2) * $t + $t1sqm);
    # my $slope = 2 * (($t*$ct - $c1) * ($ct - $t*$st)
    #                  + ($t*$st - $s1) * ($st + $t*$ct));
    #
    # my $sub = $dist/$slope;
    # $t -= $sub;

# use constant _A => 1 / (2*M_PI());



  # # my $theta = _inverse($n);
  # # my $r = _A * $theta;
  # # return ($r * cos($theta),
  # #         $r * sin($theta));
  # 
  # 
  # #   $n = floor($n);
  # #
  # #   for (my $i = scalar(@radius); $i <= $n; $i++) {
  # #     my $prev = $radius[$i-1];
  # #     # my $step = 8 * asin (.25/4 / $prev) / pi();
  # #     my $step = (.5 / pi()) / $prev;
  # #     $radius[$i] = $prev + $step;
  # #   }
  # #
  # #   my $r = $radius[$n];
  # #   my $theta = 2 * pi() * ($r - int($r));  # radians 0 to 2*pi
  # #   return ($r * cos($theta),
  # #           $r * sin($theta));
# sub _arc_length {
#   my ($theta) = @_;
#   my $hyp = hypot(1,$theta);
#   return 0.5 * _A * ($theta*$hyp + asinh($theta));
# }
# 
# # upper bound $hyp >= $theta
# #     a/2 * $theta * $theta
# # so theta = sqrt (2/_A * $length)
# #
# # lower bound $hyp <= $theta+1, log(x)<=x
# #     length <= a/2 * ($theta * ($theta+1))^2
# #     2/a * length <= (2*$theta * $theta)^2
# # so theta >= sqrt (1/(2*_A) * $length)
# #
# sub _inverse {
#   my ($length) = @_;
#   my $lo_theta = sqrt (1/(2*_A) * $length);
#   my $hi_theta = sqrt ((2/_A) * $length);
#   my $lo_length = _arc_length($lo_theta);
#   my $hi_length = _arc_length($hi_theta);
#   #### $length
#   #### $lo_theta
#   #### $hi_theta
#   #### $lo_length
#   #### $hi_length
#   die if $lo_length > $length;
#   die if $hi_length < $length;
#   my $m_theta;
#   for (;;) {
#     $m_theta = ($hi_theta + $lo_theta) / 2;
#     last if ($hi_length - $lo_length) < 0.000001;
#     my $m_length = _arc_length($m_theta);
#     if ($m_length < $length) {
#       $lo_theta = $m_theta;
#       $lo_length = $m_length;
#     } else {
#       $hi_theta = $m_theta;
#       $hi_length = $m_length;
#     }
#   }
#   return $m_theta;
# }


=for stopwords Archimedean Ryde Math-Image 27-gonal

=head1 NAME

Math::PlanePath::MathImageArchimedeanChords -- radial spiral chords

=head1 SYNOPSIS

 use Math::PlanePath::MathImageArchimedeanChords;
 my $path = Math::PlanePath::MathImageArchimedeanChords->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progresss ... xy_to_n() is a bit slow.>

This path puts points at unit chord steps on an Archimedean spiral.  The
spiral goes outwards by a constant 1 unit each revolution and the points are
placed on it spaced 1 apart.  The result is roughly

                                                        
                      32       31    30                              
                33                         29                        
                            14                                       
          34          15          13             28       50         
                                           12                        
       35       16           3                      27       49      
                       4              2       11                     
             17                                                      
    36              5           0        1             26    48      
                                              10                     
    37       18                                     25       47      
                       6                    9                        
                19           7        8          24       46         
       38                                                            
                      20                   23       45               
             39             21    22                                 
                   40                         44                     
                         41       42    43                           

X,Y positions returned are fractional.  Each revolution is about 2*pi longer
than the previous, so the effect is a kind of "6.28" step spiralling.

Because the spacing is by unit chords, unit circles centred on each N
position touch but don't overlap.  The spiral spacing of 1 unit per
revolution means they don't overlap radially either.

The unit chords are somewhat similar to the TheordorusSpiral.  It takes unit
steps at right-angles to the radius and the result approaches an Archimedean
spiral of 3.14 radial spacing.  This ArchimedeanChords on the other hand is
a 1 radial spacing, and directly followed.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageArchimedeanChords-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

C<$n> can be any value C<$n E<gt>= 0> and fractions give positions on the
spiral in between the integer points.

For C<$n < 0> the return is an empty list, it being considered there are no
negative points in the spiral.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N
is considered the centre of a circle of diameter 1 and an C<$x,$y> within
that circle returns N.

The unit spacing of the spiral means those circles don't overlap, but they
also don't cover the plane and if C<$x,$y> is not within one then the
return is C<undef>.

=back

=head1 FORMULAS

The current code keeps a position as a polar angle t and calculates an
increment u needed to move by a unit chord.  The cartesian distance between
t and t+u, or rather the square of the distance, is

    dist^2(u) =   ((t+u)/2pi*cos(t+u) - t/2pi*cos(t))^2     # X
                + ((t+u)/2pi*sin(t+u) - t/2pi*sin(t))^2     # Y

which simplifies to

    dist^2(u) = [ (t+u)^2 + t^2 - 2*t*(t+u)*cos(u) ] / (4*pi^2)

And then a half angle cos(u) = 1 - 2*sin^2(u/2) to switch to sin(u) just in
case when u is small cos(u) near 1.0 might lose floating point accuracy, and
also being a slight further simplification,

    dist^2(u) = [ u^2 + 4*t*(t+u)*sin^2(u/2) ] / (4*pi^2)

Then the aim is dist(u) = 1 for a unit chord.  The u*sin(u) probably doesn't
have a good closed form inverse, so the current code is a little
Newton/Raphson iteration seeking f(u)=0

    f(u) = u^2 + 4*t*(t+u)*sin^2(u/2) - 4*pi^2

and derivative f'(u) for the slope (from the cos() form), and again
preferring sin over cos for small u,

    f'(u) = 2*(t+u) - 2*t*[ cos(u) - (t+u)*sin(u) ]
          = 2*[ u + t * [2*sin^2(u/2) + (t+u)*sin(u) ] ]

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::TheodorusSpiral>,
L<Math::PlanePath::SacksSpiral>

=cut
