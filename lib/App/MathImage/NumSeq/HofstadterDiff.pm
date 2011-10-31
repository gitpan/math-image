# triangular with some skipping ...



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

package App::MathImage::NumSeq::HofstadterDiff;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 79;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;

use constant description => Math::NumSeq::__('Hofstadter diff sequence.');
use constant characteristic_monotonic => 1;
use constant values_min => 1;
use constant i_start => 1;

# cf A030124 - the differences, being the complement seq
#    A061577 - starting from 2
#    A061578 - starting from 2 differences
# A140778 
# A037257, A037258, A037259 - first and second diffs disjoint
#
use constant oeis_anum => 'A005228';

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 1;
  $self->{'prev'} = 0;
  $self->{'diff_upto'} = 0;
  $self->{'diff_exclude'} = {};
}

sub next {
  my ($self) = @_;
  ### HofstadterDiff next(): "$self->{'i'}"
  ### diff_exclude size: scalar(my @x = values %{$self->{'diff_exclude'}})

  my $diff = $self->{'diff_upto'};
  my $diff_exclude = $self->{'diff_exclude'};
  while (delete $diff_exclude->{++$diff}) {
    ### exclude: $diff
  }
  my $ret = $self->{'prev'} + $diff;
  $self->{'diff_upto'} = $diff;
  $self->{'prev'} = $ret;
  $diff_exclude->{$ret} = 1;
  return ($self->{'i'}++, $ret);
}

1;
__END__
