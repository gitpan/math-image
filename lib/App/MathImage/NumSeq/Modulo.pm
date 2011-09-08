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

package App::MathImage::NumSeq::Modulo;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 69;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('Modulo');
use constant description => Math::NumSeq::__('Remainder to a given modulus.');
sub characteristic_modulus {
  my ($self) = @_;
  return $self->{'modulus'};
}
use constant characteristic_monotonic => 0;
use constant parameter_info_array =>
  [ { name        => 'modulus',
      type        => 'integer',
      display     => Math::NumSeq::__('Modulus'),
      default     => 13,
      minimum     => 1,
      width       => 3,
      description => Math::NumSeq::__('Modulus.'),
    } ];

use constant values_min => 0;
sub values_max {
  my ($self) = @_;
  return $self->{'modulus'} - 1;
}

# cf A008687 - count 1s in twos-complement -n
#
my @oeis = (undef,  # 0
            undef,  # 1
            undef,  # 2
            'A010872',  # 3
            # OEIS-Catalogue: A010872 modulus=3
            'A010873',  # 4
            # OEIS-Catalogue: A010873 modulus=4
            'A010874',  # 5
            # OEIS-Catalogue: A010874 modulus=5
            'A010875',  # 6
            # OEIS-Catalogue: A010875 modulus=6
            'A010876',  # 7
            # OEIS-Catalogue: A010876 modulus=7
            'A010877',  # 8
            # OEIS-Catalogue: A010877 modulus=8
            'A010878',  # 9
            # OEIS-Catalogue: A010878 modulus=9
            'A010879',  # 10
            # OEIS-Catalogue: A010879 modulus=10
            'A010880',  # 11
            # OEIS-Catalogue: A010880 modulus=11
            'A010881',  # 12
            # OEIS-Catalogue: A010881 modulus=12
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $modulus = (ref $class_or_self
                 ? $class_or_self->{'modulus'}
                 : $class_or_self->parameter_default('modulus'));
  return $oeis[$modulus];
}

sub ith {
  my ($self, $i) = @_;
  return ($i % $self->{'modulus'});
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 0 && $value < $self->{'modulus'} && $value == int($value));
}

1;
__END__

