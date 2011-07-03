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

package App::MathImage::NumSeq::Sequence::PrimeFactorCount;
use 5.004;
use strict;
use List::Util 'min', 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 62;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('Count Prime Factors');
use constant description => __('Count of prime factors.');
use constant characteristic_count => 1;
use constant values_min => 1;
use constant i_start => 1;

use constant parameter_list => ({ name    => 'multiplicity',
                                  display => __('Multiplicity'),
                                  type    => 'enum',
                                  choices => ['repeated','distinct'],
                                  default => 'repeated',
                                  # description => __(''),
                                },
                               );

# OeisCatalogue: A001221 multiplicity=distinct
# OeisCatalogue: A001222 multiplicity=repeated
my %oeis = (distinct => 'A001221',
            repeated => 'A001222');
sub oeis_anum {
  my ($self) = @_;
  return $oeis{$self->{'multiplicity'}};
}


sub rewind {
  my ($self) = @_;
  ### PrimeFactorCount rewind()

  my $hi = $self->{'hi'};
  $self->{'i'} = $self->i_start;
  $self->{'string'} = "\0" x ($self->{'hi'}+1);

  while ($self->{'i'} < $self->{'lo'}-1) {
    ### rewind advance
    $self->next;
  }
  return $self;
}

sub next {
  my ($self) = @_;
  ### PrimeFactorCount next()

  my $i = $self->{'i'}++;
  my $hi = $self->{'hi'};
  if ($i > $hi) {
    return;
  }
  my $cref = \$self->{'string'};
  ### $i

  my $ret = vec ($$cref, $i,8);
  if ($ret == 0 && $i >= 2) {
    $ret++;
    # a prime
    for (my $power = 1; ; $power++) {
      my $step = $i ** $power;
      last if ($step > $hi);
      for (my $j = $step; $j <= $hi; $j += $step) {
        vec($$cref, $j,8) = min (255, vec($$cref,$j,8)+1);
      }
      last if $self->{'multiplicity'} eq 'distinct';
    }
    # print "applied: $i\n";
    # for (my $j = 0; $j < $hi; $j++) {
    #   printf "  %2d %2d\n", $j, vec($$cref, $j,8));
    # }
  }
  ### ret: "$i, $ret"
  return ($i, $ret);
}

sub ith {
  my ($self, $i) = @_;
  ### PrimeFactorCount pred(): $i
  if ($self->{'i'} <= $i) {
    ### extend from: $self->{'i'}
    my $upto;
    while ((($upto) = $self->next)
           && $upto < $i) { }
  }
  return vec($self->{'string'}, $i,8);
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 0);
}

1;
__END__



# Untouchables, not sum of proper divisors of any other integer
# p*q sum S=1+p+q
# so sums up to hi need factorize to (hi^2)/4
# 
