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

package App::MathImage::NumSeq::Sequence::UndulatingNumbers;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence';
use App::MathImage::NumSeq::Radix;

use vars '$VERSION';
$VERSION = 46;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Undulating Numbers');
use constant description => __('Numbers like 37373 which are a pattern of digits ABAB...');
use constant values_min => 1;
use constant growth => 'exponential';

# A033619 base 10 >=0 including a==b
# A046075 base 10 >=101 with a!=b
sub oeis {
  my ($class_or_self) = @_;
  # if (! ref $class_or_self ||
  #     $class_or_self->{'radix'} == 10) {
  #   return 'A033619'; # base 10 including a==b
  # }
  # if (ref $class_or_self && $class_or_self->{'radix'} == 2) {
  #   return 'A046076';
  # }
  return undef;
}

use constant parameter_list => (App::MathImage::NumSeq::Radix::parameter_common_radix);

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $radix = $options{'radix'} || $class->parameter_default('radix');
  if ($radix < 2) { $radix = 10; }

  return bless { radix => $radix,
                 n     => -1,
                 inc   => 1,
                 a     => 0,
                 b     => 0,
               }, $class;
}

sub next {
  my ($self) = @_;
  ### UndulatingNumbers next()

  my $radix = $self->{'radix'};
  my $n;
  if ($n = ($self->{'n'} += $self->{'inc'})) {
    $self->{'b'}++;
    ### n: $self->{'n'}
    ### a: $self->{'a'}
    ### b: $self->{'b'}

    if ($self->{'b'} == $self->{'a'}) {
      $self->{'b'}++;
      $self->{'n'} = ($n += $self->{'inc'});
      ### skip a to b: $self->{'b'}
      ### n now: $n
    }

    if ($self->{'b'} >= $radix ) {
      $self->{'b'} = 0;
      $self->{'n'} = ($n += ($self->{'inc'} & 1) ^ 1);
      ### a inc
      ### n now: $n

      if (++$self->{'a'} >= $radix) {
        # 101 -> 1010
        # or 1010 -> 10101
        my $low = $self->{'inc'} & 1;
        $self->{'inc'} = $self->{'inc'} * $radix + !$low;
        $self->{'a'} = 1;
        $self->{'n'} = ($n += $low);
        ### lengthen to inc: $self->{'inc'}
        ### n now: $n
      }
    }
  }
  return $n;
}

sub pred {
  my ($self, $n) = @_;
  my $radix = $self->{'radix'};
  my $a = $n % $radix;
  if ($n = int($n/$radix)) {
    my $b = $n % $radix;
    if ($a == $b) { return 0; }

    while ($n = int($n/$radix)) {
      if (($n % $radix) != $a) { return 0; }

      $n = int($n/$radix) || last;
      if (($n % $radix) != $b) { return 0; }
    }
  }
  return 1;
}

sub ith {
  my ($self, $i) = @_;
  ### UndulatingNumbers ith(): $i
  my $radix = $self->{'radix'};
  my $rdec = $radix - 1;

  my $pair_step = $rdec*$rdec;
  my $i_pair = $i % $pair_step;
  my $i_len = int($i/$pair_step);
  ### $i_pair
  ### $i_len

  my $a = int($i_pair/$rdec) + 1;
  my $b = $i_pair % $rdec;
  $b += ($b >= $a);
  ### $a
  ### $b

  my $ret = ($a*$radix + $b)*$radix + $a;
  while ($i_len--) {
    $ret = ($ret * $radix) + $a;
    last unless $i_len--;
    $ret = ($ret * $radix) + $b;
  }
  ### $ret
  return $ret;
}

1;
__END__


  # if ($radix == 10) {
  #   return (length($n) <= 1
  #           || (substr($n,0,1) ne substr($n,1,1)
  #               && $n =~ /^(([0-9])[0-9])\1*\2?$/));
  # }

  # if (0 && $radix == 10) {
  #   return bless { i     => -11,
  #                  rep   => 0,
  #                  radix => $radix,
  #                }, $class;
  # } else {
  # }

# my @table =
#   grep {pred({radix=>10},$_)}
#   map {sprintf '%02d', $_}
#   10 .. 999;

  # my $rep = $self->{'rep'};
  # if (0 && $radix == 10) {
  #   my $i = ++$self->{'i'};
  #   if ($i < 0) {
  #     return $i+10;
  #   }
  #   if ($i > $#table) {
  #     $i = $self->{'i'} = 0;
  #     $self->{'rep'} = ++$rep;
  #   }
  #   my $ret = $table[$i];
  #   return $ret . (substr($ret,-2) x $rep);
  #
  # } else {

                   # limit => $radix * $radix - 1,
                   # skip  => $radix+1,  # at 11

    # if ($n >= $self->{'limit'}) {
    #   $n = ($self->{'n'} += $self->{'inc'} + 1);
    #   $self->{'limit'} = ($self->{'limit'} + $radix * $self->{'inc'});
    #   $self->{'skip'} = $radix - 1;
    #   ### limit, skip to: $n
    #   ### inc now: $self->{'inc'}
    #   ### next limit: $self->{'limit'}
    #
    # } elsif (--$self->{'skip'} < 0) {
    #   $n = ($self->{'n'} += $self->{'inc'});
    #   $self->{'skip'} = $radix - 1;
    #   ### skip to: $n
    # }

