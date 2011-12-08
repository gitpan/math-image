# progressive hi limit
# FIXME: p=2 up wrong



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


# http://www.cs.uwaterloo.ca/journals/JIS/VOL12/Broughan/broughan16.pdf



package App::MathImage::NumSeq::PrimeIndexPrimes;
use 5.004;
use strict;
use List::Util 'min', 'max';
use POSIX ();

use vars '$VERSION', '@ISA';
$VERSION = 83;
use Math::NumSeq::Base::Array;
@ISA = ('Math::NumSeq::Base::Array');

use Math::NumSeq::Primes;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant description => Math::NumSeq::__('The primes which are at prime number index positions, 3, 5, 11, 17, 31, etc.');
use constant characteristic_monotonic => 2;
use constant values_min => 3;

use constant parameter_info_array =>
  [ { name      => 'level',
      share_key => 'prime_index_primes_level',
      display   => Math::NumSeq::__('Level'),
      type      => 'integer',
      default   => 1,
      minimum   => 0,
      description => Math::NumSeq::__('The level of prime-index repetition to apply.'),
    } ];


# OEIS-Catalogue: A006450  # PIPs
# # OEIS-Catalogue: A049078 level=2
# # OEIS-Catalogue: A049079 level=3
# # OEIS-Catalogue: A049080 level=4
# # OEIS-Catalogue: A049081 level=5
#
my @oeis_anum = ('A000040',  # primes
                 'A006450',  # PIPs
                 # 'A049078',  # prime index primes level 2
                 # 'A049079',  # prime index primes level 3
                 # 'A049080',  # prime index primes level 4
                 # 'A049081',  # prime index primes level 5
                );
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum[$self->{'level'}];
}

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  my $level = $options{'level'};
  if (! defined $level) { $level = 1; }

  my @array = Math::NumSeq::Primes::_primes_list ($lo, $hi);
  my $primes = \@array;
  foreach (1 .. $level) {
    my $i = 0;
    foreach my $prime (@array) {
      last if ($prime > $#array);
      $array[$i++] = $array[$prime-1];
    }
    $#array = $i-1;
  }
  return $class->SUPER::new (%options,
                             array => \@array);
}

1;
__END__
