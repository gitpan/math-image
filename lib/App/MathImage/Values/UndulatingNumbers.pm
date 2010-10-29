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

package App::MathImage::Values::UndulatingNumbers;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 28;

use constant name => __('Undulating Numbers');
use constant description => __('Numbers like 37373 which are a pattern of digits ABAB...');
use constant growth => 'exponential';

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $radix = $options{'radix'} || 10;
  if ($radix == 10) {
    return bless { i     => -11,
                   rep   => 0,
                   radix => $radix,
                 }, $class;
  } else {
    return bless { n     => -1,
                   inc   => 1,
                   limit => $radix * $radix - 1,
                   radix => $radix,
                   skip  => $radix+1,  # at 11
                 }, $class;
  }
}

my @table =
  grep {pred({radix=>10},$_)}
  map {sprintf '%02d', $_}
  10 .. 999;

sub next {
  my ($self) = @_;
  # ### UndulatingNumbers next()

  my $radix = $self->{'radix'};
  my $rep = $self->{'rep'};
  if ($radix == 10) {
    my $i = ++$self->{'i'};
    if ($i < 0) {
      return $i+10;
    }
    if ($i > $#table) {
      $i = $self->{'i'} = 0;
      $self->{'rep'} = ++$rep;
    }
    my $ret = $table[$i];
    return $ret . (substr($ret,-2) x $rep);

  } else {
    my $n = ($self->{'n'} += $self->{'inc'});
    if ($n >= $self->{'limit'}) {
      $n = ($self->{'n'} += $self->{'inc'} + 1);
      $self->{'inc'} = $self->{'inc'} * $radix + (($self->{'inc'} & 1) ^ 1);
      $self->{'limit'} = ($self->{'limit'} + $radix * $self->{'inc'});
      $self->{'skip'} = $radix - 1;
      ### limit, skip to: $n
      ### inc now: $self->{'inc'}
      ### next limit: $self->{'limit'}

    } elsif (--$self->{'skip'} < 0) {
      $n = ($self->{'n'} += $self->{'inc'});
      $self->{'skip'} = $radix - 1;
      ### skip to: $n
    }

    return $n;
  }
}

sub pred {
  my ($self, $n) = @_;
  my $radix = $self->{'radix'};
  if ($radix == 10) {
    return (length($n) <= 1
            || (substr($n,0,1) ne substr($n,1,1)
                && $n =~ /^(([0-9])[0-9])\1*\2?$/));
  } else {
    my $a = $n % $radix;
    if ($n = int($n/$radix)) {
      my $b = $n % $radix;

      while ($n = int($n/$radix)) {
        if (($n % $radix) != $a) { return 0; }

        $n = int($n/$radix) || last;
        if (($n % $radix) != $b) { return 0; }
      }
    }
    return 1;
  }
}

1;
__END__

