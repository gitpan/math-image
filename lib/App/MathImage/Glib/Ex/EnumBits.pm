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
our @EXPORT_OK = qw(to_display);

our $VERSION = 14;

sub to_display {
  my ($enum_class, $nick) = @_;
  if (@_ < 2) {
    croak "Not enough arguments for EnumBits to_display()";
  }
  if (my $subr = $enum_class->can('to_display')) {
    return $enum_class->$subr($nick);
  }
  my $str = nick_to_display ($nick);
  if (defined (my $textdomain = do { no strict 'refs';
                                    ${"${enum_class}::TEXTDOMAIN"} })
      && Locale::Messages->can('dgettext')) {
    $str = Locale::Messages::dgettext ($textdomain, $str);
  }
  return $str;
}

sub nick_to_display {
  my ($nick) = @_;
  return join (' ',
               map {ucfirst}
               split(/[-_ ]+
                    |(?<=\D)(?=\d)
                    |(?<=\d)(?=\D)
                    |(?<=[[:lower:]])(?=[[:upper:]])
                     /x, $nick));
}

sub to_description {
  my ($enum_class, $nick) = @_;
  if (@_ < 2) {
    croak "Not enough arguments for EnumBits to_description()";
  }
  if (my $subr = $enum_class->can('to_description')) {
    return $enum_class->$subr($nick);
  } else {
    return undef;
  }
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

=for stopwords Ryde Enum Glib

=head1 NAME

App::MathImage::Glib::Ex::EnumBits -- misc enum helpers

=head1 SYNOPSIS

 use App::MathImage::Glib::Ex::EnumBits;

=cut
