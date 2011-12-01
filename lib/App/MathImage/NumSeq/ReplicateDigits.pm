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

package App::MathImage::NumSeq::ReplicateDigits;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 82;

use Math::NumSeq 7; # v.7 for _is_infinite()
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant description => Math::NumSeq::__('Replicate the digits of i, so i=123 gives value 112233.');
use constant values_min => 0;
use constant characteristic_monotonic => 2;

use Math::NumSeq::DigitCount 4;
use constant parameter_info_array =>
  [ Math::NumSeq::Base::Digits::parameter_common_radix(),
    { name => 'replicate',
      type => 'integer',
      minimum => 1,
      default => 2,
      width => 1,
    },
  ];

my @oeis_anum;
BEGIN {
}
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum[$self->{'radix'}]->[$self->{'replicate'}];
}

sub ith {
  my ($self, $i) = @_;
  ### ReplicateDigits ith(): $i

  if (_is_infinite($i)) {
    return $i;  # don't loop forever if $i is +infinity
  }

  my $value = ($i * 0);   # inherit bignum 0
  my $power = $value + 1; # inherit bignum 1
  if ($i < 0) {
    $power = -$power;
    $i = - $i;
  }

  my $radix = $self->{'radix'};
  my $replicate = $self->{'replicate'};

  while ($i) {
    my $digit = $i % $radix;
    $i = int($i/$radix);
    foreach (1 .. $replicate) {
      $value += $power * $digit;
      $power *= $radix;
    }
  }
  return $value;
}

sub pred {
  my ($self, $value) = @_;
  my $radix = $self->{'radix'};
  my $replicate = $self->{'replicate'};
  $value = abs($value);
  while ($value) {
    my $digit = $value % $radix;
    $value = int($value/$radix);
    foreach (2 .. $replicate) {
      if (($value % $radix) != $digit) {
        return 0;
      }
      $value = int($value/$radix);
    }
  }
  return 1;
}

1;
__END__

# Local variables:
# compile-command: "math-image --values=ReplicateDigits"
# End:
