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

package App::MathImage::NumSeq::NumAronson;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 74;
use Math::NumSeq;
@ISA = ('Math::NumSeq');


# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('Numerical Aronson');
use constant description => Math::NumSeq::__('Sloane\'s numerical version of Aronson\'s sequence');
use constant values_min => 0;
use constant characteristic_monotonic => 1;
use constant i_start => 1;

# cf A080596 - a(1)=1
#    A079253 - even
#    A081023 - lying
#    A014132 - lying opposite parity
use constant oeis_anum => 'A079000';

# a(9*2^k-3 + j) = 12*2^k - 3 + (3/2)*j + (1/2)*abs(j)
# step
# a(n+1) - 2*a(n) + a(n-1) = 1   if n=9*2^k-3, k>=0
#                          = -1  if n = 2 and 3*2^k-3, k>=1           
#                          = 0   otherwise.                                                                       


#
# lying
# g(3*2^k-1 + j) = 2*2^(k+1)-1 + (3/2)*j + (1/2)*abs(j)
# where -2^k <= j < 2^k  and k>0
#
# then lying is d(n)=g(n+1)-1  n>=1

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
  $self->{'p2k'} = 0;
  $self->{'j'} = -1;
}

sub next {
  my ($self) = @_;
  my $p2k = $self->{'p2k'};
  my $j = ++ $self->{'j'};

  if ($p2k == 0) {
    # low special cases initial 1,4,
    if ($j < 2) {
      return ($self->{'i'}++, $j*3 + 1);
    }
    $p2k = $self->{'p2k'} = 1;    # 2**k for k=0
    $j   = $self->{'j'}   = -3;   # -3*(2**k) for k=0
  } elsif ($j >= 3 * $p2k) {
    $self->{'p2k'} = ($p2k <<= 1);
    $j = $self->{'j'} = -3 * $p2k;
  }
  return ($self->{'i'}++, 12*$p2k - 3 + (3*$j + abs($j))/2);
}

1;
__END__
