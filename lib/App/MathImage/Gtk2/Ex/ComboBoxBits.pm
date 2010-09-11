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

package App::MathImage::Gtk2::Ex::ComboBoxBits;
use 5.008;
use strict;
use warnings;

use Exporter;
our @ISA = ('Exporter');
our @EXPORT_OK = qw(set_active_text);

our $VERSION = 19;

sub set_active_text {
  my ($combobox, $str) = @_;
  my $n = -1;
  $combobox->get_model->foreach
    (sub {
       my ($model, $path, $iter) = @_;
       if ($str eq $model->get_value ($iter, 0)) {
         ($n) = $path->get_indices;
         return 1; # stop
       }
       return 0; # continue
     });
  $combobox->set_active ($n);
}

1;
__END__

=for stopwords Ryde

=head1 NAME

App::MathImage::Gtk2::Ex::ComboBoxBits -- misc Gtk2::ComboBox helpers

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::ComboBoxBits;

=head1 FUNCTIONS

=over

=item C<< $str = App::MathImage::Gtk2::Ex::ComboBoxBits::set_active_text ($combobox, $text) >>

C<$combobox> must be a simplified "text" type ComboBox.  Set the entry
C<$text> active.

(As of Gtk 2.20 ComboBox has a C<get_active_text>, but no C<set_active_text>
nor a corresponding property.)

=back

=cut
