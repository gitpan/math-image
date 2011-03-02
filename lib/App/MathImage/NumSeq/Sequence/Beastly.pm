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

package App::MathImage::NumSeq::Sequence::Beastly;
use 5.004;
use strict;
use warnings;
use List::Util 'min','max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence';
use App::MathImage::NumSeq::Radix;

use vars '$VERSION';
$VERSION = 46;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Beastly');
use constant description => __('Numbers which contain "666".  The default is decimal, or select a radix.');
use constant values_min => 666;
use constant parameter_list => (App::MathImage::NumSeq::Radix::parameter_common_radix);


# cf A131645 the beastly primes
sub oeis {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return ($radix == 10
          ? 'A051003'
          : undef);
}
# OeisCatalogue: A051003 radix=10

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;

  my $radix = $options{'radix'} || $class->parameter_default('radix');

  my $target = (6*$radix+6)*$radix+6;
  my $self = bless { radix  => $radix,
                     cube   => $radix*$radix*$radix,
                     target => $target,
                     n      => max($lo,$target) - 1,
                   }, $class;
  return $self;
}
sub next {
  my ($self) = @_;
  if ($self->{'radix'} < 7) {
    return;
  }
  my $n = $self->{'n'};
  for (;;) {
    if ($self->pred(++$n)) {
      return ($self->{'n'} = $n);
    }
  }
}

sub pred {
  my ($self, $n) = @_;
  my $radix = $self->{'radix'};
  if ($radix < 7) {
    return 0;
  }
  if ($radix == 10) {
    return ($n =~ /666/);
  }

  my $cube = $self->{'cube'};
  my $target = $self->{'target'};
  for (;;) {
    if (($n % $cube) == $target) {
      return 1;
    }
    if ($n < $cube) {
      return 0;
    }
    $n = int($n/$radix);
  }
}

1;
__END__
