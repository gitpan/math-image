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


package App::MathImage::Gtk2::SaveDialog;
use 5.008;
use strict;
use warnings;
use Text::Capitalize;
use File::Spec;
use List::Util;
use Gtk2;
use Gtk2::Ex::Units;
use App::MathImage::Gtk2::Drawing;
use App::MathImage::Gtk2::Ex::GdkPixbufBits;
use App::MathImage::Gtk2::Ex::GdkPixbuf::TypeComboBox;
use Locale::TextDomain ('App-MathImage');

our $VERSION = 13;

use Glib::Object::Subclass
  'Gtk2::FileChooserDialog',
  signals => { delete_event => \&Gtk2::Widget::hide_on_delete },
  properties => [ Glib::ParamSpec->object
                  ('draw',
                   'draw',
                   'Blurb.',
                   'App::MathImage::Gtk2::Drawing',
                   Glib::G_PARAM_READWRITE),
                ];

sub INIT_INSTANCE {
  my ($self) = @_;
  $self->set (destroy_with_parent => 1);

  {
    my $title = __('Save Image');
    if (defined (my $appname = Glib::get_application_name())) {
      $title = "$appname: $title";
    }
    $self->set_title ($title);
  }
  $self->add_buttons ('gtk-save'   => 'accept',
                      'gtk-cancel' => 'cancel');

  # connect to self instead of a class handler since as of Gtk2-Perl 1.200 a
  # Gtk2::Dialog class handler for 'response' is called with response IDs as
  # numbers, not enum strings like 'accept'
  $self->signal_connect (response => \&_do_response);

  my $vbox = $self->vbox;

  {
    my $label = Gtk2::Label->new (__('Save image to file'));
    $label->show;
    $vbox->pack_start ($label, 0,0,0);
    $vbox->reorder_child ($label, 0); # at the top of the dialog
  }
  {
    my $hbox = Gtk2::HBox->new;
    $vbox->pack_start ($hbox, 0,0,0);
    $vbox->reorder_child ($hbox, 1); # below label

    my $label = Gtk2::Label->new(__('File Format'));
    $hbox->pack_start ($label, 0,0, Gtk2::Ex::Units::em($label));

    my $combo = $self->{'combo'}
      = App::MathImage::Gtk2::Ex::GdkPixbuf::TypeComboBox->new;
    if ($combo->can('set_tooltip_text')) { # new in 2.12
      $combo->set_tooltip_text(__("The file format to save in.\n(This is all the GdkPixbuf formats with \"write\" support.)"));
    }
    $combo->signal_connect ('notify::active' => \&_combo_notify_active);
    $hbox->pack_start ($combo, 0,0,0);
    $hbox->show_all;
  }
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  $self->{$pname} = $newval;

  if ($pname eq 'draw') {
    $self->set (action => 'save');
    my $draw = $newval;
    my $scale  = $draw->get('scale');
    $self->set_current_name
      ($draw->get('values')
       . '-' . $draw->get('path')
       . '-' . $draw->allocation->width .'x'.$draw->allocation->height
       . ($scale != 1 ? "-s$scale" : '')
       . '.' . $self->{'combo'}->get('type'));
  }
}

sub _do_response {
  my ($self, $response) = @_;
  ### MathImage-SaveDialog response: $response

  if ($response eq 'accept') {
    $self->save;

  } elsif ($response eq 'cancel') {
    # raise 'close' as per a keyboard Esc to close, which defaults to
    # raising 'delete-event', which in turn defaults to a destroy
    $self->signal_emit ('close');
  }
}

# PNG spec 11.3.4.2 suggests RFC822 (or rather RFC1123) for CreationTime
use constant STRFTIME_FORMAT_RFC822 => '%a, %d %b %Y %H:%M:%S %z';

