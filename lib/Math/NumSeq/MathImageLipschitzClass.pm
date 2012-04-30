# Copyright 2012 Kevin Ryde

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

package Math::NumSeq::MathImageLipschitzClass;
use 5.004;
use strict;
use Math::Prime::XS 0.23 'is_prime'; # version 0.23 fix for 1928099
use Math::Factor::XS 0.39 'prime_factors'; # version 0.39 for prime_factors()

use vars '$VERSION', '@ISA';
$VERSION = 97;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;


# use constant name => Math::NumSeq::__('...');
use constant description => Math::NumSeq::__('Lipschitz class of an integer.');
use constant default_i_start => 1;
use constant characteristic_integer => 1;
use constant characteristic_increasing => 0;
use constant characteristic_non_decreasing => 0;
use constant characteristic_smaller => 1;
use constant values_min => 0;

use constant parameter_info_array =>
  [
   { name    => 'lipschitz_type',
     type    => 'enum',
     default => 'I',
     choices => ['I','P'],
     choices_display => [Math::NumSeq::__('I'),
                         Math::NumSeq::__('P')],
     # description => Math::NumSeq::__('...'),
   },
  ];

# use constant oeis_anum => '';

sub ith {
  my ($self, $i) = @_;

  if (_is_infinite($i) || $i > 0xFFFF_FFFF) {
    return undef;
  }
  if ($i < 3) {
    return ($i == 2 ? 1 : 0);
  }

  my @this;
  my $ret;
  if ($self->{'lipschitz_type'} eq 'P') {
    unless (is_prime($i)) {
      return 0;
    }
    if ($i == 3) {
      return 2;
    }
    @this = ($i-1);
    $ret = 1;
  } else {
    @this = ($i);
    $ret = 0;
  }

  # integers in @this
  while (@this) {
    my %next;
    foreach my $v (@this) {
      @next{prime_factors($v)} = ();  # hash slice, distinct primes
    }
    $ret++;

    last unless %next;
    delete $next{2,3};
    @this = map {$_-1} keys %next;
  }
  return $ret;
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 0
          && $value == int($value));
}

1;
__END__
