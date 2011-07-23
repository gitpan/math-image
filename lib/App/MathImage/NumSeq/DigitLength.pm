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

package App::MathImage::NumSeq::DigitLength;
use 5.004;
use strict;

use App::MathImage::NumSeq '__';
use base 'App::MathImage::NumSeq::Base::Digits';

use vars '$VERSION';
$VERSION = 65;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Digit Length');
use constant description => __('How many digits the number requires in the given radix.  For example binary 1,1,2,2,3,3,3,3,4, etc.');
use constant values_min => 1;
use constant characteristic_count => 1;

my @oeis = (undef,
            undef,
            'A070939',  # 2 binary
            'A081604',  # 3 ternary
            'A110591',  # 4
            'A110592',  # 5
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis[$radix];
}
# OEIS-Catalogue: A070939 radix=2
#
# cf A000523 - floor(log2(n))
#    A036786 - roman numeral length <  decimal length
#    A036787 - roman numeral length == decimal length
#    A036788 - roman numeral length <= decimal length

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
  $self->{'length'} = 1;
  $self->{'limit'} = $self->{'radix'};
}
sub next {
  my ($self) = @_;
  ### DigitLength next(): $self
  ### count: $self->{'count'}
  ### bits: $self->{'bits'}

  my $i = $self->{'i'}++;
  if ($i >= $self->{'limit'}) {
    $self->{'limit'} *= $self->{'radix'};
    $self->{'length'}++;
    ### step to
    ### length: $self->{'length'}
    ### remaining: $self->{'limit'}
  }
  return ($i, $self->{'length'});
}

sub ith {
  my ($self, $i) = @_;
  if ($i == $i-1) {
    return $i;  # don't loop forever if $i is +infinity
  }
  my $length = 1;
  my $power = my $radix = $self->{'radix'};
  while ($i >= $power) {
    $length++;
    $power *= $radix;
  }
  return $length;
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 1);
}

1;
__END__

