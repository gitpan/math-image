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

package App::MathImage::NumSeq::Sequence::SqrtDigits;
use 5.004;
use strict;
use Carp;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Base::Digits';

use vars '$VERSION';
$VERSION = 57;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Square Root Digits');
use constant description => __('The square root of a given number written out in decimal or a given radix.');
use constant parameter_list => (__PACKAGE__->SUPER::parameter_list,
                                { name    => 'sqrt',
                                  display => __('Sqrt'),
                                  type    => 'integer',
                                  default => 2,
                                  description => __('The number to take the square root of.  If this is a perfect square then there\'s just a handful of bits to show, non squares go on infinitely.'),
                                },
                               );

# cf
# A020807 - sqrt(1/50) decimal
# A020811 - sqrt(1/54) decimal
# A010503 - sqrt(1/2) decimal == sqrt(2)/2
# A155781 - log15(22) decimal
# A011368 - 16^(1/9) decimal
# A010121 - continued fraction sqrt(7)
# A010122 - continued fraction sqrt(13)
# A010123 - continued fraction sqrt(14)
# A010124 - continued fraction sqrt(19)
# A010125 - continued fraction sqrt(21)
#
# A092855 - the bit positions of sqrt(2)-1 in binary
#
my %oeis = (2  => { 2  => 'A004539',   # sqrt2 binary digits
                    3  => 'A004540',   # sqrt2 base 3
                    4  => 'A004541',   # sqrt2 base 4
                    5  => 'A004542',
                    10 => 'A002193',   # sqrt2 decimal
                  },
            3  => { 10 => 'A002194' }, # sqrt3 decimal
            5  => { 10 => 'A002163' }, # sqrt5 decimal
            10 => { 10 => 'A010467' }, # sqrt10 decimal
            11 => { 10 => 'A010468' }, # sqrt11 decimal
            12 => { 10 => 'A010469' }, # sqrt12 decimal
            13 => { 10 => 'A010470' }, # sqrt13 decimal
            14 => { 10 => 'A010471' }, # sqrt14 decimal
            15 => { 10 => 'A010472' }, # sqrt15 decimal
            17 => { 10 => 'A010473' }, # sqrt17 decimal
            18 => { 10 => 'A010474' }, # sqrt18 decimal
            19 => { 10 => 'A010475' }, # sqrt19 decimal
            20 => { 10 => 'A010476' }, # sqrt20 decimal
            21 => { 10 => 'A010477' }, # sqrt21 decimal
            22 => { 10 => 'A010478' },
            23 => { 10 => 'A010479' },
            24 => { 10 => 'A010480' },
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $sqrt = (ref $class_or_self
              ? $class_or_self->{'sqrt'}
              : $class_or_self->parameter_default('sqrt'));
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis{$sqrt}->{$radix};
}
# OeisCatalogue: A004539 sqrt=2 radix=2
# OeisCatalogue: A004540 sqrt=2 radix=3
# OeisCatalogue: A004541 sqrt=2 radix=4
# OeisCatalogue: A004542 sqrt=2 radix=5
# OeisCatalogue: A002193 sqrt=2 radix=10
# OeisCatalogue: A002194 sqrt=3  radix=10
# OeisCatalogue: A002163 sqrt=5  radix=10
#
# these in sequence, but skipping perfect squares 16,25,36,49,64,81
# OeisCatalogue: A010467 sqrt=10 radix=10
# OeisCatalogue: A010468 sqrt=11 radix=10
# OeisCatalogue: A010469 sqrt=12 radix=10
# OeisCatalogue: A010470 sqrt=13 radix=10
# OeisCatalogue: A010471 sqrt=14 radix=10
# OeisCatalogue: A010472 sqrt=15 radix=10
# not 16
# OeisCatalogue: A010473 sqrt=17 radix=10
# OeisCatalogue: A010474 sqrt=18 radix=10
# OeisCatalogue: A010475 sqrt=19 radix=10
# OeisCatalogue: A010476 sqrt=20 radix=10
# OeisCatalogue: A010477 sqrt=21 radix=10
# OeisCatalogue: A010478 sqrt=22 radix=10
# OeisCatalogue: A010479 sqrt=23 radix=10
# OeisCatalogue: A010480 sqrt=24 radix=10
# not 25
# OeisCatalogue: A010481 sqrt=26 radix=10
# OeisCatalogue: A010482 sqrt=27 radix=10
# OeisCatalogue: A010483 sqrt=28 radix=10
# OeisCatalogue: A010484 sqrt=29 radix=10
# OeisCatalogue: A010485 sqrt=30 radix=10
# OeisCatalogue: A010486 sqrt=31 radix=10
# OeisCatalogue: A010487 sqrt=32 radix=10
# OeisCatalogue: A010488 sqrt=33 radix=10
# OeisCatalogue: A010489 sqrt=34 radix=10
# OeisCatalogue: A010490 sqrt=35 radix=10
# not 36
# OeisCatalogue: A010491 sqrt=37 radix=10
# OeisCatalogue: A010492 sqrt=38 radix=10
# OeisCatalogue: A010493 sqrt=39 radix=10
# OeisCatalogue: A010494 sqrt=40 radix=10
# OeisCatalogue: A010495 sqrt=41 radix=10
# OeisCatalogue: A010496 sqrt=42 radix=10
# OeisCatalogue: A010497 sqrt=43 radix=10
# OeisCatalogue: A010498 sqrt=44 radix=10
# OeisCatalogue: A010499 sqrt=45 radix=10
# OeisCatalogue: A010500 sqrt=46 radix=10
# OeisCatalogue: A010501 sqrt=47 radix=10
# OeisCatalogue: A010502 sqrt=48 radix=10
# OeisCatalogue: A010503 sqrt=50 radix=10
# OeisCatalogue: A010504 sqrt=51 radix=10
# OeisCatalogue: A010505 sqrt=52 radix=10
# OeisCatalogue: A010506 sqrt=53 radix=10
# OeisCatalogue: A010507 sqrt=54 radix=10
# OeisCatalogue: A010508 sqrt=55 radix=10
# OeisCatalogue: A010509 sqrt=56 radix=10
# OeisCatalogue: A010510 sqrt=57 radix=10
# OeisCatalogue: A010511 sqrt=58 radix=10
# OeisCatalogue: A010512 sqrt=59 radix=10
# OeisCatalogue: A010513 sqrt=60 radix=10
# OeisCatalogue: A010514 sqrt=61 radix=10
# OeisCatalogue: A010515 sqrt=62 radix=10
# OeisCatalogue: A010516 sqrt=63 radix=10
# not 64
# OeisCatalogue: A010517 sqrt=65 radix=10
# OeisCatalogue: A010518 sqrt=66 radix=10
# OeisCatalogue: A010519 sqrt=67 radix=10
# OeisCatalogue: A010520 sqrt=68 radix=10
# OeisCatalogue: A010521 sqrt=69 radix=10
# OeisCatalogue: A010522 sqrt=70 radix=10
# OeisCatalogue: A010523 sqrt=71 radix=10
# OeisCatalogue: A010524 sqrt=72 radix=10
# OeisCatalogue: A010525 sqrt=73 radix=10
# OeisCatalogue: A010526 sqrt=74 radix=10
# OeisCatalogue: A010527 sqrt=75 radix=10
# OeisCatalogue: A010528 sqrt=76 radix=10
# OeisCatalogue: A010529 sqrt=77 radix=10
# OeisCatalogue: A010530 sqrt=78 radix=10
# OeisCatalogue: A010531 sqrt=79 radix=10
# OeisCatalogue: A010532 sqrt=80 radix=10
# not 81
# OeisCatalogue: A010533 sqrt=82 radix=10
# OeisCatalogue: A010534 sqrt=83 radix=10
# OeisCatalogue: A010535 sqrt=84 radix=10
# OeisCatalogue: A010536 sqrt=84 radix=10
# OeisCatalogue: A010537 sqrt=86 radix=10
# OeisCatalogue: A010538 sqrt=87 radix=10
# OeisCatalogue: A010539 sqrt=88 radix=10
# OeisCatalogue: A010540 sqrt=89 radix=10
# OeisCatalogue: A010541 sqrt=90 radix=10
# OeisCatalogue: A010542 sqrt=91 radix=10
# OeisCatalogue: A010543 sqrt=92 radix=10
# OeisCatalogue: A010544 sqrt=93 radix=10
# OeisCatalogue: A010545 sqrt=94 radix=10
# OeisCatalogue: A010546 sqrt=95 radix=10
# OeisCatalogue: A010547 sqrt=96 radix=10
# OeisCatalogue: A010548 sqrt=97 radix=10
# OeisCatalogue: A010549 sqrt=98 radix=10
# OeisCatalogue: A010550 sqrt=99 radix=10



