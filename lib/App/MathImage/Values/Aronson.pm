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

package App::MathImage::Values::Aronson;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';
use App::MathImage::ValuesFile;
use App::MathImage::ValuesFileWriter;

use vars '$VERSION';
$VERSION = 30;

use constant name => __('Aronson\'s Sequence');
use constant description => __('Aronson\'s sequence of the positions of letter "T" in self-referential "T is the first, fourth, ...".  Or French "E est la premiere, deuxieme, ...".  See the Math::Aronson module for details.');

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  require Math::Aronson;

  my $hi = $options{'hi'};
  my $lang = ($options{'aronson_lang'} || 'en');
  my $letter = $options{'aronson_letter'};
  my $conjunctions = ($options{'aronson_conjunctions'} ? 1 : 0);
  my $lying = ($options{'aronson_lying'} ? 1 : 0);

  my $letter_opt = (defined $letter ? $letter : '');
  my $options = "$lang,$letter_opt,$conjunctions,$lying";

  if (my $vf = App::MathImage::ValuesFile->new (package => __PACKAGE__,
                                                options => $options,
                                                hi => $hi)) {
    ### use ValuesFile: $vf
    return $vf;
  }

  my $aronson = Math::Aronson->new
    (hi                   => $hi,
     lang                 => $lang,
     letter               => $letter,
     without_conjunctions => ! $conjunctions,
     lying                => $lying,
    );

  # my $vfw = App::MathImage::ValuesFileWriter->new
  #   (package => __PACKAGE__,
  #    hi      => $hi);

  return bless { aronson => $aronson,
                 # vfw     => $vfw,
               }, $class;
}
sub next {
  my ($self) = @_;
  ### Aronson next(): $self->{'i'}
  return $self->{'aronson'}->next;
}

1;
__END__
