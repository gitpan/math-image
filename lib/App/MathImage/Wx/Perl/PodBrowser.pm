# Copyright 2011, 2012 Kevin Ryde

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


package App::MathImage::Wx::Perl::PodBrowser;
use strict;
use Carp;
use Wx;
use Wx::Event 'EVT_MENU';
use App::MathImage::Wx::Perl::PodRichText;

use base qw(Wx::Frame);

# uncomment this to run the ### lines
#use Smart::Comments;


our $VERSION = 100;

sub new {
  my ($class, $parent, $id, $title, @rest) = @_;
  if (! defined $id) { $id = Wx::wxID_ANY(); }
  if (! defined $title) { $title = Wx::gettext('POD Browser'); }
  my $self = $class->SUPER::new ($parent, $id, $title, @rest);
  $self->{'url_message'} = '';

  # load an icon and set it as frame icon
  $self->SetIcon (Wx::GetWxPerlIcon());

  my $menubar = Wx::MenuBar->new;
  $self->SetMenuBar ($menubar);

  {
    my $menu = Wx::Menu->new;
    $menubar->Append ($menu, Wx::gettext('&File'));

    {
      my $item = $menu->Append (Wx::wxID_ANY(),
                                Wx::gettext("Open &Module"),
                                Wx::gettext('Open a Perl module POD.'));
      EVT_MENU ($self, $item, 'popup_module_dialog');
    }
    {
      my $item = $menu->Append (Wx::wxID_ANY(),
                                Wx::gettext("&Open File"),
                                Wx::gettext('Open a POD file.'));
      EVT_MENU ($self, $item, 'popup_file_dialog');
    }
    {
      my $item
        = $self->{'go_back_menuitem'}
          = $menu->Append (Wx::wxID_ANY(),
                           Wx::gettext("&Back\tCtrl-B"),
                           Wx::gettext('Go back to the previous POD.'));
      EVT_MENU ($self, $item, 'go_back');
    }
    {
      my $item
        = $self->{'go_forward_menuitem'}
          = $menu->Append (Wx::wxID_ANY(),
                           Wx::gettext("&Forward\tCtrl-F"),
                           Wx::gettext('Go forward again.'));
      EVT_MENU ($self, $item, 'go_forward');
    }
    {
      my $item
        = $self->{'reload_menuitem'}
          = $menu->Append (Wx::wxID_ANY(),
                           Wx::gettext("&Reload"),
                           Wx::gettext('Re-read the POD file.'));
      EVT_MENU ($self, $item, 'reload');
    }
    $menu->Append(Wx::wxID_EXIT(),
                  '',
                  Wx::gettext('Close this window'));
    EVT_MENU ($self, Wx::wxID_EXIT(), 'quit');
  }
  {
    my $menu = $self->{'section_menu'} = Wx::Menu->new;
    my $label = $self->{'section_menu_label'} = Wx::gettext('&Section');
    $menubar->Append ($menu, $label);
  }
  {
    my $menu = $self->{'help_menu'} = Wx::Menu->new (Wx::gettext('Help'));
    $menubar->Append ($menu, Wx::gettext('&Help'));

    $menu->Append (Wx::wxID_ABOUT(),
                   '',
                   Wx::gettext('Show about dialog'));
    EVT_MENU ($self, Wx::wxID_ABOUT(), 'popup_about');

    {
      my $item = $menu->Append (Wx::wxID_ANY(),
                                Wx::gettext('&POD Browser POD'),
                                Wx::gettext('Show the values POD'));
      EVT_MENU ($self, $item, 'goto_own_pod');
    }
  }

  $self->CreateStatusBar;

  my $podtext
    = $self->{'podtext'}
      = App::MathImage::Wx::Perl::PodRichText->new ($self);
  $podtext->SetFocus;
  Wx::Event::EVT_MOTION ($podtext, \&mouse_motion);
  Wx::Event::EVT_ENTER_WINDOW ($podtext, \&mouse_motion);
  Wx::Event::EVT_LEAVE_WINDOW ($podtext, \&mouse_leave);
  App::MathImage::Wx::Perl::PodRichText::EVT_PERL_PODRICHTEXT_CHANGED
      ($self, $podtext, \&OnPodChanged);

  $self->SetSize ($self->GetBestSize);
  _history_changed($self);  # initial insensitive
  _update_sections($self);  # initial insensitive

  return $self;
}

sub popup_module_dialog {
  my ($self) = @_;
  # ENHANCE-ME: non-modal
  my $module = Wx::GetTextFromUser(Wx::gettext('Enter POD module name'),
                                   Wx::gettext('POD module'),
                                   '',     # default
                                   $self); # parent
  if (defined $module) {
    $module =~ s/^\s+//; # whitespace
    $module =~ s/\s+$//;
    if ($module ne '') {
      $self->goto_pod (module => $module);
    }
  }
}

