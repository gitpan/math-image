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

package App::MathImage::NumSeq::HappySteps;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 65;

use App::MathImage::NumSeq '__';
use App::MathImage::NumSeq::Base::IterateIth;
@ISA = ('App::MathImage::NumSeq::Base::IterateIth',
        'App::MathImage::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('Happy Steps');
use constant description => __('Happy numbers steps to repeat iteration sum of squares of digits.');
use constant values_min => 0;
use constant i_start => 0;
use constant characteristic_count => 1;
# 1,9,13,8,12,17,6,13,12,2,10 not in OEIS apparently ...

use App::MathImage::NumSeq::Base::Digits;
use constant parameter_list =>
  (App::MathImage::NumSeq::Base::Digits::parameter_common_radix);

# cf A035497 primes which are happy
#    A001273 smallest happy which takes N steps
#
# sub oeis_anum {
#   my ($class_or_self) = @_;
#   my $radix = (ref $class_or_self
#                ? $class_or_self->{'radix'}
#                : $class_or_self->parameter_default('radix'));
#   return ($radix == 10
#           ? 'A???????'
#           : undef);
# }

sub ith {
  my ($self, $i) = @_;

  if ($i <= 0) {
    return 0;
  }
  my $radix = $self->{'radix'};
  my $steps = 0;
  my %seen;
  for (;;) {
    ### $i
    my $sum = 0;
    if ($seen{$i}) {
      return $steps;
    }
    $seen{$i} = 1;
    while ($i) {
      my $digit = ($i % $radix);
      $sum += $digit * $digit;
      $i = int($i/$radix);
    }
    $i = $sum;
    $steps++;
  }
}

sub pred {
  my ($self, $value) = @_;
  ### Happy pred(): $value
  return ($value >= 0);
}

1;
__END__
