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


package App::MathImage::Wx::Perl::PodRichText::SimpleParser;
use strict;
use warnings;
use base 'Pod::Simple';
our $VERSION = 100;

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  ### PodRichText-Parser new(): @_

  my $self = $class->SUPER::new (%options);
  $self->{'textctrl'} = $options{'textctrl'};

  $self->nbsp_for_S(1);   # latin-1 0xA0
  $self->preserve_whitespace (1);  # eg. two-spaces for full stop
  $self->accept_targets ('text','TEXT');
  return $self;
}

sub _handle_text {
  my ($self, $text) = @_;
  ### _handle_text: $text
  my $textctrl = $self->{'textctrl'};

  if ($self->{'in_X'}) {
    $self->{'X'} .= $text;
    return;
  }

  if ($self->{'verbatim'}) {
    $text =~ s/[ \t\r]*\n/\x1D/g; # newlines to Wx::wxRichTextLineBreakChar()
    #   if ($text eq '') {
    #     ### collapse empty verbatim ...
    #     return '';
    #   }
  } else {
    if ($self->{'start_Para'}) {
      $text =~ s/^\s+//;
      return if $text eq '';
      $self->{'start_Para'} = 0;
    }
    $text =~ s/\s*\r?\n\s*/ /g;  # flow newlines
  }
  ### $text
  $textctrl->WriteText($text);
}

