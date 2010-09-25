# unit_arc
# unit_chord




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


package App::MathImage::PlanePath::ArchimedeanSpiral;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use Math::Libm 'hypot';
use Math::Trig 'asin', 'asinh', 'pi';
use POSIX 'floor';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 22;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant figure => 'circle';

my @radius = (0, 1);

use constant _A => 1 / (2*pi());

sub _arc_length {
  my ($theta) = @_;
  my $hyp = hypot(1,$theta);
  return 0.5 * _A * ($theta*$hyp + asinh($theta));
}

# upper bound $hyp >= $theta
#     a/2 * $theta * $theta
# so theta = sqrt (2/_A * $length)
#
# lower bound $hyp <= $theta+1, log(x)<=x
#     length <= a/2 * ($theta * ($theta+1))^2
#     2/a * length <= (2*$theta * $theta)^2
# so theta >= sqrt (1/(2*_A) * $length)
#
sub _inverse {
  my ($length) = @_;
  my $lo_theta = sqrt (1/(2*_A) * $length);
  my $hi_theta = sqrt ((2/_A) * $length);
  my $lo_length = _arc_length($lo_theta);
  my $hi_length = _arc_length($hi_theta);
  #### $length
  #### $lo_theta
  #### $hi_theta
  #### $lo_length
  #### $hi_length
  die if $lo_length > $length;
  die if $hi_length < $length;
  my $m_theta;
  for (;;) {
    $m_theta = ($hi_theta + $lo_theta) / 2;
    last if ($hi_length - $lo_length) < 0.000001;
    my $m_length = _arc_length($m_theta);
    if ($m_length < $length) {
      $lo_theta = $m_theta;
      $lo_length = $m_length;
    } else {
      $hi_theta = $m_theta;
      $hi_length = $m_length;
    }
  }
  return $m_theta;
}

sub n_to_xy {
  my ($self, $n) = @_;
  return if $n < 0;

  my $theta = _inverse($n);
  my $r = _A * $theta;
  return ($r * cos($theta),
          $r * sin($theta));


#   $n = floor($n);
# 
#   for (my $i = scalar(@radius); $i <= $n; $i++) {
#     my $prev = $radius[$i-1];
#     # my $step = 8 * asin (.25/4 / $prev) / pi();
#     my $step = (.5 / pi()) / $prev;
#     $radius[$i] = $prev + $step;
#   }
# 
#   my $r = $radius[$n];
#   my $theta = 2 * pi() * ($r - int($r));  # radians 0 to 2*pi
#   return ($r * cos($theta),
#           $r * sin($theta));

}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ArchimedeanSpiral xy_to_n(): "$x, $y"
  return;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  my $r = 1 + int (hypot (max(abs($x1),abs($x2)), max(abs($y1),abs($y2))));

  # area pi*r^2, divided by each circle pi/4 == 4*$r*$r
  return (0,
          4*$r*$r);
}

1;
__END__

=for stopwords Archimedean Ryde Math-Image 27-gonal

=head1 NAME

App::MathImage::PlanePath::ArchimedeanSpiral -- radial spiral

=head1 SYNOPSIS

 use App::MathImage::PlanePath::ArchimedeanSpiral;
 my $path = App::MathImage::PlanePath::ArchimedeanSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points on a Archimedean spiral.  The spiral goes outwards by
a constant 1 unit each revolution and the points are placed on it spaced 1
apart.  The result is roughly

                                                        
              31  30                                    
           32        29                                 
        33                 50                           
              14 13     28                              
          15        12                                  
     34                   27 49                         
        16     3  2   11                                
    35      4                 48                        
                          26                            
       17           1  10                               
    36     5                  47                        
                          25                            
        18   6        9                                 
    37             8     24  46                         
         19     7                                       
      38              23   45                           
            20     22                                   
        39      21       44                             
           40                                           
               41 42  43                                
                                                                               

X,Y positions returned are fractional.  Each revolution is approximately
2*pi longer than the previous, so the effect is a kind of "6.28" step
spiralling.  The "27-gonal" numbers k*(25k - 23)/2 get close to that, almost
lining up, but still spiralling.

=head1 FUNCTIONS

=over 4

=item C<$path = App::MathImage::PlanePath::ArchimedeanSpiral-E<gt>new ()>

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

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::TheodorusSpiral>,
L<Math::PlanePath::SacksSpiral>

=cut