my %radix_to_stringize = (2  => 'as_bin',
                          8  => 'as_oct',
                          10 => 'bstr');

sub new {
  my ($class, %options) = @_;
  ### SqrtDigits new()
  my $lo = $options{'lo'} || 0;
  my $radix = $options{'radix'} || 2;

  my $sqrt = $options{'sqrt'};
  if (defined $sqrt) {
    if ($sqrt =~ m{^\s*(\d+)\s*$}) {
      $sqrt = $1;
    } else {
      croak "Unrecognised Sqrt Digits parameter: $options{'sqrt'}";
    }
  } else {
    $sqrt = $class->parameter_default('sqrt');
  }

  unless (Math::BigInt->can('new')) {
    require Math::BigInt;
    Math::BigInt->import (try => 'GMP');
  }
  my $calcdigits = int(2*$options{'hi'} + 32);

  my $power;
  my $root;
  my $halfdigits = int($calcdigits/2);
  if ($radix == 2) {
    $root = Math::BigInt->new(1);
    $root->blsft ($calcdigits);
  } else {
    $power = Math::BigInt->new($radix);
    $power->bpow ($halfdigits);
    $root = Math::BigInt->new($power);
    $root->bmul ($root);
  }
  $root->bmul ($sqrt);
  ### $radix
  ### $calcdigits
  ### root of: "$root"
  $root->bsqrt();
  ### root is: "$root"

  if (my $method = $radix_to_stringize{$radix}) {
    my $str = $root->$method;
    my $i = (substr($str,0,2) eq '0b' ? 1 : -1); # trim 0b from as_bin()
    ### SqrtBits string: $str
    return bless { sqrt   => $sqrt,
                   radix  => $radix,
                   string => $str,
                   i      => $i,
                   power  => $power,
                 }, $class;
  } else {
    if ($radix > 1) {
      while ($power <= $root) {
        $power->bmul($radix);
      }
    }
    return bless { sqrt  => $sqrt,
                   radix => $radix,
                   i     => -1,
                   root  => $root,
                   power => $power,
                 }, $class;
  }
}

