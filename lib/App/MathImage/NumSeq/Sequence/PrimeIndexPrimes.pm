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



package App::MathImage::NumSeq::Sequence::PrimeIndexPrimes;
use 5.004;
use strict;
use List::Util 'min', 'max';
use POSIX ();

use App::MathImage::NumSeq::Sequence::Primes;
use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Base::Array';

use vars '$VERSION';
$VERSION = 58;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Prime Numbers');
use constant description => __('The primes which are at prime number index positions, 3, 5, 11, 17, 31, etc.');
use constant values_min => 3;

use constant parameter_list =>
  { name      => 'level',
    share_key => 'prime_index_primes_level',
    display   => __('Level'),
    type      => 'integer',
    default   => 1,
    minimum   => 0,
    description => __('The level of prime-index repetition to apply.'),
  };


# OeisCatalogue: A006450  # PIPs 
# OeisCatalogue: A049078 level=2
# OeisCatalogue: A049079 level=3
# OeisCatalogue: A049080 level=4
# OeisCatalogue: A049081 level=5
#
my @oeis_anum = ('A000040',  # primes
                 'A006450',  # PIPs
                 'A049078',  # prime index primes level 2
                 'A049079',  # prime index primes level 3
                 'A049080',  # prime index primes level 4
                 'A049081',  # prime index primes level 5
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

  my @array = App::MathImage::NumSeq::Sequence::Primes::_my_primes_list ($lo, $hi);
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
