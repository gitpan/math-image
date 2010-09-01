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

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 18;

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

sub new_text {
  my ($class) = @_;
  return $class->new;
}

sub INIT_INSTANCE {
  my ($self) = @_;
  $self->set_model (Gtk2::ListStore->new ('Glib::String'));
  my $cell = Gtk2::CellRendererText->new;
  $self->pack_start ($cell, 1);
  $self->set_attributes ($cell, text => 0);
}

sub GET_PROPERTY {
  my ($self) = @_;
  return $self->get_active_text;
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  ### ActiveText SET_PROPERTY: $pname, $newval

  my $model = $self->get_model;
  my $n = -1;
  $model->foreach
    (sub {
       my ($model, $path, $iter) = @_;
       if ($newval eq $model->get_value ($iter, 0)) {
         ($n) = $path->get_indices;
         return 1; # stop
       }
       return 0; # continue
     });
  $self->set_active ($n);
}

# 'changed' class closure
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

=head1 FUNCTIONS

=over 4

=item C<< $combobox = App::MathImage::Gtk2::Ex::ComboBox::ActiveText->new (key=>value,...) >>

Create and return a new C<ActiveText> combobox object.  Optional key/value
pairs set initial properties per C<< Glib::Object->new >>.

    my $combo = App::MathImage::Gtk2::Ex::ComboBox::ActiveText->new;

=back

=head1 PROPERTIES

=over 4

=item C<active-text> (string or undef, default C<undef>)

The text of the selected enum value.

=back

=head1 SEE ALSO

L<Gtk2::ComboBox>,
L<App::MathImage::Glib::Ex::EnumBits>

=cut
