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

package App::MathImage::NumSeq::Sequence::GoldenSequence;
use 5.004;
use strict;
use List::Util 'max';
use POSIX 'ceil';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 52;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant PHI => (1 + sqrt(5)) / 2;

use constant name => __('Golden Sequence');
use constant values_min => 1;
# use constant description => __('');

use constant parameter_list => ({ name    => 'spectrum',
                                  display => __('Spectrum'),
                                  type    => 'float',
                                  default => PHI,
                                  description => __('The to show the spectrum of, usually an irrational.'),
                                },
                               );

# cf A003849  0,1,1,0,1,0,1
sub oeis_anum {
  my ($class_or_self) = @_;
  my $spectrum = (ref $class_or_self
              ? $class_or_self->{'spectrum'}
              : $class_or_self->parameter_default('spectrum'));
  if ($spectrum == PHI) {
    return 'A000201'; # Golden Sequence 1,3,4,6,8,9,11,12
  }
  return undef;
}

# integer part of sqrt(5*i*i) so as not to depend on multiplying up the
# float sqrt(5)
#
# i*(1+sqrt(5))/2
# = (i+sqrt(5*i*i))/2
# = i/2 + sqrt(5*i*i)/2

sub rewind {
  my ($self) = @_;
  ### GoldenSequence rewind()

  my $lo = $self->{'lo'};
  $lo = max (1, $lo);

  my $spectrum = $self->{'spectrum'} || PHI;
  ### $spectrum
  $self->{'i'} = ceil ($lo / $spectrum);
}

sub next {
  my ($self) = @_;
  ### GoldenSequence next()
  ### i: $self->{'i'}

  my $i = $self->{'i'}++;
  my $spectrum = $self->{'spectrum'};
  if ($spectrum == PHI) {
    ### i*PHI: $i*PHI
    ### int: int( ($i + sqrt(5*$i*$i)) / 2 )
    return ($i, int( ($i + sqrt(5*$i*$i)) / 2 ));
  } else {
    ### i*spectrum: $i * $spectrum
    return ($i, int($i * $spectrum));
  }
}

sub pred {
  my ($self, $n) = @_;
  if ($n <= 0) { return 0; }
  return (int($self->inv_floor($n) * $self->{'spectrum'}) == $n);
}
sub inv_floor {
  my ($self, $n) = @_;
  return ceil($n/$self->{'spectrum'});
}

1;
__END__

