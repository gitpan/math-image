# Copyright 2010, 2011 Kevin Ryde

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

package App::MathImage::Gtk2::PodDialog;
use 5.008;
use strict;
use warnings;
use FindBin;
use Glib 1.220; # for Glib::SOURCE_REMOVE and probably more
use Gtk2 1.200; # for Gtk2::GTK_PRIORITY_RESIZE and probably more
use Gtk2::Ex::PodViewer;
use Gtk2::Ex::WidgetCursor;
use Gtk2::Ex::Units;
use Locale::TextDomain ('Math-Image');

use App::MathImage::Generator;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 50;

use Glib::Object::Subclass 'Gtk2::Dialog';

sub INIT_INSTANCE {
  my ($self) = @_;

  {
    my $title = __('POD Documentation');
    if (defined (my $appname = Glib::get_application_name())) {
      $title = "$appname: $title";
    }
    $self->set_title ($title);
  }

  # connect to self instead of a class handler since as of Gtk2-Perl 1.200 a
  # Gtk2::Dialog class handler for 'response' is called with response IDs as
  # numbers, not enum strings like 'accept'
  $self->signal_connect (response => \&_do_response);

  my $vbox = $self->vbox;

  my $combobox = $self->{'combobox'} = Gtk2::ComboBox->new_text;
  $combobox->append_text ($FindBin::Script);
  foreach my $name (App::MathImage::Generator->path_choices) {
    $combobox->append_text ($name);
  }
  $combobox->append_text ('Math::Aronson');
  $combobox->append_text ('Math::Symbolic');
  $combobox->append_text ('Math::Expression::Evaluator');
  $combobox->set_active (0);
  $combobox->signal_connect (changed => \&_do_combo_changed);
  my $action_hbox = $self->get_action_area;
  $action_hbox->pack_start ($combobox, 0,0,0);

  $self->add_buttons ('gtk-close' => 'cancel');

  my $scrolled = Gtk2::ScrolledWindow->new;
  $scrolled->set_policy ('never', 'always');
  $vbox->pack_start ($scrolled, 1,1,0);

  my $viewer = $self->{'viewer'} = Gtk2::Ex::PodViewer->new;
  $viewer->signal_connect (link_clicked => \&_do_viewer_link_clicked);
  $scrolled->add ($viewer);

  Gtk2::Ex::Units::set_default_size_with_subsizes
      ($self, [ $vbox, '60 ems', '35 lines' ]);
  $self->show_all;
  ### default size: $self->get_default_size

  # WidgetCursor doesn't work due to explicit set_cursor() in PodViewer
  $self->{'cursor'} = Gtk2::Ex::WidgetCursor->new (widget => $self,
                                                   cursor => 'watch',
                                                   include_children => 1,
                                                   priority => 10,
                                                   active => 1);
  Scalar::Util::weaken (my $weak_self = $self);
  Glib::Idle->add (\&_do_idle, \$weak_self,
                   Gtk2::GTK_PRIORITY_RESIZE() + 10);  # low priority
  #   Glib::Timeout->add (3000, \&_do_idle, \$weak_self,
  #                       Gtk2::GTK_PRIORITY_RESIZE() + 10);
}

sub _do_idle {
  my ($ref_weak_self) = @_;
  if (my $self = $$ref_weak_self) {
    _do_combo_changed ($self->{'combobox'});
    delete $self->{'cursor'};
  }
  return Glib::SOURCE_REMOVE; # once only
}

sub _do_response {
  my ($self, $response) = @_;

  if ($response eq 'cancel') {
    # "Close" button gives GTK_RESPONSE_CANCEL.
    # Emit 'close' same as a keyboard Esc to close, and that signal defaults
    # to raising 'delete-event', which in turn defaults to a destroy
    $self->signal_emit ('close');
  }
}

sub _do_combo_changed {
  my ($combobox) = @_;
  my $self = $combobox->get_ancestor(__PACKAGE__) || return;

  my $filename;
  my $name = $combobox->get_active_text;
  $name =~ s/-/::/g;
  if ($combobox->get_active == 0) {
    $filename = "$FindBin::Bin/$name";
  } elsif ($name =~ /::/) {
    $filename = Module::Util::find_installed ($name);
  } else {
    $filename = Module::Util::find_installed ("Math::PlanePath::$name");
  }
  ### $filename
  my $viewer = $self->{'viewer'};
  if (! (defined $filename
         && defined ($viewer->load_file ($filename)) # successful load
         && $viewer->get_buffer->get_char_count)) {  # and not empty
    _empty ($viewer, $name);
  }
}

sub _do_viewer_link_clicked {
  my ($viewer, $target) = @_;
  ### _do_viewer_link_clicked(): $target

  Gtk2::Ex::WidgetCursor->busy;
  ($target, my $section) = split(/\//, $target, 2);
  if ($target) {
    my $loaded;
    if (eval { require Pod::Simple::Search }
        && (my $filename = Pod::Simple::Search->new->find($target))) {
      $loaded = $viewer->load_file ($filename);
    } else {
      $loaded = $viewer->load ($target);
    }
    (defined $loaded
     && $viewer->get_buffer->get_char_count)
      or _empty ($viewer, $target);
  }

  $section = lc($section);
  foreach my $mark_name ($viewer->get_marks) {
    ### $mark_name
    $mark_name =~ s/^[\"\']|[\"\']$//g; # no quotes
    if (lc($mark_name) eq $section) {
      $viewer->scroll_to_mark ($viewer->get_mark ($mark_name),
                               0,     # within_margin
                               1,     # use_align
                               0,     # xalign, left of window
                               .05);  # yalign, just below top of screen
      last;
    }
  }
}

sub _empty {
  my ($viewer, $target) = @_;
  my $textbuf = $viewer->get_buffer;
  $textbuf->delete ($textbuf->get_start_iter, $textbuf->get_end_iter);
  $textbuf->insert ($textbuf->get_start_iter,
                    __x("Nothing for {target}\n", target => $target));
}

1;
__END__

=for stopwords PodDialog

=head1 NAME

App::MathImage::Gtk2::PodDialog -- program POD dialog

=head1 SYNOPSIS

 use App::MathImage::Gtk2::PodDialog;

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::PodDialog> is a subclass of C<Gtk2::Dialog>.

    Gtk2::Widget
      Gtk2::Container
        Gtk2::Bin
          Gtk2::Window
            Gtk2::Dialog
              App::MathImage::Gtk2::PodDialog

=head1 SEE ALSO

L<Gtk2::Dialog>

=cut
