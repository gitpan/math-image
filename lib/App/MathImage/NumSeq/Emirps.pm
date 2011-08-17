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

package App::MathImage::NumSeq::Emirps;
use 5.004;
use strict;
use List::Util 'min', 'max';
use POSIX ();

use Math::NumSeq;
use base 'Math::NumSeq::Base::Array';

use vars '$VERSION';
$VERSION = 67;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('Emirps');
use constant description => Math::NumSeq::__('Numbers which are primes forwards and backwards, eg. 157 because both 157 and 751 are primes.  Palindromes like 131 are excluded.  Default is decimal, or select a radix.');

use Math::NumSeq::Base::Digits;
use constant parameter_info_array =>
  [ Math::NumSeq::Base::Digits::parameter_common_radix() ];

use constant values_min => 3;
use constant characteristic_monotonic => 1;

# A006567 - decimal reversal is a prime and different
# A007500 - decimal reversal is a prime, so palindrome primes too
#
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return ($radix == 10
          ? 'A006567'
          : undef);
}
# OEIS-Catalogue: A006567 radix=10

sub _digits_in_radix {
  my ($n, $radix) = @_;
  return 1 + int(log($n)/log($radix));
}

sub new {
  my ($class, %options) = @_;
  ### Emirps new()

  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  my $radix = $options{'radix'} || $class->parameter_default('radix');
  if ($radix < 2) { $radix = 10; }
  $lo = max (10, $lo);
  $hi = max ($lo, $hi);

  my $primes_lo = $radix ** (_digits_in_radix($lo,$radix) - 1) - 1;
  my $primes_hi = $radix ** _digits_in_radix($hi,$radix) - 1;
  #
  ### Emirps: "$lo to $hi radix $radix"
  ### using primes: "$primes_lo to $primes_hi"
  ### digits: _digits_in_radix($lo,$radix).' to '._digits_in_radix($hi,$radix)

  # App::MathImage::NumSeq::Primes->new (lo => $primes_lo,
  #                                      hi => $primes_hi);

  require App::MathImage::NumSeq::Primes;
  my @array = App::MathImage::NumSeq::Primes::_my_primes_list
    ($primes_lo, $primes_hi);

  my %primes;
  @primes{@array} = ();
  if ($radix == 10) {
    @array = grep {
      $_ >= $lo && $_ <= $hi && do {
        my $r;
        ((($r = reverse $_) != $_) && exists $primes{$r})
      }
    } @array;
  } else {
    @array = grep {
      $_ >= $lo && $_ <= $hi && do {
        my $r;
        (($r = _reverse_in_radix($_,$radix)) != $_ && exists $primes{$r})
      }
    } @array;
  }
  ### @array

  return $class->SUPER::new (%options,
                             radix => $radix,
                             array => \@array);
}

# return $n value reversed in $radix
sub _reverse_in_radix {
  my ($n, $radix) = @_;
  my $ret = 0;
  # ### _reverse_in_radix(): sprintf '%#X %d', $n, $n
  do {
    $ret = $ret * $radix + ($n % $radix);
  } while ($n = int($n/$radix));
  # ### ret: sprintf '%#X %d', $ret, $ret
  return $ret;
}

1;
__END__
