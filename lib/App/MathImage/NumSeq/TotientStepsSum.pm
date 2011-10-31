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

package App::MathImage::NumSeq::TotientStepsSum;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 79;
use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

use Math::NumSeq::Totient 13;
*_totient_by_sieve = \&Math::NumSeq::Totient::_totient_by_sieve;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant description => Math::NumSeq::__('Sum of totients when repeatedly applying until reach 1.');
use constant values_min => 0;
use constant characteristic_monotonic => 0;
use constant i_start => 1;
use constant parameter_info_array =>
  [ { name        => 'including_self',
      type        => 'boolean',
      display     => Math::NumSeq::__('Inc Self'),
      default     => 1,
      description => Math::NumSeq::__('Whether to include N itself in the sum.'),
    },
  ];

# OEIS-Catalogue: A053478 including_self=1
# OEIS-Catalogue: A092693 including_self=0
sub oeis_anum {
  my ($self) = @_;
  return ($self->{'including_self'} ? 'A053478' : 'A092693');
}

sub ith {
  my ($self, $i) = @_;
  my $sum = ($self->{'including_self'} ? $i : $i*0);
  while ($i > 1) {
    $sum += ($i = _totient_by_sieve($self,$i));
  }
  return $sum;
}

1;
__END__

# Local variables:
# compile-command: "math-image --values=TotientStepsSum"
# End:
