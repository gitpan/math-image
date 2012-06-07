# Copyright 2012 Kevin Ryde

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


package App::MathImage::Wx::Perl::PodRichText;
use strict;
use Carp;
use Wx;
use Wx::RichText;

use base 'Wx::RichTextCtrl';
our $VERSION = 100;

use base 'Exporter';
our @EXPORT_OK = ('EVT_PERL_PODRICHTEXT_CHANGED');

# uncomment this to run the ### lines
#use Smart::Comments;


#------------------------------------------------------------------------------
# changed event

my $changed_eventtype = Wx::NewEventType;

# this works, not sure if it's quite right
sub EVT_PERL_PODRICHTEXT_CHANGED ($$$) {
  my ($self, $target, $func) = @_;
  $self->Connect($target, -1, $changed_eventtype, $func);
}
{
  package App::MathImage::Wx::Perl::PodRichText::ChangedEvent;
  use strict;
  use warnings;
  use base qw(Wx::PlCommandEvent);
  sub GetWhat {
    my ($self) = @_;
    return $self->{'what'};
  }
  sub SetWhat {
    my ($self, $newval) = @_;
    $self->{'what'} = $newval;
  }
}
sub emit_changed {
  my ($self, $what) = @_;
  my $event = App::MathImage::Wx::Perl::PodRichText::ChangedEvent->new
    ($changed_eventtype, $self->GetId);
  $event->SetWhat($what);
  $self->GetEventHandler->ProcessEvent($event);
}


#------------------------------------------------------------------------------

sub new {
  my ($class, $parent, $id) = @_;
  if (! defined $id) { $id = Wx::wxID_ANY(); }
  my $self = $class->SUPER::new ($parent,
                                 $id,
                                 Wx::gettext('Nothing selected'),
                                 Wx::wxDefaultPosition(),
                                 Wx::wxDefaultSize(),
                                 (Wx::wxTE_AUTO_URL()
                                  | Wx::wxTE_MULTILINE()
                                  | Wx::wxTE_READONLY()
                                  | Wx::wxHSCROLL()
                                  | Wx::wxTE_PROCESS_ENTER()
                                 ));
  Wx::Event::EVT_TEXT_URL ($self, $self, 'OnUrl');
  Wx::Event::EVT_TEXT_ENTER ($self, $self, 'OnEnter');
  Wx::Event::EVT_KEY_DOWN ($self, 'OnKey');

  # Must hold in $self->{'stylesheet'} or a refcount bug bites wxPerl 0.9901.
  my $stylesheet
    = $self->{'stylesheet'}
      = Wx::RichTextStyleSheet->new;
  $self->SetStyleSheet ($stylesheet);
  {
    my $basic_attrs = $self->GetBasicStyle;
    my $basic_font = $basic_attrs->GetFont;
    my $font = Wx::Font->new ($basic_font->GetPointSize,
                              Wx::wxFONTFAMILY_TELETYPE(),
                              $basic_font->GetStyle,
                              $basic_font->GetWeight,
                              $basic_font->GetUnderlined);
    ### code facename: $font->GetFaceName

    my $attrs = Wx::RichTextAttr->new;
    $attrs->SetFontFaceName ($font->GetFaceName);
    $attrs->SetFlags (Wx::wxTEXT_ATTR_FONT_FACE());

    my $style = Wx::RichTextCharacterStyleDefinition->new ('code');
    $style->SetStyle($attrs);
    $stylesheet->AddCharacterStyle ($style);
  }
  {
    my $attrs = Wx::RichTextAttr->new;
    $attrs->SetFontStyle (Wx::wxTEXT_ATTR_FONT_ITALIC());
    $attrs->SetFlags (Wx::wxTEXT_ATTR_FONT_ITALIC());

    my $style = Wx::RichTextCharacterStyleDefinition->new ('file');
    $style->SetStyle($attrs);
    $stylesheet->AddCharacterStyle ($style);
  }
  {
    my $attrs = Wx::RichTextAttr->new;
    $attrs->SetFontUnderlined (1);
    $attrs->SetFlags (Wx::wxTEXT_ATTR_FONT_UNDERLINE());

    my $style = Wx::RichTextCharacterStyleDefinition->new ('link');
    $style->SetStyle($attrs);
    $stylesheet->AddCharacterStyle ($style);
  }

  $self->{'history'} = [];
  $self->{'forward'} = [];
  $self->{'location'} = undef;
  $self->Clear;

  $self->set_size_chars(80, 30);
  return $self;
}

#------------------------------------------------------------------------------

sub set_size_chars {
  my ($self, $width, $height) = @_;
  my $attrs = $self->GetBasicStyle;
  my $font = $attrs->GetFont;
  my $font_points = $font->GetPointSize;
  my $font_mm = $font_points * (1/72 * 25.4);

  ### $font_mm
  ### xpixels: x_millimetres_to_pixels ($self, $width * $font_mm * .8)
  ### ypixels: y_millimetres_to_pixels ($self, $height * $font_mm)

  $self->SetSize (x_millimetres_to_pixels ($self, $width * $font_mm * .8),
                  y_millimetres_to_pixels ($self, $height * $font_mm));
}
# cf Wx::Display->GetFromWindow($window), but it doesn't have MM ?
#
sub x_millimetres_to_pixels {  
  my ($window, $mm) = @_;
  my $size_pixels = Wx::GetDisplaySize();
  my $size_mm = Wx::GetDisplaySizeMM();
  return $mm * $size_pixels->GetWidth / $size_mm->GetWidth;
}
sub y_millimetres_to_pixels {
  my ($window, $mm) = @_;
  my $size_pixels = Wx::GetDisplaySize();
  my $size_mm = Wx::GetDisplaySizeMM();
  return $mm * $size_pixels->GetHeight / $size_mm->GetHeight;
}
# sub pixel_size_mm {
#   my ($window) = @_;
#   my $size_pixels = Wx::GetDisplaySize();
#   my $size_mm = Wx::GetDisplaySizeMM();
#   return ($size_mm->GetWidth / $size_pixels->GetWidth,
#           $size_mm->GetHeight / $size_pixels->GetHeight);
# }

#------------------------------------------------------------------------------
# sections

sub get_section_position {
  my ($self, $section) = @_;
  ### get_section_position(): $section

  my $pos = $self->{'section_positions'}->{$section};
  if (! defined $pos) {
    $pos = $self->{'section_positions'}->{lc($section)};
  }
  ### $pos
  return $pos;
}

sub get_heading_list {
  my ($self) = @_;
  return @{$self->{'heading_list'} ||= []};
}

#------------------------------------------------------------------------------

sub goto_pod {
  my ($self, %options) = @_;
  ### goto_pod(): keys %options

  my %location;
  $self->current_location_line; # before section move etc

  if (defined (my $guess = $options{'guess'})) {
    if ($guess eq '-') {
      $options{'filehandle'} = \*STDIN;
    } elsif ($guess =~ /::/
             || do { require Pod::Find; Pod::Find::pod_where({-inc=>1}, $guess) }) {
      $options{'module'} = $guess;
    } elsif (-e $guess) {
      $options{'filename'} = $guess;
    } elsif ($guess =~ /^=(head|pod)/m
             || $guess =~ /^\s*$/) {
      $options{'string'} = $guess;
    } else {
      $self->show_error_text ("Cannot guess POD input type");
      return;
    }
  }

  my $module = $options{'module'};
  if (defined $module && $module ne '') {
    ### $module
    require Pod::Find;
    my $filename = Pod::Find::pod_where({-inc=>1}, $module);
    ### $filename
    if (! $filename) {
      $self->show_error_text ("Module not found: $module");
      return;
    }
    $options{'filename'} = $filename;
    $location{'module'} = $module;
  }

  my $filename = $options{'filename'};
  if (defined $filename && $filename ne '') {
    ### $filename
    my $fh;
    if (! open $fh, '<', $filename) {
      $self->show_error_text ("Cannot open $filename: $!");
      return;
    }
    $options{'filehandle'} = $fh;
    $options{'close_fh'} = 1;
    unless (exists $location{'module'}) {
      $location{'filename'} = $filename;
    }
  }

  if (defined $options{'string'}) {
    ### string ...
    # Note: must keep string in its own scalar since IO::String takes a
    # reference not a copy.
    require IO::String;
    $options{'filehandle'} = IO::String->new ($options{'string'});
  }

  if (defined (my $fh = $options{'filehandle'})) {
    ### filehandle: $fh

    require App::MathImage::Wx::Perl::PodRichText::SimpleParser;
    $self->{'parser'} = App::MathImage::Wx::Perl::PodRichText::SimpleParser->new
      (textctrl => $self);
    $self->{'section'} = delete $options{'section'};
    $self->{'line'} = delete $options{'line'};
    $self->{'fh'} = $fh;
    $self->{'busy'} ||= Wx::BusyCursor->new;
    require Time::HiRes;
    $self->parse_some (1);

    # require App::MathImage::Wx::Perl::PodRichText::PodParser;
    # my $parser = App::MathImage::Wx::Perl::PodRichText::PodParser->new
    #   (textctrl => $self);
    # $parser->parse_from_filehandle ($fh);
    # if ($options{'close_fh'}) {
    #   close $fh
    #     or $self->WriteText ("\n\n\nError closing filehandle: $!");
    # }

    # $self->SetInsertionPoint(0);
    $options{'content_changed'} = 1;
  }

  if (defined (my $line = $options{'line'})) {
    $self->SetInsertionPoint($self->XYToPosition($options{'column'} || 0,
                                                 $options{'line'}));
    $location{'line'} = $line;
  }

  if (defined (my $section = $options{'section'})) {
    if (defined (my $pos = $self->get_section_position($section))) {
      $self->SetInsertionPoint($pos);
      my ($x,$y) = $self->PositionToXY($pos);
      $location{'line'} = $y;
    } else {
      ### unknown section ...
      # Wx::Bell();
    }
  }

  if ($self->{'fh'}) {
    # show start while load in progress
    $self->ShowPosition(0);
  } else {
    # end and then back again scrolls window to have point at the top
    $self->ShowPosition($self->GetLastPosition);
    $self->ShowPosition($self->GetInsertionPoint);
  }

  unless ($options{'no_history'}) {
    if (%{$self->{'location'}}) {
      my $history = $self->{'history'};
      push @$history, $self->{'location'};
      if (@$history > 20) {
        splice @$history, 0, -20; # keep last 20
      }
    }
    $self->{'location'} = \%location;
    $options{'history_changed'} = 1;
  }

  ### goto_pod done ...
  ### location now: $self->{'location'}
  ### history now: $self->{'history'}

  if ($options{'content_changed'}) {
    $self->emit_changed('content');
  }
  if ($options{'history_changed'}) {
    $self->emit_changed('history');
  }
}

sub parse_some {
  my ($self, $nofreeze) = @_;
  ### parse_some() ...

  my $freezer = $nofreeze || Wx::WindowUpdateLocker->new($self);
  $self->SetInsertionPoint($self->GetLastPosition); # for WriteText
  my $fh = $self->{'fh'} || return;
  my $t = Time::HiRes::time();
  my $eof = 0;
  for (;;) {
    my @lines;
    for (;;) {
      my $line = <$fh>;
      push @lines, $line;
      if (! defined $line) {
        # eof
        delete $self->{'fh'};
        delete $self->{'busy'};
        $self->{'parser'}->parse_lines (@lines);
        $self->goto_pod (section => delete $self->{'section'},
                         line    => delete $self->{'line'},
                         no_history => 1);
        $self->emit_changed('content');
        return;
      }
      if (@lines >= 20) {
        last;
      }
    }
    $self->{'parser'}->parse_lines (@lines);
    if (abs (Time::HiRes::time() - $t) > .4) {
      last;
    }
  }

  $self->{'timer'} ||= do {
    my $timer = Wx::Timer->new ($self);
    Wx::Event::EVT_TIMER ($self, -1, \&parse_some);
    $timer
  };
  $self->{'timer'}->Start(50,Wx::wxTIMER_ONE_SHOT());
}

sub show_error_text {
  my ($self, $str) = @_;
  $self->Clear;
  $self->SetDefaultStyle ($self->GetBasicStyle);
  $self->WriteText ($str);
  $self->SetInsertionPoint(0);
}

#------------------------------------------------------------------------------
# history

sub can_reload {
  my ($self) = @_;
  ### can_reload(): $self->{'location'}
  return (defined $self->{'location'}->{'module'}
          || defined $self->{'location'}->{'filename'});
}
sub reload {
  my ($self) = @_;
  $self->current_location_line;
  $self->goto_pod (%{$self->{'location'}},
                   no_history => 1);
  ### location now: $self->{'location'}
  ### history now: $self->{'history'}
}

sub can_go_forward {
  my ($self) = @_;
  return @{$self->{'forward'}} > 0;
}
sub go_forward {
  my ($self) = @_;
  if (defined (my $forward_location = shift @{$self->{'forward'}})) {
    my $current_location = $self->{'location'};

    my %goto_pod = %$forward_location;
    if ($goto_pod{'module'}
        && $current_location->{'module'}
        && $goto_pod{'module'} eq $current_location->{'module'}) {
      delete $goto_pod{'module'};
    } elsif ($goto_pod{'filename'}
             && $current_location->{'filename'}
             && $goto_pod{'filename'} eq $current_location->{'filename'}) {
      delete $goto_pod{'filename'};
    }
    $self->goto_pod (%goto_pod,
                     history_changed => 1);
  }
}
sub can_go_back {
  my ($self) = @_;
  return @{$self->{'history'}} > 0;
}
sub go_back {
  my ($self) = @_;
  if (defined (my $back_location = pop @{$self->{'history'}})) {
    my $current_location = $self->{'location'};
    $self->current_location_line;
    unshift @{$self->{'forward'}}, $current_location;
    $self->{'location'} = $back_location;

    my %goto_pod = %$back_location;
    if ($goto_pod{'module'}
        && $current_location->{'module'}
        && $goto_pod{'module'} eq $current_location->{'module'}) {
      delete $goto_pod{'module'};
    } elsif ($goto_pod{'filename'}
             && $current_location->{'filename'}
             && $goto_pod{'filename'} eq $current_location->{'filename'}) {
      delete $goto_pod{'filename'};
    }
    $self->goto_pod (%goto_pod,
                     no_history => 1,
                     history_changed => 1);
  }
}
sub current_location_line {
  my ($self) = @_;
  ### current_location_line() ...
  ### location now: $self->{'location'}
  if (%{$self->{'location'}}) {
    my ($x,$y) = $self->PositionToXY($self->GetFirstVisiblePosition);
    $self->{'location'}->{'line'} = $y;
  }
}

#------------------------------------------------------------------------------
# link following

sub OnKey {
  my ($self, $event) = @_;
  ### PodRichText OnEnter(): $event
  ### keycode: $event->GetKeyCode
  if ($event->ControlDown) {
    if ($event->GetKeyCode == ord('b') || $event->GetKeyCode == ord('B')) {
      $self->go_back;
    } elsif ($event->GetKeyCode == ord('f') || $event->GetKeyCode == ord('F')) {
      $self->go_forward;
    }
  } else {
    if ($event->GetKeyCode == ord("\r")) {
      $self->_goto_link_at_pos ($self->GetInsertionPoint);
    }
  }
  $event->Skip(1); # propagate to other handlers
}
sub OnUrl {
  my ($self, $event) = @_;
  ### PodRichText OnUrl(): $event
  $self->_goto_link_at_pos ($event->GetURLStart);
  $event->Skip(1); # propagate to other handlers
}
sub _goto_link_at_pos {
  my ($self, $pos) = @_;
  ### get_url_at_pos(): $pos
  my $attrs = $self->GetRichTextAttrStyle($pos);
  if (defined (my $url = $attrs->GetURL)) {
    ### $url
    if ($url =~ m{^pod://([^#]+)?(#(.*))?}) {
      my $module = $1;
      my $section = $3;
      ### $module
      ### $section
      $self->goto_pod (module  => $module,
                       section => $section);
    } else {
      Wx::LaunchDefaultBrowser($url);
    }
  }
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::Wx::Perl::PodRichText -- POD in a Wx::RichTextCtrl

=head1 SYNOPSIS

 use App::MathImage::Wx::Perl::PodRichText;
 my $podtext = App::MathImage::Wx::Perl::PodRichText->new;
 $podtext->goto_pod (module => 'Foo::Bar');

=head1 CLASS HIERARCHY

    App::MathImage::Wx::Perl::PodRichText
      Wx::RichTextCtrl

=head1 DESCRIPTION

I<In progress, mostly working ...>

This is a wxRichTextCtrl for displaying formatted POD documents, either from
F<.pod> or F<.pm> files, or parsed from a string or file handle.

See L<App::MathImage::Wx::Perl::PodBrowser> for a whole browser window.

=head2 Details

The widget initial C<SetSize> is approximately 80 columns by 30 lines of the
default font.  A parent widget can make it bigger or smaller as desired.

Formatting tries to make use of the RichText features.  Indentation is done
with the left indent feature so text paragraphs flow nicely within C<=over>
etc.

C<=item> bullet points use the RichText bullet feature, and numbered
C<=item> likewise.  Circa Wx 2.8.12 numbered points seem to display with the
text overlapping a big number, but it's presumed that's a Wx matter, and for
small numbers it's fine.

Verbatim paragraphs are done in C<wxFONTFAMILY_TELETYPE> and with
C<wxRichTextLineBreakChar> for line breaks at each newline.  Wraparound is
avoided by a large negative right indent but there's no scroll bar or visual
indication that there's more text off to the right.  Avoiding wraparound
helps tables and ascii art.

LE<lt>E<gt> links to URLs are underlined and buttonized with the "URL"
attribute.  LE<lt>E<gt> links to POD similarly, using a "pod://" pseudo-URL.
Is that a good idea?  Such a url won't be usable by anything else, but it's
a handy place to hold the link target.

=cut

# An C<EVT_TEXT_URL> handler follows to the target POD or
# runs C<Wx::LaunchDefaultBrowser()> for URLs.  (Perhaps there could be an
# option to restrict that if an application only wanted to display a single
# POD.)

# C<Wx::wxTE_AUTO_URL> is turned on attempting to pick up unlinked URLs, but
# it doesn't seem to have any effect circa Wx 2.8.12 with Gtk.  Is that option
# only for the plain C<Wx::TextCtrl>?

=pod

C<SE<lt>E<gt>> non-breaking text is done with latin-1 0xA0 non-breaking
spaces.  RichText obeys when word wrapping.

The display is reckoned as "text" so C<=begin text> sections are included in
the display.  Other C<=begin> types are ignored.

Reading a large POD file is slow.  The work is done piece-wise from the
event loop to try to keep the rest of the application running.

=head1 FUNCTIONS

=over

=item C<$podtext = App::MathImage::Wx::Perl::PodRichText-E<gt>new()>

=item C<$podtext = App::MathImage::Wx::Perl::PodRichText-E<gt>new($id,$parent)>

Create and return a new PodRichText widget.

=item C<$podtext-E<gt>goto_pod (key =E<gt> value, ...)>

Go to a specified POD module, filename, section etc.  The key/value options
are

    module     => $str      module etc in @INC
    filename   => $str      file name
    filehandle => $fh
    string     => $str
    guess      => $str

    section  => $string
    line     => $integer     line number

The target POD document is given by C<module>, C<filename>, etc.  C<string>
is POD in a string.

    # move within current displayed document
    $podtext->goto_pod (module => "perlpodspec");

C<guess> tries a module, filename, or POD string.  It's designed for use
from a command line or similar loose input to let the user enter either
module or filename.

Optional C<section> or C<line> is a position within the document.  They can
be given alone to move within the currently displayed document.

    # move within current displayed document
    $podtext->goto_pod (section => "DESCRIPTION");

C<section> can be an C<=head> heading or an C<=item> text.  The first word
from an C<=item> works too, as is common for the POD formatters and which
helps cross-references to L<perlfunc> and similar.

=item C<@strings = $podtext-E<gt>get_heading_list ()>

Return a list of the C<=head> headings in the displayed document.

=back

=head1 SEE ALSO

L<Wx>,
L<App::MathImage::Wx::Perl::PodBrowser>

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
