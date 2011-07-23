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

package App::MathImage::NumSeq::Beastly;
use 5.004;
use strict;
use List::Util 'min','max';

use vars '$VERSION', '@ISA';
$VERSION = 65;

use App::MathImage::NumSeq '__';
@ISA = ('App::MathImage::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Beastly');
use constant description => __('Numbers which contain "666".  The default is decimal, or select a radix.');
use constant values_min => 666;

use App::MathImage::NumSeq::Base::Digits;
use constant parameter_list => (App::MathImage::NumSeq::Base::Digits::parameter_common_radix);


# cf A131645 the beastly primes
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return ($radix == 10
          ? 'A051003'
          : undef);
}
# OEIS-Catalogue: A051003 radix=10

sub rewind {
  my ($self) = @_;
  my $lo = $self->{'lo'};

  my $radix = $self->{'radix'};

  $self->{'i'}      = 0;
  $self->{'target'} = (6*$radix+6)*$radix+6;
  $self->{'cube'}   = $radix*$radix*$radix;
  $self->{'value'}  = max($lo,$self->{'target'}) - 1;
}
sub next {
  my ($self) = @_;
  if ($self->{'radix'} < 7) {
    return;
  }
  my $value = $self->{'value'};
  for (;;) {
    if ($self->pred(++$value)) {
      return ($self->{'i'}++, ($self->{'value'} = $value));
    }
  }
}

sub pred {
  my ($self, $value) = @_;
  my $radix = $self->{'radix'};
  if ($radix < 7) {
    return 0;
  }
  if ($radix == 10) {
    return ($value =~ /666/);
  }

  my $cube = $self->{'cube'};
  my $target = $self->{'target'};
  for (;;) {
    if (($value % $cube) == $target) {
      return 1;
    }
    if ($value < $cube) {
      return 0;
    }
    $value = int($value/$radix);
  }
}

1;
__END__