sub popup_file_dialog {
  my ($self) = @_;
  require Cwd;

  # ENHANCE-ME: non-modal
  my $filename = Wx::FileSelector
    (Wx::gettext('Choose a POD file'),
     Cwd::getcwd(), # default dir
     '',            # default filename
     '',            # default extension
     'Perl files (pod,pm,pl)|*.pod;*.pm;*.pl|All files|*',
     (Wx::wxFD_OPEN()
      | Wx::wxFD_FILE_MUST_EXIST()
      | Wx::wxSTAY_ON_TOP()),
     $self,
    );
  ### $filename
  $self->goto_pod (filename => $filename);

  # my $dialog = ($self->{'file_dialog'} ||= Wx::FileDialog->new
  #               ($self,
  #                Wx::gettext('Choose a POD file'),
  #                Cwd::getcwd(), # default dir
  #                '',            # default file
  #                'Perl files (pod,pm,pl)|*.pod;*.pm;*.pl|All files|*',
  #                (Wx::wxFD_OPEN()
  #                 | Wx::wxFD_FILE_MUST_EXIST()
  #                 | Wx::wxSTAY_ON_TOP())
  #               ));
  # Wx::Event::EVT_COMMAND ($dialog, $self, sub {
  #                           ### EVT_COMMAND() ...
  #                           my $filename = $dialog->GetPath;
  #                           $self->goto_pod (filename => $filename);
  #                         });
  # Wx::Event::EVT_ACTIVATE ($dialog, sub {
  #                            ### EVT_ACTIVATE() ...
  #                            my $filename = $dialog->GetPath;
  #                            $self->goto_pod (filename => $filename);
  #                          });
  # $dialog->Show;

  # if( $dialog->ShowModal == Wx::wxID_CANCEL() ) {
  #   ### user cancel ...
  #   return;
  # }
  # my $filename = $dialog->GetPath;
  # $self->goto_pod (filename => $filename);
  # $dialog->Destroy;
}

sub reload {
  my ($self) = @_;
  $self->{'podtext'}->reload;
}
sub go_back {
  my ($self) = @_;
  $self->{'podtext'}->go_back;
}
sub go_forward {
  my ($self) = @_;
  $self->{'podtext'}->go_forward;
}

sub _history_changed {
  my ($self) = @_;
  ### PodBrowser _history_changed() ...

  my $podtext = $self->{'podtext'};
  $self->{'go_back_menuitem'}->Enable($podtext->can_go_back);
  $self->{'go_forward_menuitem'}->Enable($podtext->can_go_forward);

  ### can_reload: $podtext->can_reload
  $self->{'reload_menuitem'}->Enable($podtext->can_reload);
}
sub _update_sections {
  my ($self) = @_;
  ### PodBrowser _update_sections() ...
  my $podtext = $self->{'podtext'};

  ### can_reload: $podtext->can_reload
  $self->{'reload_menuitem'}->Enable($podtext->can_reload);

  my @heading_list = $podtext->get_heading_list;
  ### @heading_list

  # limit number shown in menu
  if ($#heading_list > 50) {
    $#heading_list = 50;
  }


  {
    my $menubar = $self->GetMenuBar;
    my $pos = $menubar->FindMenu ($self->{'section_menu_label'});
    if ($pos != Wx::wxNOT_FOUND()) {
      $menubar->EnableTop ($pos, @heading_list > 0);
    }
  }
  {
    my $menu = $self->{'section_menu'};
    my @items = $menu->GetMenuItems;
    my $num = 0;
    foreach my $heading (@heading_list) {
      my $label = $heading;
      if (length $label > 30) {
        $label = substr($label,0,30) . Wx::gettext('...');
      }
      $label =~ s/&/&&/g; # escape

      my $help = Wx::gettext('Go to section:').' '.$heading;
      ### $label
      ### $help

      if (my $item = shift @items) {
        # cf SetItemLabel in Wx 2.9 up
        $menu->SetLabel($item->GetId, $label);
        $item->SetHelp ($help);
      } else {
        $item = $menu->Append (Wx::wxID_ANY(), $label, $help);
        my $thisnum = $num;
        EVT_MENU ($self, $item, sub { _section_menuitem_activate($self,$thisnum) });
      }
      $num++;
    }
    foreach my $item (@items) {
      $menu->Remove($item);
    }
  }
}

sub _section_menuitem_activate {
  my ($self, $num) = @_;
  ### _section_menuitem_activate(): $num

  my $podtext = $self->{'podtext'};
  my @headings = $podtext->get_heading_list;
  $self->goto_pod(section => $headings[$num]);
}

sub goto_own_pod {
  my ($self) = @_;
  $self->goto_pod (module => ref $self);
}
sub goto_pod {
  my ($self, @args) = @_;
  my $podtext = $self->{'podtext'};
  $podtext->goto_pod (@args);
}
sub OnPodChanged {
  my ($self, $event) = @_;
  my $what = $event->GetWhat;
  if ($what eq 'history') {
    _history_changed($self);
  }
  if ($what eq 'content') {
    _update_sections($self);
  }
}

sub quit {
  my ($self, $event) = @_;
  $self->Close;
}