sub _handle_element_start {
  my ($self, $element, $attrs) = @_;
  ### _handle_element_start(): $element
  my $textctrl = $self->{'textctrl'};

  if ($element eq 'Document') {
    $self->{'indent'} = 0;

    my $attrs = $textctrl->GetBasicStyle;
    my $font = $attrs->GetFont;
    my $font_mm = $font->GetPointSize * (1/72 * 25.4);
    # 1.5 characters expressed in tenths of mm
    $self->{'indent_step'} = int($font_mm*10 * 1.5);
    ### $font_mm
    ### indent_step: $self->{'indent_step'}

    $textctrl->Clear;
    $textctrl->SetDefaultStyle ($textctrl->GetBasicStyle);
    $textctrl->BeginSuppressUndo;
    # .6 of a line, expressed in tenths of a mm
    $textctrl->BeginParagraphSpacing ($font_mm*10 * .2,  # before
                                      $font_mm*10 * .4); # after
    $textctrl->{'section_positions'} = {};
    $textctrl->{'heading_list'} = [];

  } elsif ($element eq 'Para'
           || $element eq 'Data') {  # =end text
    $self->{'start_Para'} = 1;
    $textctrl->BeginLeftIndent($self->{'indent'} + $self->{'indent_step'});

  } elsif ($element eq 'Verbatim') {
    ### start verbatim ...
    $self->{'verbatim'} = 1;
    $textctrl->BeginLeftIndent($self->{'indent'} + $self->{'indent_step'});
    $textctrl->BeginRightIndent(-10000);
    # $textctrl->BeginTextColour(Wx::wxRED());
    $textctrl->BeginCharacterStyle('code');

  } elsif ($element =~ /^over/) {
    $self->{'indent'} += $self->{'indent_step'};

  } elsif ($element =~ /^item/) {
    $self->{'startpos'} = $textctrl->GetInsertionPoint;
    if ($element eq 'item-bullet') {
      $textctrl->BeginStandardBullet("standard/circle",
                                     $self->{'indent'},
                                     $self->{'indent_step'});
    } elsif ($element eq 'item-number') {
      # $textctrl->BeginLeftIndent($self->{'indent'});
      # $self->_handle_text($number.'.');

      $textctrl->BeginNumberedBullet($attrs->{'number'},
                                     $self->{'indent'},
                                     $self->{'indent_step'});
    } else {
      $textctrl->BeginLeftIndent($self->{'indent'});
    }

  } elsif ($element =~ /^head(\d*)/) {
    my $level = $1;
    $textctrl->BeginLeftIndent($self->{'indent'}
                               # half indent for =head2 and higher
                               + ($level > 1 ? $self->{'indent_step'} / 2 : 0));
    $textctrl->BeginBold;
    $self->{'startpos'} = $textctrl->GetInsertionPoint;

  } elsif ($element eq 'B') {
    $self->{'bold'}++;
    $textctrl->BeginBold;
  } elsif ($element eq 'C') {
    $textctrl->BeginCharacterStyle('code');
  } elsif ($element eq 'I') {
    $textctrl->BeginItalic;
  } elsif ($element eq 'F') {
    $textctrl->BeginCharacterStyle('file');
    # $textctrl->BeginItalic;

  } elsif ($element eq 'L') {
    if ($attrs->{'type'} eq 'pod') {
      my $url = 'pod://';
      my $to = $attrs->{'to'};
      my $section = $attrs->{'section'};
      if (defined $to)      { $url .= $to; }
      if (defined $section) { $url .= "#$section"; }
      $textctrl->BeginURL ($url);
      $self->{'in_URL'}++;
    } elsif ($attrs->{'type'} eq 'url') {
      $textctrl->BeginURL ($attrs->{'to'});
      $self->{'in_URL'}++;
    }
    $textctrl->BeginCharacterStyle('link');

  } elsif ($element eq 'X') {
    $self->{'in_X'} = 1;
  }
}
sub _handle_element_end {
  my ($self, $element, $attrs) = @_;
  ### end: $element

  my $textctrl = $self->{'textctrl'};

  if ($element eq 'Document') {
    $textctrl->EndSuppressUndo;
    $textctrl->EndParagraphSpacing;
    $textctrl->SetInsertionPoint(0);

  } elsif ($element eq 'Para'
           || $element eq 'Data') {   # =begin text
    $self->{'start_Para'} = 0;
    $textctrl->Newline;
    $textctrl->EndLeftIndent;

  } elsif ($element eq 'Verbatim') {
    $self->{'verbatim'} = 0;
    $textctrl->EndCharacterStyle;
    $textctrl->Newline;
    $textctrl->EndRightIndent;
    $textctrl->EndLeftIndent;

  } elsif ($element =~ /^head(\d*)/) {
    $self->set_section_range($self->{'startpos'},$textctrl->GetInsertionPoint);
    $textctrl->EndBold;
    $textctrl->Newline;
    $textctrl->EndLeftIndent;

  } elsif ($element =~ /^over/) { # =back
    $self->{'indent'} -= $self->{'indent_step'};

  } elsif ($element =~ /^item/) {
    $self->set_item_range ($self->{'startpos'}, $textctrl->GetInsertionPoint);
    $textctrl->Newline;
    if ($element eq 'item-bullet') {
      $textctrl->EndStandardBullet;
    } elsif ($element eq 'item-number') {
      $textctrl->EndNumberedBullet;
    } else {
      $textctrl->EndLeftIndent;
    }

  } elsif ($element eq 'B') {
    $self->{'bold'}--;
    $textctrl->EndBold;
  } elsif ($element eq 'C') {
    $textctrl->EndCharacterStyle;
  } elsif ($element eq 'I') {
    $textctrl->EndItalic;
  } elsif ($element eq 'F') {
    $textctrl->EndCharacterStyle;

  } elsif ($element eq 'L') {
    $textctrl->EndCharacterStyle;
    if ($self->{'in_URL'}) {
      $self->{'in_URL'}--;
      $textctrl->EndURL;
    }

  } elsif ($element eq 'X') {
    delete $self->{'in_X'};
    push @{$textctrl->{'index_list'}},
      delete $self->{'X'}, $self->{'startpos'};
  }
}

# set the position of $section to $pos
# if $pos is not given then default to the current insertion point
sub set_section_range {
  my ($self, $startpos, $endpos) = @_;
  ### set_section_position() ...
  my $textctrl = $self->{'textctrl'};

  my $section = $textctrl->GetRange($startpos, $endpos);
  $section =~ s/\s+$//; # trailing whitespace
  push @{$textctrl->{'heading_list'}}, $section;
  $textctrl->{'section_positions'}->{$section} = $startpos;
  $section = lc($section);
  if (! defined $textctrl->{'section_positions'}->{$section}) {
    $textctrl->{'section_positions'}->{$section} = $startpos;
  }
}
sub set_item_range {
  my ($self, $startpos, $endpos) = @_;

  my $textctrl = $self->{'textctrl'};

  my $item = $textctrl->GetRange($startpos, $endpos);
  $item =~ s/\s+$//; # trailing whitespace
  foreach my $name ($item,
                    ($item =~ /(\w+)/ ? $1 : ())) { # also just the first word
    $textctrl->{'section_positions'}->{$name} = $startpos;
    my $lname = lc($name);
    if (! defined $textctrl->{'section_positions'}->{$lname}) {
      $textctrl->{'section_positions'}->{$lname} = $startpos;
    }
  }
}

1;
__END__
