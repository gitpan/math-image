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

package App::MathImage::Values::Sequence::HarshadNumbers;
use 5.004;
use strict;

use App::MathImage::Values::Base '__';
use base 'App::MathImage::Values::Sequence';
use App::MathImage::Values::Base::Digits;

use vars '$VERSION';
$VERSION = 63;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('Harshad Numbers');
use constant description => __('Harshad numbers, divisible by the sum of their digits.');
use constant values_min => 1;
use constant i_start => 1;
use constant parameter_list => (App::MathImage::Values::Base::Digits::parameter_common_radix);

my %oeis = (2  => 'A049445',  # binary 1s divide N
            10 => 'A005349',  # decimal sum digits divide N
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis{$radix};
}
# OeisCatalogue: A049445 radix=2
# OeisCatalogue: A005349 radix=10

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 1;
  $self->{'value'} = 0;
}
sub next {
  my ($self) = @_;
  my $value = $self->{'value'};
  for (;;) {
    if ($self->pred(++$value)) {
      return ($self->{'i'}++, ($self->{'value'} = $value));
    }
  }
}
sub pred {
  my ($self, $value) = @_;
  ### HarshadNumbers pred(): $value
  if ($value <= 0) {
    return 0;
  }
  my $radix = $self->{'radix'};
  my $sum = 0;
  my $v = $value;
  while ($v) {
    $sum += ($v % $radix);
    $v = int($v/$radix);
  }
  return ! ($value % $sum);
}
# sub ith {
#   my ($self, $i) = @_;
#   return ...
# }

1;
__END__
