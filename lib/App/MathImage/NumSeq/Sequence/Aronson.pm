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

package App::MathImage::NumSeq::Sequence::Aronson;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';
use App::MathImage::NumSeq::Base::File;
use App::MathImage::NumSeq::Base::FileWriter;

use vars '$VERSION';
$VERSION = 52;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Aronson\'s Sequence');
use constant description => __('Aronson\'s sequence of the positions of letter "T" in self-referential "T is the first, fourth, ...".  Or French "E est la premiere, deuxieme, ...".  See the Math::Aronson module for details.');
use constant values_min => 1;
use constant parameter_list =>
  ({
    name    => 'aronson_lang',
    display => __('Language'),
    type    => 'enum',
    default => '',
    # Can't offer all langs as there's no "initial_string" except en and fr
    # if (eval { require Lingua::Any::Numbers }) {
    #   push @langs, sort map {lc} Lingua::Any::Numbers::available();
    #   @langs = List::MoreUtils::uniq (@langs);
    # }
    choices => ['en','fr'],
    choices_display => [__('EN'),__('FR')],
    #        en => __('English'),
    #        fr => __('French'));
    # %App::MathImage::Gtk2::Drawing::aronson_lang::EnumBits_to_display
    #   = ((map {($_,uc($_))} @langs),
   },
   {
    name    => 'aronson_letter',
    display => __('Letter'),
    type    => 'enum',
    default => '',
    choices => ['', 'A' .. 'Z'],
   },
   {
    name    => 'aronson_conjunctions',
    display => __('Conjunctions'),
    type    => 'boolean',
    default => 0,
    description => __('Whether to include conjunctions "and" or "et" in the words of the sequence.'),
   },
   {
    name    => 'aronson_lying',
    display => __('Lying'),
    type    => 'boolean',
    default => 0,
    description => __('Whether to show the "lying" version of the sequence, being positions which are not "T" (or whatever requested letter).'),
   });

# A005224    en, 'T', without_conjunctions=>1
# A055508    letter=>'H', without_conjunctions=>1
# A049525    letter=>'I', without_conjunctions=>1
# A081023    lying=>1
# A072886    lying=>1, initial_string=>"S ain't the"
# A080520    lang=>'fr'
#
# A072887    complement of lying A081023
# A081024    complement of lying "S ain't" A072886
# A072421    Latin P
# A072422    Latin N
# A072423    Latin T

sub oeis_anum {
  my ($self) = @_;
  if (ref $self) {
    if ($self->{'aronson_lang'} eq 'en') {
      if (! $self->{'aronson_conjunctions'}) {
        if ($self->{'aronson_letter'} eq 'T'
            || $self->{'aronson_letter'} eq '') {
          return 'A005224'; # english T
        }
        if ($self->{'aronson_letter'} eq 'H') {
          return 'A055508'; # english H
        }
        if ($self->{'aronson_letter'} eq 'I') {
          return 'A049525'; # english I
        }
      }
    } elsif ($self->{'aronson_lang'} eq 'fr') {
      if ($self->{'aronson_letter'} eq 'E'
          || $self->{'aronson_letter'} eq '') {
        return 'A080520'; # french E
      }
    }
  }
  return undef;
}

# sub new {
#   my ($class, %options) = @_;
# 
#   my $aronson 
# 
#   # my $vfw = App::MathImage::NumSeq::Base::FileWriter->new
#   #   (package => __PACKAGE__,
#   #    hi      => $hi);
# 
#   return bless { aronson => $aronson,
#                  aronson_lang => $lang,
#                  aronson_letter => $aronson->{'letter'},
#                  # vfw     => $vfw,
#                }, $class;
# }
sub rewind {
  my ($self) = @_;

  require Math::Aronson;
  my $hi = $self->{'hi'};
  my $lang = ($self->{'aronson_lang'} || 'en');
  my $letter = $self->{'aronson_letter'};
  my $conjunctions = ($self->{'aronson_conjunctions'} ? 1 : 0);
  my $lying = ($self->{'aronson_lying'} ? 1 : 0);

  my $letter_opt = (defined $letter ? $letter : '');
  my $options = "$lang,$letter_opt,$conjunctions,$lying";

  # if (my $vf = App::MathImage::NumSeq::Base::File->new (package => __PACKAGE__,
  #                                                 options => $options,
  #                                                 hi => $hi)) {
  #   ### use NumSeqFile: $vf
  #   return $vf;
  # }

  $self->{'i'} = 0;
  $self->{'aronson'} = Math::Aronson->new
    (hi                   => $hi,
     lang                 => $lang,
     letter               => $letter,
     without_conjunctions => ! $conjunctions,
     lying                => $lying,
    );
}
sub next {
  my ($self) = @_;
  ### Aronson next(): $self->{'i'}
  return ($self->{'i'}++, $self->{'aronson'}->next);
}

1;
__END__