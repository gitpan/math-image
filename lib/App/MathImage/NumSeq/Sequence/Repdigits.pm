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

package App::MathImage::NumSeq::Sequence::Repdigits;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';
use App::MathImage::NumSeq::Base::Digits;

use vars '$VERSION';
$VERSION = 56;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Repdigits');
use constant description => __('Numbers which are a "repdigit", meaning 1 ... 9, 11, 22, 33, ... 99, 111, 222, 333, ..., 999, etc.  The default is decimal, or select a radix.');
use constant values_min => 1;
use constant parameter_list => (App::MathImage::NumSeq::Base::Digits::parameter_common_radix());

sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return ($radix == 10
          ? 'A010785'
          : undef);
}
# OeisCatalogue: A010785 radix=10

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;

  my $radix = $options{'radix'} || $class->parameter_default('radix');
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
sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
}
sub next {
  my ($self) = @_;

  my $i = $self->{'i'}++;
  my $radix = $self->{'radix'};
  if ($radix == 2) {
    return (1 << $i) - 1;

  } else {
    my $n = ($self->{'n'} += $self->{'inc'});
    if (++$self->{'digit'} >= $radix) {
      $self->{'inc'} = $self->{'inc'} * $radix + 1;
      $self->{'digit'} = 1;
      $self->{'n'} = ($n += 1); # not ++$n as that gives warnings on overflow
      ### digit: $self->{'digit'}
      ### inc: $self->{'inc'}
      ### $n
    }
    return ($i, $n);
  }
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