sub next {
  my ($self) = @_;
  my $radix = $self->{'radix'};
  if ($radix < 2) {
    return;
  }

  ### SqrtDigits next(): $self->{'i'}
  if (defined $self->{'string'}) {
    my $i = ++$self->{'i'};
    if ($i > length($self->{'string'})) {
      return;
    }
    ### string char: substr($self->{'string'},$i,1)
    return ($i, substr($self->{'string'},$i,1));
    
  } else {
    # digit by digit from the top like this is a bit slow, should chop into
    # repeated halves instead

    my $power = $self->{'power'};
    if ($power == 0) {
      return;
    }
    my $root  = $self->{'root'};
    ### root: "$root"
    ### power: "$power"

    $power->bdiv($self->{'radix'});
    (my $digit, $root) = $root->bdiv ($power);

    $self->{'power'} = $power;
    $self->{'root'} = $root;
    return (++$self->{'i'}, $digit);

    # my $digit = 0;
    # while ($root >= $power) {
    #   $digit++;
    #   $root -= $power;
    # }
    #
    # $self->{'power'} = $power;
    # $self->{'root'} = $root;
    # return (++$self->{'i'}, $digit);
  }
}

sub pred {
  my ($self, $n) = @_;
  return ($n < $self->{'radix'});
}

1;
__END__
