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

# math-image --values=Kolakoski
#
# http://dimacs.rutgers.edu/TechnicalReports/abstracts/1993/93-84.html


package App::MathImage::NumSeq::Kolakoski;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 77;

use Math::NumSeq;
@ISA = ('Math::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;

use constant description => Math::NumSeq::__('Kolakoski sequence 1,2,1,1,2,etc.');
use constant characteristic_monotonic => 1;
use constant values_min => 1;
use constant values_max => 2;
use constant i_start => 1;

# cf A000002 - starting 1,2,2,1,1,
#    A006928 - starting 1,2,1,1,...
#    A064353 - 1,3 sequence
#    A054353 - partial sums
#    A078880 - starting from 2
#    A054353 - partial sums, step 1 or 2, is kol(n)!=kol(n+1) the 2 gaps ...
#    A074286 - partial sums minus n (variously repeating values)
#    A054349 - successive generations as big decimals
#    A042942 - something substitutional
#    A013949 substitute
#    A156077 digits ...
#    A078929 A(n+k) = A(n)
#
# A156253 kol supp
# A064353 kol 1/3
# A001083 A00002 lengths after iterating 1,2,3,5,7,10,15
# A006928 lengths ...
# A042942 1,2,1,1 lengths after iterating 1,2,4,6,9,14,22
# A079729 1,2,3 starting 1,2,2
# A079730 1,2,3,4 starting 1,2,2
#
#    A025142,A025143 - invert 1,2 so opposite run length
#
#    A074293 most populous digit,
#    A074295 most populous digit in groups of 7
#
#    A171899 van eck transform of 
# A001462 golomb
# A001463 golomb partial sums
#
use constant oeis_anum => 'A006928';

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 1;
  $self->{'digit'} = 1;
  $self->{'pending'} = [1];
}

sub next {
  my ($self) = @_;
  ### Kolakoski next(): "$self->{'i'}"

  my $pending = $self->{'pending'};
  # unless (@$pending) {
  #   push @$pending, ($self->{'digit'}) x $self->{'digit'};
  #   # ($self->{'digit'} ^= 3);
  # }
  my $ret = shift @$pending;
  ### $ret
  ### append: ($self->{'digit'} ^ 3)

  push @$pending, (($self->{'digit'} ^= 3) x $ret);

  # A025142
  # push @$pending, (($self->{'digit'}) x $ret);
  # $self->{'digit'} ^= 3;

  ### now pending: @$pending
  return ($self->{'i'}++, $ret);
}

1;
__END__