#------------------------------------------------------------------------------
# Help/About

sub popup_about {
  my ($self, $event) = @_;

  my $info = Wx::AboutDialogInfo->new;
  $info->SetName(ref $self);
  # $info->SetIcon('...');
  $info->SetVersion($self->VERSION);
  $info->SetWebSite('http://user42.tuxfamily.org/wx-pod-browser/index.html');

  $info->SetDescription(sprintf("%s\n
You are running under: Perl %s, wxPerl %s, Wx %s",
                                $self->GetTitle,
                                sprintf('%vd', $^V),
                                Wx::wxVERSION_STRING,
                                Wx->VERSION));

  $info->SetCopyright(Wx::gettext('Copyright (C) 2012 Kevin Ryde

Wx-Pod-Browser is Free Software, distributed under the terms of the GNU General
Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.  Click on the
License button below for the full text.

Wx-Pod-Browser is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the license for more.
'));

  # the same as COPYING in the sources
  if (eval { require Software::License::GPL_3; 1}) {
    my $sl = Software::License::GPL_3->new({ holder => 'Kevin Ryde' });
    $info->SetLicense ($sl->license);
  }

  Wx::AboutBox($info);
}

#------------------------------------------------------------------------------

sub mouse_motion {
  my ($podtext, $event) = @_;
  #  ### Wx-PodBrowser mouse_motion(): $event->GetX,$event->GetY
  my $self = $podtext->GetParent;
  my $message = '';
  my ($outside, $col,$row) = $podtext->HitTest($event->GetPosition);
  # ### $outside
  # ### $row
  # ### $col
  if (! $outside) {
    if (defined (my $pos = $podtext->XYToPosition($col,$row))) {
      # ### $pos
      if (my $attrs = $podtext->GetRichTextAttrStyle($pos)) {
        # ### url: $attrs->GetURL
        if (my $url = $attrs->GetURL) {
          $message = $url;
        }
      }
    }
  }
  $self->show_url_message ($message);
  $event->Skip(1); # propagate to other processing
}
sub mouse_leave {
  my ($podtext, $event) = @_;
  my $self = $podtext->GetParent;
  $self->show_url_message ('');
  $event->Skip(1); # propagate to other processing
}
sub show_url_message {
  my ($self, $message) = @_;
  if ($self->{'url_message'} ne $message) {
    $self->{'url_message'} = $message;
    $self->SetStatusText ($message);
  }
}

1;

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::Wx::Perl::PodBrowser -- POD browser window

=head1 SYNOPSIS

 use App::MathImage::Wx::Perl::PodBrowser;
 my $browser = App::MathImage::Wx::Perl::PodBrowser->new;
 $browser->Show;
 $browser->goto_pod (module => 'Foo::Bar');

=head1 CLASS HIERARCHY

    App::MathImage::Wx::Perl::PodBrowser
      Wx::Frame

=head1 DESCRIPTION

I<In progress, mostly working ...>

This is a simple POD documentation browser using C<Wx::RichTextCtrl>.  The
menus and any links in the text can be followed to other documents.

    +-------------------------------------------+
    | File  Section  Help                       |
    +-------------------------------------------+
    | NAME                                      |
    |   Foo - some thing                        |
    | DESCRIPTION                               |
    |   Blah blah.                              |
    | SEE ALSO                                  |
    |   Bar                                     |
    +-------------------------------------------+
    |                                           |
    +-------------------------------------------+

=head2 Programming

The initial window size follows the 80x30 initial size of the PodRichText
widget.  Program code or user interaction can make it bigger or smaller
later as desired.

The menubar is available from the usual frame C<$browser-E<gt>GetMenuBar> to
make additions or modifications.  The quit menu item is C<Wx::wxID_EXIT> and
closes the window with the usual frame C<$browser-E<gt>Close()>.  In a
multi-window program this just closes the PodBrowser window, it doesn't exit
the whole program.

=head1 FUNCTIONS

=over 4

=item C<$browser = App::MathImage::Wx::Perl::PodBrowser-E<gt>new ()>

=item C<$browser = App::MathImage::Wx::Perl::PodBrowser-E<gt>new ($parent, $id, $title)>

Create and return a new browser window widget.

The C<$parent>, C<$id> and C<$title> arguments are per
C<Wx::Frame-E<gt>new()>.

The default C<$title> is "POD Browser".  An application using it for a help
display could give something more specific if desired, either at creation or
later with C<$window-E<gt>SetTitle()> in the usual way.

=back

=cut

# =head2 Mainline
# 
# =over
# 
# =item C<$exitcode = App::MathImage::Wx::Perl::PodBrowser-E<gt>command_line ()>
# 
# Run a POD browser as from the command line.  Arguments are taken from
# C<@ARGV> and the return value is an exit code suitable for C<exit>.
# 
# =back

=head1 SEE ALSO

L<Wx>,
L<Wx::Perl::PodEditor>
L<Tk::Pod>,
L<Gtk2::Ex::PodViewer>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2012 Kevin Ryde

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
