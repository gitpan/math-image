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
$VERSION = 15;

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
    if ($lang eq 'en') {
      %$self = (letter => 't',
                initial_string => 't is the',
                conjunction_word => 'and',
                %$self);
    } elsif ($lang eq 'fr') {
      %$self = (letter => 'e',
                initial_string => 'e est la',
                conjunction_word => 'et',
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

  my $letter = $self->{'letter'} = lc($self->{'letter'});

  my $str = delete $self->{'initial_string'};
  if (! defined $str) {
    croak 'No initial_string';
  }
  &$conjunctions_func ($str);
  &$unaccent ($str);
  $str = lc ($str);
  $str =~ tr/a-z//cd;
  ### $str
  my $upto = 1;
  my $pos = 0;
  while (($pos = index($str,$letter,$pos)) >= 0) {
    push @ret, $pos++ + $upto;
  }
  $self->{'upto'} = $upto + length($str);

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

Aronson's sequence is a recurrence generated from positions of the letter T
in numbers expressed in words.

    T is the first, fourth, eleventh, sixteenth, ...
    ^    ^       ^      ^         ^      ^   ^
    1    4      11     16        24     29  33

In the starting "T is the", the letter T is the first and fourth letters, so
those words are added to make "T is the first, fourth".  In those new words
"first, fourth" there are further Ts at 11 and 16, so those words are added,
and so on.

Spaces and punctuation are ignored.  It's possible for the sequence to end,
since the ordinal names for some numbers don't have any Ts in them, but in
English there doesn't seem to be enough of them, or the sequence doesn't
fall on enough of them, to end.  (Is that proven?)

On reaching 104 there's a choice whether to write that as "one hundred and
four" or just "one hundred four".  The default is to include the "and", but
there's an option below to try it without.

=head1 FUNCTIONS

=over

=item C<< $obj = App::MathImage::Math::Aronson->new (key => value, ...) >>

Create and return a new Aronson sequence object.  The following optional
key/value parameters affect the sequence.

=item C<< conjunctions => $boolean >>, default true

Whether to include conjunctions, meaning "and" in the wording.  The default
is to do so.

=item C<< hi => $integer >>, default C<undef>

The highest value desired from the sequence object.

=back

=cut
