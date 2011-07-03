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

package App::MathImage::NumSeq::Sequence::SumTwoSquares;
use 5.004;
use strict;
use POSIX 'floor','ceil';
use List::Util 'max';
use List::MoreUtils;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 62;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Sum of Two Squares');
use constant description => __('Sum of two squares, ie. all numbers which occur as x^2+y^2 for x>=1 and y>=1.');

sub values_min {
  my ($self) = @_;
  if ($self->{'distinct'}) {
    return 5;
  } else {
    return 2;
  }
}

# cf A004431 sum two nonzero squares, distinct so x!=y
#    A024507 with repetitions
#    A001844 2n(n+1)+1 is those hypots with Y=H-1 in X^2+Y^2=H^2
#    A024509 x^2+y^2 with repetitions for different ways each can occur
#    A025284 x^2+y^2 occurring in exactly one way
#
use constant oeis_anum => 'A000404'; # sum two nonzero squares, possibly x==y

sub rewind {
  my ($self) = @_;
  ### SumTwoSquares rewind()
  $self->{'i'} = 0;
  if ($self->{'distinct'}) {
    #                                  y=1      y=2
    $self->{'y_next_x'}     = [ undef,  2,       3 ];
    $self->{'y_next_hypot'} = [ undef,  2*2+1*1, 2*2+3*3 ];
  } else {
    #                                  y=1       y=2
    $self->{'y_next_x'}     = [ undef,  1,        2 ];
    $self->{'y_next_hypot'} = [ undef,  1*1+1*1,  2*2+2*2 ];
  }
  $self->{'prev_hypot'} = 1;
  ### $self
}
sub next {
  my ($self) = @_;
  my $prev_hypot = $self->{'prev_hypot'};
  my $y_next_x = $self->{'y_next_x'};
  my $y_next_hypot = $self->{'y_next_hypot'};
  my $found_hypot = 4 * $prev_hypot + 4;
  ### $prev_hypot
  for (my $y = 1; $y < @$y_next_x; $y++) {
    my $h = $y_next_hypot->[$y];
    ### consider y: $y
    ### $h
    if ($h <= $prev_hypot) {
      if ($y == $#$y_next_x) {
        my $next_y = $y + 1;
        ### extend to: $next_y
        my $x = ($self->{'distinct'} ? $next_y+1 : $next_y);
        push @$y_next_x, $x;
        push @$y_next_hypot, $x*$x + $next_y*$next_y;
        ### $y_next_x
        ### $y_next_hypot
        ### assert: $y_next_hypot->[$next_y] == $next_y*$next_y + $y_next_x->[$next_y]*$y_next_x->[$next_y]
      }
      do {
        $h = $y_next_hypot->[$y] += 2*($y_next_x->[$y]++)+1;
        ### step y: $y
        ### next x: $y_next_x->[$y]
        ### next hypot: $y_next_hypot->[$y]
        ### assert: $y_next_hypot->[$y] == $y*$y + $y_next_x->[$y]*$y_next_x->[$y]
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
  return ($self->{'i'}++, $found_hypot);
}

# ENHANCE-ME: check the factorization, or a least a few smallish 4n+3 primes
sub pred {
  my ($self, $n) = @_;
  if ($n == $n-1) {
    return 0;
  }
  my $limit = int(sqrt($n/2));
  for (my $x = 1; $x <= $limit; $x++) {
    my $y = int(sqrt($n - $x*$x));
    if ($x*$x + $y*$y == $n) {
      unless ($self->{'distinct'} && $y == $x) {
        return 1;
      }
    }
  }
  return 0;
}

1;
__END__
