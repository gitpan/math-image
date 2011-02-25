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

package App::MathImage::NumSeq::Sequence::Count::PrimeFactors;
use 5.004;
use strict;
use warnings;
use List::Util 'min', 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 45;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Count Prime Factors');
use constant description => __('Count of prime factors, as a grey scale of white for prime through to black for many factors (or the foreground through to background, if they\'re given in hex #RRGGBB).');
use constant type => 'count';
use constant values_min => 1;

use constant oeis => 'A001222'; # with multiplicity
# use constant oeis => 'A001221'; # without multiplicity
# OeisCatalogue: A001222

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  $lo = max (0, $lo);
  $hi = max (0, $hi);

  my $i = 1;
  my $self = bless { i => $i,
                     string => "\0" x ($hi+1),
                     hi     => $hi,
                   }, $class;
  vec ($self->{'string'}, 1,4) = 1;   # N=1 count 1
  while ($i < $lo-1) {
    $self->next;
  }
  return $self;
}
sub next {
  my ($self) = @_;

  my $i = $self->{'i'}++;
  my $hi = $self->{'hi'};
  if ($i > $hi) {
    return;
  }
  my $cref = \$self->{'string'};

  my $ret = vec ($$cref, $i,4);
  if ($ret == 0) {
    $ret++;
    # a prime
    for (my $power = 1; ; $power++) {
      my $step = $i ** $power;
      last if ($step > $hi);
      for (my $j = $step; $j <= $hi; $j += $step) {
        vec($$cref, $j,4) = min (15, vec($$cref,$j,4)+1);
      }
    }
    # print "applied: $i\n";
    # for (my $j = 0; $j < $hi; $j++) {
    #   printf "  %2d %2d\n", $j, vec($$cref, $j,4));
    # }
  }
  return ($i, $ret);
}

sub pred {
  my ($self, $n) = @_;
  ### Count-PrimeFactors pred(): $n
  if ($self->{'i'} <= $n) {
    ### extend from: $self->{'i'}
    my $i;
    while ((($i) = $self->next) && $i < $n) { }
  }
  return vec($self->{'string'}, $n,4);
}

1;
__END__



# Untouchables, not sum of proper divisors of any other integer
# p*q sum S=1+p+q
# so sums up to hi need factorize to (hi^2)/4
# 
