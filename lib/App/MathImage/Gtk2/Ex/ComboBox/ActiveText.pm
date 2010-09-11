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

package App::MathImage::Gtk2::Ex::ComboBox::ActiveText;
use 5.008;
use strict;
use warnings;
use Carp;
use Gtk2;
use Scalar::Util;
use List::MoreUtils;
use App::MathImage::Gtk2::Ex::ComboBoxBits 'set_active_text';

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 19;

use Glib::Object::Subclass
  'Gtk2::ComboBox',
  signals => { notify => \&_do_notify },
  properties => [ Glib::ParamSpec->string
                  ('active-text',
                   'active-text',
                   'The selected text value.',
                   '',
                   Glib::G_PARAM_READWRITE),
                ];

# Gtk2::ComboBox::new_text creates a Gtk2::ComboBox, must override to get a
# subclass App::MathImage::Gtk2::Ex::ComboBoxBits
# could think about offering this as a ComboBox::Subclass mix-in
sub new_text {
  my ($class) = @_;
  return $class->new;
}

sub INIT_INSTANCE {
  my ($self) = @_;

  # same as gtk_combo_box_new_text(), which alas it doesn't make available
  # for general use
  $self->set_model (Gtk2::ListStore->new ('Glib::String'));
  my $cell = Gtk2::CellRendererText->new;
  $self->pack_start ($cell, 1);
  $self->set_attributes ($cell, text => 0);
}

sub GET_PROPERTY {
  my ($self) = @_;
  ### ActiveText GET_PROPERTY: $pspec->get_name, $newval
  # 'active-text'
  return $self->get_active_text;
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  ### ActiveText SET_PROPERTY: $pspec->get_name, $newval
  # 'active_text'
  $self->set_active_text ($newval);
}

# 'notify' class closure
sub _do_notify {
  my ($self, $pspec) = @_;
  if ($pspec->get_name eq 'active') {
    $self->notify ('active-text');
  }
}

1;
__END__

=for stopwords Gtk Gtk2 combobox ComboBox Gtk programmatically

=head1 NAME

App::MathImage::Gtk2::Ex::ComboBox::ActiveText -- text combobox with "active-text" property

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::ComboBox::ActiveText;
 my $combo = App::MathImage::Gtk2::Ex::ComboBox::ActiveText->new_text;
 $combo->append_text ('First Choice');
 $combo->append_text ('Second Choice');

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::ComboBox::ActiveText> is a subclass of
C<Gtk2::ComboBox>,

    Gtk2::Widget
      Gtk2::Container
        Gtk2::Bin
          Gtk2::ComboBox
            App::MathImage::Gtk2::Ex::ComboBox::ActiveText

=head1 DESCRIPTION

This "text" convenience style C<Gtk2::ComboBox>, adding an C<active-text>
property which is the selected text string.  The property value is the same
as C<get_active_text>, but it can be set too.

=head1 FUNCTIONS

=over 4

=item C<< $combobox = App::MathImage::Gtk2::Ex::ComboBox::ActiveText->new (key=>value,...) >>

Create and return a new ActiveText combobox object.  Optional key/value
pairs set initial properties per C<< Glib::Object->new >>.

    my $combo = App::MathImage::Gtk2::Ex::ComboBox::ActiveText->new;

=back

=head1 PROPERTIES

=over 4

=item C<active-text> (string or C<undef>, default C<undef>)

The text of the selected item, or C<undef> if nothing selected.

=back

=head1 SEE ALSO

L<Gtk2::ComboBox>,
L<App::MathImage::Gtk2::Ex::ComboBoxBits>

=cut
