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


# go to no extension when combobox nothing selected ...


package App::MathImage::Gtk2::SaveDialog;
use 5.008;
use strict;
use warnings;
use Text::Capitalize;
use File::Spec;
use List::Util;
use Gtk2;
use Gtk2::Ex::Units;
use Glib::Ex::ObjectBits;
use Glib::Ex::SignalIds;
use Glib::Ex::ConnectProperties 11; # version 11 for widget-allocation
use Gtk2::Ex::ComboBox::PixbufType;
use Locale::TextDomain ('App-MathImage');

use App::MathImage::Gtk2::Drawing;
use App::MathImage::Gtk2::Ex::GdkPixbufBits;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 36;

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

# get_widget_for_response() new in gtk 2.20
my $get_widget_for_response = Gtk2::Dialog->can('get_widget_for_response')
  || sub {
    my ($dialog, $id) = @_;
    return List::Util::first {$dialog->get_response_for_widget($_) eq $id}
      $dialog->get_action_area->get_children;
  };

sub new {
  my $class = shift;
  # pending support for object "constructor" thingie
  $class->SUPER::new (action => 'save', @_);
}

sub INIT_INSTANCE {
  my ($self) = @_;
  $self->set (destroy_with_parent => 1);

  { my $title = __('Save Image');
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

    my $combo = $self->{'combo'} = Gtk2::Ex::ComboBox::PixbufType->new
      (active_type => 'png');
    Glib::Ex::ObjectBits::set_property_maybe
        ($combo,
         # tooltip-text new in Gtk 2.12
         tooltip_text => __('The file format to save in.
This is all the GdkPixbuf formats with "write" support.

PNG and TIFF compress well.
JPEG and BMP tend to be a bit bloated.
ICO only goes up to 255x255 pixels.'));

    $combo->signal_connect ('notify::active' => \&_combo_notify_active);
    $hbox->pack_start ($combo, 0,0,0);
    $hbox->show_all;

    my $type = $combo->get('active-type');
    if (my $info = _get_format_from_type($type)) {
      $self->{'old_extensions'} = $info->{'extensions'};
    }

    # no Save if no active type
    Glib::Ex::ConnectProperties->new
        ([$combo, 'active-type'],
         [$self->$get_widget_for_response('accept'), 'sensitive',
          write_only => 1]);
  }
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  $self->{$pname} = $newval;

  if ($pname eq 'draw') {
    # this doesn't work in INIT_INSTANCE :-(
    $self->set (action => 'save');

    my $draw = $newval;
    my $scale  = $draw->get('scale');
    $self->set_current_name
      ($draw->get('values')
       . '-' . $draw->get('path')
       . '-' . $draw->allocation->width .'x'.$draw->allocation->height
       . ($scale != 1 ? "-s$scale" : '')
       . '.' . $self->{'combo'}->get('active-type'));

    #     $self->{'draw_ids'} = Glib::Ex::SignalIds->new
    #       ($draw,
    #        $draw->signal_connect (size_allocate => sub {
    #                                 my ($draw, $alloc) = @_;
    #                                 $self->{'combo'}->set (for_width => $alloc->width,
    #                                                        for_height => $alloc->height);
    #                               }));

    $self->{'draw_connections'} = $draw
      && [ Glib::Ex::ConnectProperties->dynamic
           ([$draw,            'widget-allocation#width'],
            [$self->{'combo'}, 'for-width']),
           Glib::Ex::ConnectProperties->dynamic
           ([$draw,            'widget-allocation#height'],
            [$self->{'combo'}, 'for-height']),
         ];
  }
}

sub _do_response {
  my ($self, $response) = @_;
  ### MathImage-SaveDialog response: $response

  if ($response eq 'accept') {
    $self->save;

  } elsif ($response eq 'cancel') {
    # raise 'close' as per a keyboard Esc to close, which defaults to
    # raising 'delete-event', which is setup as a hide() above
    $self->signal_emit ('close');
  }
}

# PNG spec 11.3.4.2 suggests RFC822 (or rather RFC1123) for CreationTime
use constant STRFTIME_FORMAT_RFC822 => '%a, %d %b %Y %H:%M:%S %z';

sub save {
  my ($self) = @_;
  ### Math-Image-SaveDialog save()

  my $filename = $self->get_filename;
  # Gtk2-Perl 1.200 $chooser->get_filename gives back wide chars (where it
  # almost certainly should be bytes)
  if (utf8::is_utf8($filename)) {
    $filename = Glib->filename_from_unicode ($filename);
  }
  ### $filename

  my $combo = $self->{'combo'};
  my $type = $combo->get('active-type');

  my $draw = $self->get('draw');
  my $pixmap = $draw->pixmap;
  my $pixbuf = Gtk2::Gdk::Pixbuf->get_from_drawable ($pixmap,
                                                     undef, # colormap
                                                     0,0, 0,0,
                                                     $pixmap->get_size);
  my $values = $draw->get('values');
  if ($values eq 'Fraction' || $values eq 'Expression'
      || $values eq 'Polygonal' || $values eq 'Multiples'
      || $values eq 'SqrtBits') {
    my $pname = lc($values);
    $pname =~ s/bits$//;
    $values .= ' '.$draw->get($pname);
  }

  my $path = $draw->get('path');
  # my $scale = $draw->get('scale');
  my $title = __x('{values} drawn as {path}',
                  values => Text::Capitalize::capitalize($values),
                  path   => Text::Capitalize::capitalize($path));
  if (eval {
    App::MathImage::Gtk2::Ex::GdkPixbufBits::save
        ($pixbuf, $filename, $type,
         'tEXt::Title'         => $title,
         'tEXt::Creation Time' => POSIX::strftime (STRFTIME_FORMAT_RFC822,
                                                   localtime(time)),
         # 'tEXt::Description'   => '',
         'tEXt::Software'      => "Math-Image, http://user42.tuxfamily.org/math-image/index.html",
         zlib_compression      => 9,
         tiff_compression_type => 'deflate',
         quality_percent       => 100);
    1 }) {
    # success
    $self->hide;
  } else {
    # failure
    my $err = $@;
    # This die() message here might be an unholy amalgam of filename
    # charset $filename, and utf8 Glib::Error.  It probably occurs in many
    # other libraries too, and you're probably asking for trouble if your
    # filename and locale charsets are different, so leave it as just this
    # simple combination for now.
    my $dialog = Gtk2::MessageDialog->new
      ($self,
       ['modal','destroy-with-parent'], # GtkDialogFlags
       'error', # GtkMessageType
       'ok',    # GtkButtonsType
       __x("Cannot save {filename}:\n\n{error}",
           filename => Glib::filename_display_name($filename),
           error    => "$err"));  # Glib::Error
    $dialog->signal_connect (response => \&_message_dialog_response);
    $dialog->present;
  }
}

sub _message_dialog_response {
  my ($dialog) = @_;
  $dialog->destroy;
}

# type combobox 'active' signal handler
sub _combo_notify_active {
  my ($combo) = @_;
  my $self = $combo->get_ancestor(__PACKAGE__);
  my $type = $combo->get('active-type');
  my $info = _get_format_from_type($type) || return; # oops, unknown

  _change_extension ($self,
                     $self->{'old_extensions'} || [],
                     $info->{'extensions'});
  $self->{'old_extensions'} = $info->{'extensions'};
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
sub _change_extension {
  my ($chooser, $old_aref, $new_aref, $case_sensitive) = @_;
  ### _change_extension(): $chooser->get_filename
  ### $old_aref
  ### $new_aref

  # get_filename() undef initially
  my $fullname = $chooser->get_filename;
  if (! defined $fullname) { return; }
  my ($volume, $directories, $filename) = File::Spec->splitpath ($fullname);

  if (defined (_filename_has_extension($filename, $new_aref,
                                       $case_sensitive))) {
    # already have one of the new extensions
    return;
  }
  if (my ($basename) = _filename_has_extension($filename, $old_aref,
                                               $case_sensitive)) {
    # found one of the old extensions to change
    my $new_ext = $new_aref->[0];
    $new_ext =~ s/^([^.])/.$1/;  # "txt" -> ".txt"
    $filename = $basename . $new_ext;
    $chooser->set_current_folder (File::Spec->catdir ($volume, $directories));
    $chooser->set_current_name ($filename);
  }
}

sub _filename_has_extension {
  my ($filename, $aref, $case_sensitive) = @_;
  ### _filename_has_extension()
  ### $filename
  ### $aref
  foreach my $ext (@$aref) {
    $ext =~ s/^([^.])/.$1/;  # "txt" -> ".txt"
    if ($filename =~ ($case_sensitive
                      ? qr/(.*)\Q$ext\E$/ : qr/(.*)\Q$ext\E$/i)) {
      ### yes: $1
      return $1;
    }
  }
  ### no
  return;
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