sub save {
  my ($self) = @_;
  ### Math-Image-SaveDialog save()
  $self->hide;

  my $filename = $self->get_filename;
  # Gtk2-Perl 1.200 $chooser->get_filename gives back wide chars (where it
  # almost certainly should be bytes)
  if (utf8::is_utf8($filename)) {
    $filename = Glib->filename_from_unicode ($filename);
  }
  ### $filename

  my $combo = $self->{'combo'};
  my $format = $combo->get('type');

  my $draw = $self->get('draw');
  my $pixmap = $draw->pixmap;
  my $pixbuf = Gtk2::Gdk::Pixbuf->get_from_drawable ($pixmap,
                                                     undef, # colormap
                                                     0,0, 0,0,
                                                     $pixmap->get_size);
  my $values = $draw->get('values');
  if ($values eq 'fraction' || $values eq 'expression' || $values eq 'sqrt'
      || $values eq 'polygonal' || $values eq 'multiples') {
    $values .= ' '.$draw->get($values);
  }
  my $path = $draw->get('path');
  my $scale = $draw->get('scale');
  my $title = __x('{values} drawn as {path}',
                  values => Text::Capitalize::capitalize($values),
                  path   => Text::Capitalize::capitalize($path));
  eval {
    $pixbuf->save
      ($filename, $format,
       App::MathImage::Gtk2::Ex::GdkPixbufBits::save_options
       ($format,
        'tEXt::Title'         => $title,
        'tEXt::Creation Time' => POSIX::strftime (STRFTIME_FORMAT_RFC822,
                                                  localtime(time)),
        # 'tEXt::Description'   => '',
        'tEXt::Software'      => "math-image, http://user42.tuxfamily.org/math-image/index.html",
        zlib_compression      => 9,
        tiff_compression_type => 'deflate',
        quality_percent       => 100));
    1;
  } or do {
    # This die() message here might be an unholy amalgam of filename
    # charset $filename, and utf8 Glib::Error.  It probably occurs in many
    # other libraries too, and you're probably asking for trouble if your
    # filename and locale charsets are different, so leave it as just this
    # simple combination for now.
    die "Cannot write $filename: $@";
  };
}

# type combobox 'active' signal handler
sub _combo_notify_active {
  my ($combo) = @_;
  my $self = $combo->get_ancestor(__PACKAGE__);
  my $type = $combo->get('type');
  my $info = _get_format_from_type($type) || return; # oops, unknown
  _set_extension ($self, $info->{'extensions'}->[0] || '');
}

# Set the ".xyz" extension part of the filename in $chooser.
# $ext can be for instance ".txt", "txt", or empty "".
# If $case_sensitive is true then $ext and any extension in the current
# filename are compared case-sensitively before changing.
#
# The extension on the current filename is taken to be any ".abcde" of 0 to
# 5 characters.  If there's other dots in the name and no ".txt" or whatever
# then a part of the name as such might be replaced.
#
# Is there a $chooser->get_current for the user entered part?
#
sub _set_extension {
  my ($chooser, $ext, $case_sensitive) = @_;
  unless ($ext =~ /^(\.|$)/) {
    $ext = ".$ext";
  }
  my $filename = $chooser->get_filename;
  if ($filename =~ ($case_sensitive ? qr/\Q$ext\E$/ : qr/\Q$ext\E$/i)) {
    return; # already right
  }
  (my $volume,my $directories, $filename) = File::Spec->splitpath($filename);
  $filename =~ s/\.[^.]{0,5}$/$ext/;
  $chooser->set_current_folder ($directories);
  $chooser->set_current_name ($filename);
}

my $get_formats_method;
BEGIN {
  $get_formats_method = (Gtk2::Gdk::Pixbuf->can('get_formats') # new in Gtk 2.2
                         ? 'get_formats'
                         : sub { return () }); # empty list
}
sub _get_format_from_type {
  my ($type) = @_;
  return List::Util::first
    {$_->{'name'} eq $type}
      Gtk2::Gdk::Pixbuf->$get_formats_method;
}

1;
__END__
