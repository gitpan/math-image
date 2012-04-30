# Copyright 2012 Kevin Ryde

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

package Math::NumSeq::MathImageAlphabeticalLength;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 97;
use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;


# use constant name => Math::NumSeq::__('...');
use constant description => Math::NumSeq::__('Length of i written out in words.');
use constant i_start => 1;
use constant characteristic_smaller => 1;
use constant characteristic_integer => 1;
use constant characteristic_count => 1;

use constant _HAVE_LINGUA_ANY_NUMBERS =>
  eval { require Lingua::Any::Numbers; 1 };

sub parameter_info_array {
  my ($class_or_self) = @_;
  my @choices;
  if (_HAVE_LINGUA_ANY_NUMBERS) {
    @choices = Lingua::Any::Numbers::available();
  }
  @choices = sort @choices;
  my $en;
  @choices = map { $_ eq 'EN' ? do { $en=1; () } : $_ } @choices;
  if ($en) {
    unshift @choices, 'EN';
  }
  return [
          {
           name        => 'language',
           type        => 'string',
           default     => 'EN',
           choices     => \@choices,
           width       => 8,
           # description => Math::NumSeq::__('...'),
          },
          {
           name        => 'number_type',
           type        => 'enum',
           default     => 'cardinal',
           choices     => ['cardinal','ordinal'],
           # description => Math::NumSeq::__('...'),
          },
          # Not through Lingua::Any::Numbers interface
          # {
          #  name        => 'gender',
          #  type        => 'enum',
          #  default     => 'M',
          #  choices     => ['M','F','N'],
          #  # description => Math::NumSeq::__('...'),
          # },
          # {
          #  name        => 'declension',
          #  type        => 'enum',
          #  default     => 'nominative',
          #  choices     => ['nominative','genitive','dative','accusative','ablative'],
          #  # description => Math::NumSeq::__('...'),
          # },
         ];
}

sub values_min {
  my ($self) = @_;
  return 1;  # depends on the language
}


my %oeis_anum = (sv => 'A059124',
                );
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum{$self->{'language'}};
}

sub ith {
  my ($self, $i) = @_;
  ### MathImageAlphabeticalLength ith(): "$i"
  _HAVE_LINGUA_ANY_NUMBERS or return undef;

  if (_is_infinite($i)) {
    return undef;
  }

  my $str;
  if ($self->{'number_type'} eq 'ordinal') {
    $str = Lingua::Any::Numbers::to_ordinal($i,$self->{'language'});
    if ($str eq $i) {
      return undef;
    }
  } else {
    $str = Lingua::Any::Numbers::to_string($i,$self->{'language'});
  }
  $str =~ s/\W//g;
  return length($str);
}

1;
__END__
