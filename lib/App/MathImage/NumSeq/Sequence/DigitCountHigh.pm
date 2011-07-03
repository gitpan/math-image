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

package App::MathImage::NumSeq::Sequence::DigitCountHigh;
use 5.004;
use strict;
use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 62;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Digit Count High');
use constant description => __('How many of a given digit at the high end of a number, in a given radix.');
use constant values_min => 1;
use constant characteristic_count => 1;

use App::MathImage::NumSeq::Sequence::DigitCount;
*parameter_list = \&App::MathImage::NumSeq::Sequence::DigitCount::parameter_list;

# cf
# 
my @oeis;

sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  my $digit = (ref $class_or_self
               ? $class_or_self->{'digit'}
               : $class_or_self->parameter_default('digit'));
  return $oeis[$radix]->[$digit];
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
}
sub next {
  my ($self) = @_;
  ### DigitCount next()
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}

sub ith {
  my ($self, $i) = @_;
  $i = abs($i);
  if ($i == $i-1) {
    return $i;  # don't loop forever if $i is +infinity
  }
  my $digit = $self->{'digit'};
  my $radix = $self->{'radix'};
  my $count = 0;
  if ($radix == 2) {
    while ($i) {
      if (($i & 1) == $digit) {
        $count++;
      } else {
        $count = 0;
      }
      $i >>= 1;
    }
  } else {
    while ($i) {
      if (($i % $radix) == $digit) {
        $count++;
      } else {
        $count = 0;
      }
      $i = int($i/$radix);
    }
  }
  return $count;
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 0);
}

1;
__END__
