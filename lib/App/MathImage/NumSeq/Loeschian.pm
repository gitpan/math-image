# OEIS starts with i=1 for value=0 ...




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

package App::MathImage::NumSeq::Loeschian;
use 5.004;
use strict;
use POSIX 'floor','ceil';
use List::Util 'max';
use List::MoreUtils;

use vars '$VERSION', '@ISA';
$VERSION = 74;
use Math::NumSeq;
@ISA = ('Math::NumSeq');


# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('Loeschian numbers');
use constant description => Math::NumSeq::__('Loeschian numbers x^2+xy+y^2 norms on hexagonal A2 grid, which is also (a^2+3*b^2)/4 for all a>=0,b>=0 and a,b opposite odd/even.');
use constant i_start => 1; # per oeis ...
use constant characteristic_monotonic => 1;

# cf A132111 - triangle T(n,k) = n^2 + k*n + k^2, 0<=k<=n
#              same values different order?
#
use constant oeis_anum => 'A003136';

# X^2+3Y^2 (X=y+x/2, Y=x/2)

sub rewind {
  my ($self) = @_;
  ### Loeschian rewind()
  $self->{'i'} = max (1, $self->{'lo'} || 0);
  $self->{'y_next_x'}     = [ 0, 1         ];
  $self->{'y_next_hypot'} = [ 0, 1*1+3*1*1 ];
  $self->{'prev_hypot'} = -1;
  ### assert: $self->{'y_next_hypot'}->[1] == 3*1**2 + $self->{'y_next_x'}->[1]**2
  ### $self
}
sub next {
  my ($self) = @_;
  my $prev_hypot = $self->{'prev_hypot'};
  my $y_next_x = $self->{'y_next_x'};
  my $y_next_hypot = $self->{'y_next_hypot'};
  my $found_hypot = 12 * $prev_hypot + 24;
  ### $prev_hypot
  for (my $y = 0; $y < @$y_next_x; $y++) {
    my $h = $y_next_hypot->[$y];
    ### consider y: $y
    ### $h
    if ($h <= $prev_hypot) {
      if ($y == $#$y_next_x) {
        my $next_y = $y + 1;
        ### extend to: $next_y
        my $x = 2 - ($next_y & 1);  # x=1 or 2
        push @$y_next_x, $x;
        push @$y_next_hypot, $x*$x + 3*$next_y*$next_y;
        ### $y_next_x
        ### $y_next_hypot
        ### assert: (($next_y^$y_next_x->[$next_y])&1) == 0
        ### assert: $y_next_hypot->[$next_y] == 3*$next_y**2 + $y_next_x->[$next_y]**2
      }
      do {
        $h = ($y_next_hypot->[$y] += 4*($y_next_x->[$y] += 2) - 4);
        ### step y: $y
        ### next x: $y_next_x->[$y]
        ### next hypot: $y_next_hypot->[$y]
        ### assert: (($y^$y_next_x->[$y])&1) == 0
        ### assert: $y_next_hypot->[$y] == 3*$y**2 + $y_next_x->[$y]**2
      } while ($h <= $prev_hypot);
    }
    ### $h
    if ($h < $found_hypot) {
      ### lower hypot: $y
      $found_hypot = $h;
    }
  }
  $self->{'prev_hypot'} = $found_hypot;
  ### return: $self->{'i'}, $found_hypot
  ### assert: ($found_hypot % 4) == 0
  return ($self->{'i'}++, $found_hypot/4);
}

# ENHANCE-ME: check the factorization
# primes 3k+2 must have even exponent, other primes can be anything
# divide out primes for progressively smaller sqrt limit of remaining
sub pred {
  my ($self, $value) = @_;
  if ($value == $value-1) {
    return 0;
  }
  $value *= 4;
  my $limit = int(sqrt($value/3));
  ### $limit
  for (my $y = 0; $y <= $limit; $y++) {
    my $ysq = 3*$y*$y;
    my $x = int(sqrt($value - $ysq));
    if ((($x ^ $y) & 1) == 0
        && $x*$x + $ysq == $value) {
      return 1;
    }
  }
  return 0;
}

1;
__END__
