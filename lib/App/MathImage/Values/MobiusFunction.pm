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

package App::MathImage::Values::MobiusFunction;
use 5.004;
use strict;
use warnings;
use List::Util 'min','max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 26;

use constant name => __('Mobius Function');
use constant description => __('The Mobius function, being 1 for an even number of prime factors, -1 for an odd number, or 0 if any repeated factors (ie. not square-free).');
use constant type => 'count1';

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};

  my $count = "0" x ($hi+1);
  substr ($count, 1,1) = "\003";
  my $i = min(1, $lo-1);
  my $self =  bless { i     => $i,
                     string => \$count,
                     hi     => $hi,
                   }, $class;
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
  if ($i <= 1) {
    if ($i <= 0) { return ($i, undef); }
    else { return ($i, 1); }
  }

  my $cref = $self->{'string'};

  my $ret = substr($$cref, $i,1);
  if ($ret eq '0') {
    # a prime
    $ret = 1;

    for (my $j = $i; $j <= $hi; $j += $i) {
      substr ($$cref, $j,1,
              chr (2 | (1 ^ ord(substr($$cref, $j,1)))));
    }

    my $step = $i * $i;
    for (my $j = $step; $j <= $hi; $j += $step) {
      substr ($$cref, $j,1, '4');  # repeated factor
    }
    # print "applied: $i\n";
    # for (my $j = 0; $j < $hi; $j++) {
    #   printf "  %2d %2d\n", $j, ord(substr($$cref, $j,1));
    # }
  }
  if ($ret >= 4) {
    return ($i, 0);
  } else {
    return ($i, 1+($ret & 1));
  }
}

sub pred {
  my ($self, $n) = @_;
  ### CountPrimeFactors pred(): $n
  if ($self->{'i'} <= $n) {
    ### extend from: $self->{'i'}
    my $i;
    while ((($i) = $self->next) && $i < $n) { }
  }
  my $ret = substr(${$self->{'string'}}, $n,1);
  if ($ret >= 4) {
    return 0;
  } else {
    return 1+($ret & 1);
  }
}

1;
__END__
