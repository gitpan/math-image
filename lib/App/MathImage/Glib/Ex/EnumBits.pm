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

package App::MathImage::Glib::Ex::EnumBits;
use 5.008;
use strict;
use warnings;
use Carp;

# uncomment this to run the ### lines
#use Smart::Comments;

use Exporter;
our @ISA = ('Exporter');
our @EXPORT_OK = qw(to_text
                    to_text_default
                    to_description);

our $VERSION = 15;

sub to_text {
  my ($enum_class, $nick) = @_;
  if (@_ < 2) {
    croak "Not enough arguments for EnumBits to_text()";
  }
  if (my $subr = $enum_class->can('to_text')) {
    return $enum_class->$subr($nick);
  }
  return to_text_default ($enum_class, $nick);
}

sub to_text_default {
  my ($enum_class, $nick) = @_;
  if (@_ < 2) {
    croak "Not enough arguments for EnumBits to_text_default()";
  }
  my $str = join (' ',
                  map {ucfirst}
                  split(/[-_ ]+
                       |(?<=\D)(?=\d)
                       |(?<=\d)(?=\D)
                       |(?<=[[:lower:]])(?=[[:upper:]])
                        /x,
                        $nick));
  if (defined $enum_class
      && defined (my $textdomain = do { no strict 'refs';
                                        ${"${enum_class}::TEXTDOMAIN"} })
      && Locale::Messages->can('dgettext')) {
    $str = Locale::Messages::dgettext ($textdomain, $str);
  }
  return $str;
}

sub to_description {
  my ($enum_class, $nick) = @_;
  if (@_ < 2) {
    croak "Not enough arguments for EnumBits to_description()";
  }
  if (my $subr = $enum_class->can('to_description')) {
    return $enum_class->$subr($nick);
  }
  return undef;
}

1;
__END__

# # cf g_enum_get_value_by_name() and g_enum_get_value_by_nick()
# sub to_nick {
#   my ($enum_class, $value) = @_;
#   if (my $h = to_info ($enum_class, $value)) {
#     return $h->{'nick'};
#   } else {
#     return undef;
#   }
# }
# 
# sub to_info {
#   my ($enum_class, $value) = @_;
#   my @info = Glib::Type->list_values($enum_class);
#   foreach my $h (@info) {
#     if ($value eq $h->{'name'}
#         || $value eq $h->{'nick'}) {
#       return $h;
#     }
#   }
#   if (looks_like_number($value)) {
#     foreach my $h (@info) {
#       if ($value == $h->{'value'}) {
#         return $h;
#       }
#     }
#   }
#   return undef;
# }

=for stopwords Ryde enum Enum Glib

=head1 NAME

App::MathImage::Glib::Ex::EnumBits -- misc enum helpers

=head1 SYNOPSIS

 use App::MathImage::Glib::Ex::EnumBits;

=head1 FUNCTIONS

=over

=item << App::MathImage::Glib::Ex::EnumBits::to_text ($enum_class, $nick) >>

Return a text form of value C<$nick> from C<$enum_class>.  This is meant to
be suitable for display in a menu, label, etc.

C<$enum_class> is a string like C<"Glib::UserDirectory">.  If it has a
C<< $enum_class->to_text ($nick) >> method then that's called, otherwise the
C<$nick> string is manipulated to turn for instance C<public-share> into
"Public Share".

=back

=head1 SEE ALSO

L<Glib>,
L<Glib::Type>

=cut
