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

package App::MathImage::NumSeq::Sequence::ThueMorse;
use 5.004;
use strict;
use warnings;
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence';
use App::MathImage::NumSeq::Base::Digits;

use vars '$VERSION';
$VERSION = 38;


# ENHANCE-ME: maybe a radix parameter, modulo sum of digits

# bit count per example in perlfunc unpack()

use constant name => __('Digit Sum Modulo');
use constant description => __('Sum of the digits in the given radix, modulo that radix.  Eg. for binary this is the bitwise parity.');
use constant parameter_list => (App::MathImage::NumSeq::Base::Digits::parameter_common_radix);

# use constant parameter_list => ({ name    => 'parity',
#                                   display => __('Parity'),
#                                   type    => 'enum',
#                                   choices => ['odd','even'],
#                                   choices_display => [__('Odd'),__('Even')],
#                                   description => __('The parity odd or even to show for the sequence.'),
#                                 });

# use constant oeis => 'A001969'; # with even 1s
# df 'A026147'; # positions of 1s in evil
# cf A001285
my @oeis = (undef,
            undef,
            'A010060', # 2 binary
            'A053838', # 3 ternary
            'A053839', # 4
            'A053840', # 5
            'A053841', # 6
            'A053842', # 7
            'A053843', # 8
            'A053844', # 9
           );
sub oeis {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis[$radix];
}


# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  $lo = max ($lo, 0); # no negatives

  my $odd = 1;
  if (defined $options{'thue_morse_odd'}) {
    $odd = $options{'thue_morse_odd'};
  }
  if ($options{'parity'} && $options{'parity'} eq 'even') {
    $odd = 0;
  }

  my $self = bless { odd => $odd }, $class;

  # i initially the first $i < $lo satisfying pred(), but no further back
  # than -1
  my $i = $lo-1;
  while ($i >= 0 && ! $self->pred($i)) {
    $i--;
  }
  $self->{'i'} = $i;
  return $self;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'};
  if (! ($i & 3)) {
    ### 0b...00 next same parity 0b...11 which is +3
    return ($self->{'i'} += 3);
  }
  if (($i & 3) == 1) {
    ### 0b...01 next same parity 0b...10 which is +1
    return ($self->{'i'} += 1);
  }
  if (($i & 6) == 2) {
    ### 0b...01. next same parity 0b...10. which is +2
    return ($self->{'i'} += 2);
  }
  # search
  until ($self->pred(++$i)) { }
  return ($self->{'i'} = $i);
}

sub pred {
  my ($self, $n) = @_;
  return $self->{'odd'} ^ !(1 & unpack('%32b*', pack('I', $n)));
}
1;
__END__
