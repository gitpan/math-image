# Copyright 2010 Kevin Ryde

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

package App::MathImage::Values::Emirps;
use 5.004;
use strict;
use warnings;
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::ValuesArray';

use vars '$VERSION';
$VERSION = 34;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Emirps');
use constant description => __('Numbers which are primes forwards and backwards, eg. 157 because both 157 and 751 are primes.  Palindromes like 131 are excluded.  Default is decimal, or select a radix.');

# http://www.research.att.com/~njas/sequences/A030310  # binary 1 positions
sub oeis {
  my ($class_or_self) = @_;
  if (! ref $class_or_self ||
      $class_or_self->{'radix'} == 10) {
    return 'A006567';
  }
  return undef;
}

use constant parameters => { radix => { type => 'integer',
                                        default => 10,
                                      }
                           };

sub _digits_in_radix {
  my ($n, $radix) = @_;
  return 1 + int(log($n)/log($radix));
}

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

sub new {
  my ($class, %options) = @_;
  ### Emirps new()

  require Math::Prime::XS;
  Math::Prime::XS->VERSION (0.022); # version 0.22 for lo==hi

  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  my $radix = $options{'radix'} || $class->parameters->{'radix'}->{'default'};
  if ($radix < 2) { $radix = 10; }
  $lo = max (10, $lo);
  $hi = max ($lo, $hi);

  my $primes_lo = $radix ** (_digits_in_radix($lo,$radix) - 1) - 1;
  my $primes_hi = $radix ** _digits_in_radix($hi,$radix) - 1;
  ### Emirps: "$lo to $hi radix $radix"
  ### using primes: "$primes_lo to $primes_hi"
  ### digits: _digits_in_radix($lo,$radix).' to '._digits_in_radix($hi,$radix)

  # App::MathImage::Values::Primes->new (lo => $primes_lo,
  #                                      hi => $primes_hi);

  my @primes = Math::Prime::XS::sieve_primes ($primes_lo, $primes_hi);
  my %primes;
  @primes{@primes} = ();
  if ($radix == 10) {
    @primes = grep {
      $_ >= $lo && $_ <= $hi && do {
        my $r;
        ((($r = reverse $_) != $_) && exists $primes{$r})
      }
    } @primes;
  } else {
    @primes = grep {
      $_ >= $lo && $_ <= $hi && do {
        my $r;
        (($r = _reverse_in_radix($_,$radix)) != $_ && exists $primes{$r})
      }
    } @primes;
  }
  ### @primes

  return bless { %options,
                 radix => $radix,
                 array => \@primes,
               }, $class;
}

1;
__END__
