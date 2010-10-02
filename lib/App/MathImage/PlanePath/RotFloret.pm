# Copyright 2010 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.


package App::MathImage::PlanePath::RotFloret;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use Math::Libm 'hypot';
use Math::Trig 'pi';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 18;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments '###';


use constant figure => 'circle';

use constant PHI => (1 + sqrt(5)) / 2;

# use constant FACTOR => do {
#   my @c = map {
#     my $n = $_;
#     my $r = sqrt($n);
#     my $theta = 2 * $n;
#     ### $r
#     ### $theta
#     Math::Trig::cylindrical_to_cartesian($r, $theta, 0);
#   } 1, 4;
#   ### @c
#   # 1 / hypot ($c[0]-$c[3], $c[1]-$c[4]);
# 
#   
# };

sub new {
  my $class = shift;
  ### RotFloret new(): @_

  my $self = $class->SUPER::new (@_);
  if (! defined $self->{'rotation'}) {
    $self->{'rotation'} = 'phi';
  }
  if ($self->{'rotation'} eq 'pi') {
    $self->{'rot'} = pi() - 3;
    $self->{'factor'} = 1.60242740883046;

  } elsif ($self->{'rotation'} eq 'sqrt2') {
    $self->{'rot'} = sqrt(2) - 1;
    $self->{'factor'} = 0.679984167849259;

  } elsif ($self->{'rotation'} =~ /^sqrt *([[:digit:].]+)$/) {
    $self->{'rot'} = sqrt($1) - int(sqrt($1));
    $self->{'factor'} = 1;

  } else {
    $self->{'rot'} = 1 / (PHI * PHI);
    $self->{'factor'} = 0.624239116809924;
  }

  ### $self
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  return if $n < 0;
  my $r = sqrt($n) * $self->{'factor'};
  my $theta = $n * $self->{'rot'};  # 1==full circle
  $theta = 2 * pi() * ($theta - int($theta));  # radians 0 to 2*pi
  return ($r * cos($theta),
          $r * sin($theta));
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  my $r = hypot ($x, $y) * $self->{'factor'};

  # Slack approach just trying all the N values between r-.5 and r+.5.
  #
  # r = sqrt(n)*FACTOR
  # n = (r*(1/FACTOR))^2
  #
  {
    my $lo = POSIX::floor((max(0,$r-1))**2);
    my $hi = POSIX::ceil(($r+1)**2);
    #### xy: "$x,$y"
    #### $r
    #### $lo
    #### $hi
  }

  foreach my $n (reverse POSIX::floor((max(0,$r-.6))**2)
                 .. POSIX::ceil(($r+.6)**2)) {
    my ($nx, $ny) = $self->n_to_xy($n);
    ### hypot: "$n ".hypot($nx-$x,$ny-$y)
    if (hypot($nx-$x,$ny-$y) <= 0.5) {
      #### found: $n
      return $n;
    }
  }
  return undef;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  my $r = max (hypot ($x1, $y1),
               hypot ($x1, $y2),
               hypot ($x2, $y1),
               hypot ($x2, $y2))
    + 1;
  # ENHANCE-ME: find actual minimum r if rect doesn't cover 0,0
  return (1,
          1 + POSIX::ceil (($r / $self->{'factor'}) ** 2));
}

1;
__END__
