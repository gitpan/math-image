# Copyright 2007, 2008, 2009, 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

package App::MathImage::Gtk2::Ex::MenuItem::Subclass;
use 5.008;
use Gtk2;
use strict;
use warnings;

# use base 'Exporter';
# our @EXPORT_OK = qw(new new_with_label new_with_mnemonic);
# our %EXPORT_TAGS = (all => \@EXPORT_OK);

# uncomment this to run the ### lines
#use Smart::Comments;


# GtkMenuItem in 2.16 up has "label" and "use-underline" properties which do
# the AccelLabel creation stuff.
#
# For earlier versions must replicate the C code from
#
#     gtk_menu_item_new_with_label()
#     gtk_menu_item_new_with_mnemonic()
# or
#     gtk_check_menu_item_new_with_label()
#     gtk_check_menu_item_new_with_mnemonic()
#
# But using the given $class instead of hard-coding a type as in those C
# funcs.

BEGIN {
  if (Gtk2::MenuItem->find_property('label')) {
    eval "#line ".(__LINE__+1)." \"".__FILE__."\"\n" . <<'HERE' or die;

sub new_with_label {
  my ($class, $str) = @_;
  ### MenuItem-Subclass new_with_label()
  return $class->Glib::Object::new (@_ > 1
                                    ? (label => $str)
                                    : ());
}
sub new_with_mnemonic {
  my ($class, $str) = @_;
  return $class->Glib::Object::new (@_ > 1
                                    ? (label => $str,
                                       use_underline => 1)
                                    : ());
}
1
HERE

  } else {
    eval "#line ".(__LINE__+1)." \"".__FILE__."\"\n" . <<'HERE' or die;
sub new_with_label {
  my ($class, $str) = @_;
  my $self = $class->Glib::Object::new;
  if (@_ > 1) {
    my $label = Gtk2::AccelLabel->new ($str);
    $label->set_alignment (0, 0.5);
    $self->add ($label);
    $label->set_accel_widget ($self);
    $label->show;
  }
  return $self;
}
sub new_with_mnemonic {
  my ($class, $str) = @_;
  my $self = $class->Glib::Object::new;
  if (@_ > 1) {
    my $label = Glib::Object::new ('Gtk2::AccelLabel');
    $label->set_text_with_mnemonic ($str);
    $label->set_alignment (0, 0.5);
    $self->add ($label);
    $label->set_accel_widget ($self);
    $label->show;
  }
  return $self;
}
1
HERE
  }

  *new = \&new_with_mnemonic;
}

1;
__END__

=for stopwords subclassing

=head1 NAME

App::MathImage::Gtk2::Ex::MenuItem::Subclass -- help for subclassing Gtk2::MenuItem

=for test_synopsis our @ISA

=head1 SYNOPSIS

 package My::MenuItem;
 use Glib::Object::Subclass 'Gtk2::MenuItem';

 use App::MathImage::Gtk2::Ex::MenuItem::Subclass;
 unshift @ISA, 'App::MathImage::Gtk2::Ex::MenuItem::Subclass';

 # then in an application
 my $item1 = My::MenuItem->new ('_Foo');
 my $item2 = My::MenuItem->new_with_label ('Bar');
 my $item3 = My::MenuItem->new_with_mnemonic ('_Quux');

=head1 DESCRIPTION

B<This is an internal part of Math-Image and will be moved and renamed if it
has wider use.>

C<App::MathImage::Gtk2::Ex::MenuItem::Subclass> helps subclasses of
C<Gtk2::MenuItem>.  It provides versions of the following class methods

    new
    new_with_label
    new_with_mnemonic

They behave the same as the base C<Gtk2::MenuItem> methods but create a
widget of the given subclass, not merely a C<Gtk2::MenuItem> the way the
wrapped C code methods do.  This is designed as a multiple inheritance
mix-in.  For example,

    package My::MenuItem;
    use Glib::Object::Subclass 'Gtk2::MenuItem',
       signals => { ... },
       properties => [ ... ];

    # prepend to prefer this new() etc
    use App::MathImage::Gtk2::Ex::MenuItem::Subclass;
    unshift @ISA, 'App::MathImage::Gtk2::Ex::MenuItem::Subclass';

