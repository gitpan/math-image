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

package App::MathImage::Values::MobiusFunction;
use 5.004;
use strict;
use warnings;
use List::Util 'min','max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 41;

use constant name => __('Mobius Function');
use constant description => __('The Mobius function, being 1 for an even number of prime factors, -1 for an odd number, or 0 if any repeated factors (ie. not square-free).');
use constant type => 'count1';
# use constant oeis => 'A008683'; # mobius -1,0,1


# uncomment this to run the ### lines
#use Smart::Comments;

# each 2-bit vec() value is
#    0 unset
#    1 square factor
#    2 even count of factors
#    3 odd count of factors

my @tranform = (0, 0, 2, 1);

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};

  my $self =  bless { i  => 1,
                      hi => $hi,
                    }, $class;
  $self->{'string'} = "\0" x (($hi+1)/4);  # 4 of 2 bits each
  vec($self->{'string'}, 0,2) = 1;  # N=0 treated as square
  vec($self->{'string'}, 1,2) = 2;  # N=1 treated as even

  while ($self->{'i'} < $lo) {
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
    if ($i <= 0) { return ($i, 0); }
    else { return ($i, 2); }
  }

  my $sref = \$self->{'string'};

  my $ret = vec($$sref, $i,2);
  if ($ret == 0) {
    ### prime: $i
    $ret = 3; # odd

    # existing squares $v==1 left alone, others toggle 2=odd,3=even
    for (my $j = $i; $j <= $hi; $j += $i) {
      ### p: "$j ".vec($$sref, $j,2)
      if ((my $v = vec($$sref, $j,2)) != 1) {
        vec($$sref, $j,2) = ($v ^ 1) | 2;
      ### set: vec($$sref, $j,2)
      }
    }

    # squares set to $v==1
    my $step = $i * $i;
    for (my $j = $step; $j <= $hi; $j += $step) {
      vec($$sref, $j,2) = 1;
    }
    # print "applied: $i\n";
    # for (my $j = 0; $j < $hi; $j++) {
    #   printf "  %2d %2d\n", $j, vec($$sref,$j,2);
    # }
  }
  ### ret: "$i, $ret -> ".($ret != 1 && 4-$ret)
  return ($i, $tranform[$ret]);
}

sub pred {
  my ($self, $n) = @_;
  ### MobiusFunction pred(): $n
  if ($self->{'i'} <= $n) {
    ### extend from: $self->{'i'}
    my $i;
    while ((($i) = $self->next) && $i < $n) { }
  }
  return $tranform[ vec($self->{'string'}, $n,2) ];
}

1;
__END__
