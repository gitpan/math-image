# ordinal_func





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

package App::MathImage::Math::Aronson;
use 5.004;
use strict;
use warnings;
use Carp;
# use Lingua::EN::Numbers 1.01 'num2en_ordinal';  # 1.01 rewrite
use Lingua::Any::Numbers 'to_ordinal';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 16;

my $unaccent;
BEGIN {
  if (eval { require Unicode::Normalize }) {
    $unaccent = sub {
      ### unaccent: $_[0]
      $_[0] =~ s{([^[:ascii:]])}
                { my $c = $1;
                  my $nfd = Unicode::Normalize::normalize('D',$c);
                  ($nfd =~ /^([[:ascii:]])/ ? $1 : $c)
                }ge;
    };
  } else {
    $unaccent = sub {
      # latin-1, per devel/aronson-latin1.pl
      $_[0] =~ tr/\x{C0}\x{C1}\x{C2}\x{C3}\x{C4}\x{C5}\x{C7}\x{C8}\x{C9}\x{CA}\x{CB}\x{CC}\x{CD}\x{CE}\x{CF}\x{D1}\x{D2}\x{D3}\x{D4}\x{D5}\x{D6}\x{D9}\x{DA}\x{DB}\x{DC}\x{DD}\x{E0}\x{E1}\x{E2}\x{E3}\x{E4}\x{E5}\x{E7}\x{E8}\x{E9}\x{EA}\x{EB}\x{EC}\x{ED}\x{EE}\x{EF}\x{F1}\x{F2}\x{F3}\x{F4}\x{F5}\x{F6}\x{F9}\x{FA}\x{FB}\x{FC}\x{FD}\x{FF}/AAAAAACEEEEIIIINOOOOOUUUUYaaaaaaceeeeiiiinooooouuuuyy/;
    };
  }
}

sub new {
  my $class = shift;
  my @ret;
  my $self = bless { ret   => \@ret,
                     queue => [ ],
                     lang  => 'en',
                     @_
                   }, $class;

  if (defined (my $lang = $self->{'lang'})) {
    if ($lang eq 'fr') {
      %$self = (initial_string => 'e est la',
                conjunction_word => 'et',
                %$self);
    } elsif ($lang eq 'en') {
      %$self = (initial_string => 't is the',
                conjunction_word => 'and',
                %$self);
    }
  }

  my $conjunctions = delete $self->{'conjunctions'};
  my $conjunction_word = delete $self->{'conjunction_word'};
  my $conjunctions_func
    = ($self->{'conjunctions_func'} ||=
       ($conjunctions || ! defined $conjunction_word
        ? \&_conjunction_noop
        : do {
          $conjunction_word = lc($conjunction_word);
          sub { $_[0] =~ s/\b\Q$conjunction_word\E\b// }
        }));

  my $str = delete $self->{'initial_string'};
  if (! defined $str) {
    croak 'No initial_string';
  }
  &$unaccent ($str);
  $str = lc ($str);

  my $letter = $self->{'letter'};
  if (! defined $letter) {
    $letter = substr($str,0,1);
  }
  unless (length($letter)) {
    $letter = ' '; # dummy no-match empty
  }
  $self->{'letter'} = $letter = lc($letter);

  &$conjunctions_func ($str);
  $str =~ tr/a-z//cd;
  ### initial: $str
  my $upto = 1;
  my $pos = 0;
  while (($pos = index($str,$letter,$pos)) >= 0) {
    push @ret, $pos++ + $upto;
  }
  $self->{'upto'} = $upto + length($str);
  ### initial: $self
  return $self;
}

sub _conjunction_noop {
  return $_[0];
}

sub next {
  my ($self) = @_;
  my $ret = $self->{'ret'};
  for (;;) {
    if (my $n = shift @$ret) {
      push @{$self->{'queue'}}, $n;
      return $n;
    }

    my $k = shift @{$self->{'queue'}}
      || return;  # end of sequence

    my $str = to_ordinal ($k, $self->{'lang'});
    ### orig str: $str
    &{$self->{'conjunctions_func'}} ($str);
    &$unaccent ($str);
    $str = lc ($str);

    # FIXME: "premiere" is per Sloane's sequence, should this be an option?
    if ($str eq 'premier' && $self->{'lang'} eq 'fr') { $str = 'premiere'; }

    $str =~ tr/a-z//cd;
    ### munged str: $str

    my $upto = $self->{'upto'};
    my $letter = $self->{'letter'};
    my $pos = 0;
    while (($pos = index($str,$letter,$pos)) >= 0) {
      push @$ret, $pos++ + $upto;
    }
    $self->{'upto'} += length($str);
    ### now upto: $self->{'upto'}
    ### ret: $ret
    ### queue: $self->{'queue'}
  }
}

1;
__END__

=for stopwords Ryde Aronson Aronson's proven

=head1 NAME

App::MathImage::Math::Aronson -- generate values of Aronson's sequence

=head1 SYNOPSIS

 use App::MathImage::Math::Aronson;
 my $aronson = App::MathImage::Math::Aronson->new;
 print $aronson->next,"\n";
 print $aronson->next,"\n";

=head1 DESCRIPTION

Aronson's sequence is a kind of self-referential recurrence generated from
where the letter T falls in numbers written out in words.

    T is the first, fourth, eleventh, sixteenth, ...
    ^    ^       ^      ^         ^      ^   ^
    1    4      11     16        24     29  33

In the initial string "T is the", the letter T is the first and fourth
letters, so those words are added to make "T is the first, fourth".  In
those new words "first, fourth" there are further Ts at 11 and 16, so those
words are added, and so on.

Spaces and punctuation are ignored.  The C<conjunctions> option can ignore
"and" or "et" too.  For non-English languages accents like acutes are
stripped for matching.

It's possible for the sequence to end, since the ordinal names for some
numbers don't have any Ts in them, but in English there doesn't seem to be
enough of those, or the sequence doesn't fall on enough of them.  (Is that
proven?)

=head1 FUNCTIONS

=over

=item C<< $obj = App::MathImage::Math::Aronson->new (key => value, ...) >>

Create and return a new Aronson sequence object.  The following optional
key/value parameters affect the sequence.

=over

=item C<< lang => $string >>, default "en"

The language to use for the sequence.  This can be anything recognised by
C<Lingua::Any::Numbers>.  "en" and "fr" have defaults for the settings
below.

=item C<< initial_string => $str >>, default "T is the" or "E est la"

The initial string for the sequence.  The default is "T is the" for English
or "E est la" for French.  For other languages an C<initial_string> must be
given or the sequence is empty.

=item C<< letter => $str >>, default "T" or "E"

The letter to look for in the words.  The default is the first letter of
C<initial_string>.

=item C<< conjunctions => $boolean >>, default true

Whether to include conjunctions, meaning "and" in the wording, so for
instance "one hundred and four" or "one hundred four".  The default is with
whatever conjunctions C<Lingua::Any::Numbers> gives.

For reference, in Sloane's On-Line Encyclopedia of Integer Sequences the
English sequence A005224 is without conjunctions, but the French one A080520
is with them.

    http://www.research.att.com/%7Enjas/sequences/A005224
    http://www.research.att.com/%7Enjas/sequences/A080520

=item C<< conjunction_word => $string >>, default "and" or "et"

The conjunction word to exclude if C<conjunctions> is true.  The default is
"and" for English or "et" for French.  For other languages there's no
default currently.

=back

=back

=head1 SEE ALSO

L<Lingua::Any::Numbers>

=cut

# =item C<< hi => $integer >>, default C<undef>
# 
# The highest value desired from the sequence object.

