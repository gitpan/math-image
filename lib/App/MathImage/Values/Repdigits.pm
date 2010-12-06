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

package App::MathImage::Values::Repdigits;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 36;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Repdigits');
use constant description => __('Numbers which are a "repdigit", meaning 1 ... 9, 11, 22, 33, ... 99, 111, 222, 333, ..., 999, etc.  The default is decimal, or select a radix.');

use constant parameters => { radix => { type => 'integer',
                                        default => 10,
                                      }
                           };

sub oeis {
  my ($class_or_self) = @_;
  return ((ref $class_or_self
                ? $class_or_self->{'radix'}
                : $class_or_self->parameters->{'radix'}->{'default'}) == 10
          ? 'A010785'
          : undef);
}

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;

  my $radix = $options{'radix'} || $class->parameters->{'radix'}->{'default'};
  if ($radix < 2) { $radix = 10; }

  my $self = bless { radix => $radix }, $class;
  if ($radix == 2) {
    $self->{'i'} = 0;
  } else {
    $self->{'n'} = -1;
    $self->{'inc'} = 1;
    $self->{'digit'} = -1;
  }
  return $self;
}
sub next {
  my ($self) = @_;

  my $radix = $self->{'radix'};
  if ($radix == 2) {
    return (1 << ($self->{'i'}++)) - 1;
  }

  my $n = ($self->{'n'} += $self->{'inc'});
  if (++$self->{'digit'} >= $radix) {
    $self->{'inc'} = $self->{'inc'} * $radix + 1;
    $self->{'digit'} = 1;
    $self->{'n'} = ++$n;
    ### digit: $self->{'digit'}
    ### inc: $self->{'inc'}
    ### $n
  }
  return $n;
}

sub pred {
  my ($self, $n) = @_;
  my $radix = $self->{'radix'};
  if ($radix == 2) {
    return ! (($n+1) & $n);
  }
  if ($radix == 10) {
    my $digit = substr($n,0,1);
    return ($n !~ /[^$digit]/);

  } else {
    my $digit = $n % $radix;
    while ($n = int($n/$radix)) {
      if (($n % $radix) != $digit) {
        return 0;
      }
    }
    return 1;
  }
}

sub ith {
  my ($self, $i) = @_;
  my $radix = $self->{'radix'};

  if ($radix == 2) {
    return (1 << $i) - 1;
  }

  if (--$i < 0) {
    return 0;
  }
  my $digit = ($i % ($radix-1)) + 1;
  $i = int($i/($radix-1)) + 1;
  return ($radix ** $i - 1) / ($radix - 1) * $digit;
}

1;
__END__
