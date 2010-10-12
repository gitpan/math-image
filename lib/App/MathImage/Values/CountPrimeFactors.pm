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

package App::MathImage::Values::CountPrimeFactors;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 25;

use constant name => __('Count Prime Factors');
use constant description => __('Count of prime factors, as a grey scale of white for prime through to black for many factors (or the foreground through to background, if they\'re given in hex #RRGGBB).');
use constant type => 'count1';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 25;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};

  my $count = "\0" x ($hi+1);
  substr ($count, 1,1, "\001");
  my $i = 1;
  my $self = bless { i => $i,
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
  my $cref = $self->{'string'};

  my $ret = ord (substr ($$cref, $i,1));
  if ($ret == 0) {
    $ret++;
    # a prime
    for (my $power = 1; ; $power++) {
      my $step = $i ** $power;
      last if ($step > $hi);
      for (my $j = $step; $j <= $hi; $j += $step) {
        substr ($$cref, $j,1,
                chr (1 + ord(substr($$cref, $j,1))));
      }
    }
    # print "applied: $i\n";
    # for (my $j = 0; $j < $hi; $j++) {
    #   printf "  %2d %2d\n", $j, ord(substr($$cref, $j,1));
    # }
  }
  return ($i, $ret);
};

sub pred {
  my ($self, $n) = @_;
  return ord (substr (${$self->{'string'}}, $n,1));
}

1;
__END__