Then in application code create a C<My::MenuItem> widget with

    my $item = My::MenuItem->new ('_Foo');

C<$item> is created as a C<My::MenuItem>, as the call would suggest.
Similarly C<new_with_label> and C<new_with_mnemonic>.

The same can be done when subclassing from C<Gtk2::CheckMenuItem> too.

=head2 C<ISA> order

The C<unshift @ISA> above ensures
C<App::MathImage::Gtk2::Ex::MenuItem::Subclass> is before the C<new> from
C<Glib::Object::Subclass> and before the C<new_with_label> and
C<new_with_mnemonic> from C<Gtk2::MenuItem>.  The effect is

    @ISA = ('App::MathImage::Gtk2::Ex::MenuItem::Subclass',
            'Glib::Object::Subclass',
            'Gtk2::MenuItem',
            'Gtk2::Item',
            'Gtk2::Bin',
            ...)

If you want the C<Glib::Object> key/value C<new()> rather than the
label-string one then put C<App::MathImage::Gtk2::Ex::MenuItem::Subclass>
just after C<Glib::Object::Subclass>, like

    # for key/value new() per plain Glib::Object
    @ISA = ('Glib::Object::Subclass',
            'App::MathImage::Gtk2::Ex::MenuItem::Subclass',
            'Gtk2::MenuItem',
            'Gtk2::Item',
            ...)

All C<@ISA> setups are left to the subclassing package because the order can
be important and it's can be confusing if too many C<use> things muck about
with it.

=head1 FUNCTIONS

=over 4

=item C<< $item = $class->new () >>

=item C<< $item = $class->new ($str) >>

Create and return a new menu item widget of C<$class>.  If a C<$str>
argument is given then this behaves as C<new_with_mnemonic> below.

=item C<< $item = $class->new_with_label () >>

=item C<< $item = $class->new_with_label ($str) >>

Create and return a new menu item widget of C<$class>.  If a C<$str>
argument is given then a C<Gtk2::AccelLabel> child is created and added to
display that string.  C<$str> should not be C<undef>.

If there's no C<$str> argument then C<new_with_label> behaves the same as
plain C<new> and doesn't create a child widget.

=item C<< $item = $class->new_with_mnemonic () >>

=item C<< $item = $class->new_with_mnemonic ($str) >>

Create and return a new menu item widget of C<$class>.  If a C<$str>
argument is given then a C<Gtk2::AccelLabel> child is created and added to
display that string.  An underscores in the string becomes an underline and
keyboard shortcut, eg. "_Edit" for underlined "E".  C<$str> should not be
C<undef>.

If there's no C<$str> argument then C<new_with_mnemonic> behaves the same as
plain C<new> and doesn't create a child widget.

=back

When running on Gtk 2.16 and up C<new_with_label> simply sets the C<label>
property and C<new_with_mnemonic> the C<label> and C<use-underline>
properties.  For earlier versions an explicit C<Gtk2::AccelLabel> creation
is done as per past code in C<gtk_menu_item_new_with_label>.

For reference it doesn't work just to re-bless the return from the base
C<new_with_label> and C<new_with_mnemonic> in C<Gtk2::MenuItem>.  Doing so
changes the Perl hierarchy but doesn't change the underlying C code widget
C<GType> and therefore doesn't get new properties or signals from the
subclass.

=head1 OTHER WAYS TO DO IT

When running on Gtk 2.16 the C<label> property means there's no particular
need for a separate C<new_with_label> method, simply pass the string as an
argument in the usual key/value C<new> you get from
C<Glib::Object::Subclass>.

    package My::MenuItem;
    use Glib::Object::Subclass 'Gtk2::MenuItem';

    # then in the application
    my $item = My::MenuItem->new (label => 'Hello');

The benefit of C<App::MathImage::Gtk2::Ex::MenuItem::Subclass> is that you
don't leave exposed a C<new_with_label> which does the wrong thing, and can
work on Gtk prior to 2.16.

=head1 SEE ALSO

C<Gtk2::MenuItem>, C<Glib::Object::Subclass>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
